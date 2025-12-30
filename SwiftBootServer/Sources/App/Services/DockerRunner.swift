import Foundation
import Vapor

/// Docker 컨테이너에서 코드를 실행하고 결과를 반환
actor DockerRunner {
    private let workDir = "/tmp/swiftboot/submissions"
    private let timeout: Int = 5
    private let memoryLimit = "128m"
    private let cpuLimit = "0.5"

    /// 코드 실행 결과
    struct ExecutionResult {
        let stdout: String
        let stderr: String
        let exitCode: Int32
        let timedOut: Bool
        let executionTime: TimeInterval
    }

    /// 코드 실행
    func execute(code: String, config: LanguageConfig) async throws -> ExecutionResult {
        let submissionId = UUID().uuidString
        let submissionDir = "\(workDir)/\(submissionId)"
        let fileName = "main.\(config.fileExtension)"
        let filePath = "\(submissionDir)/\(fileName)"

        // 1. 작업 디렉토리 생성
        try createDirectory(at: submissionDir)

        defer {
            // 정리: 임시 파일 삭제
            cleanup(directory: submissionDir)
        }

        // 2. 코드 파일 작성
        try writeCode(code, to: filePath)

        // 3. Docker 명령 실행
        let startTime = Date()
        let result = try await runDockerContainer(
            config: config,
            submissionDir: submissionDir
        )
        let executionTime = Date().timeIntervalSince(startTime)

        return ExecutionResult(
            stdout: result.stdout,
            stderr: result.stderr,
            exitCode: result.exitCode,
            timedOut: result.timedOut,
            executionTime: executionTime
        )
    }

    // MARK: - Private Helpers

    private func createDirectory(at path: String) throws {
        try FileManager.default.createDirectory(
            atPath: path,
            withIntermediateDirectories: true,
            attributes: nil
        )
    }

    private func writeCode(_ code: String, to path: String) throws {
        try code.write(toFile: path, atomically: true, encoding: .utf8)
    }

    private func cleanup(directory: String) {
        try? FileManager.default.removeItem(atPath: directory)
    }

    private func runDockerContainer(
        config: LanguageConfig,
        submissionDir: String
    ) async throws -> (stdout: String, stderr: String, exitCode: Int32, timedOut: Bool) {
        let dockerArgs = buildDockerArgs(config: config, submissionDir: submissionDir)

        // 타임아웃 상태를 추적하기 위한 래퍼
        final class TimeoutState: @unchecked Sendable {
            var timedOut = false
        }
        let timeoutState = TimeoutState()

        return try await withCheckedThrowingContinuation { continuation in
            let process = Process()
            process.executableURL = URL(fileURLWithPath: "/usr/local/bin/docker")
            process.arguments = dockerArgs

            let stdoutPipe = Pipe()
            let stderrPipe = Pipe()
            process.standardOutput = stdoutPipe
            process.standardError = stderrPipe

            // 타임아웃 처리 (Docker 내부 timeout + 여유 시간)
            let timeoutSeconds = Double(timeout + 2)
            let timer = DispatchSource.makeTimerSource(queue: .global())
            timer.schedule(deadline: .now() + timeoutSeconds)
            timer.setEventHandler {
                timeoutState.timedOut = true
                process.terminate()
            }
            timer.resume()

            process.terminationHandler = { proc in
                timer.cancel()

                let stdoutData = stdoutPipe.fileHandleForReading.readDataToEndOfFile()
                let stderrData = stderrPipe.fileHandleForReading.readDataToEndOfFile()

                let stdout = String(data: stdoutData, encoding: .utf8) ?? ""
                let stderr = String(data: stderrData, encoding: .utf8) ?? ""

                continuation.resume(returning: (stdout, stderr, proc.terminationStatus, timeoutState.timedOut))
            }

            do {
                try process.run()
            } catch {
                timer.cancel()
                continuation.resume(throwing: error)
            }
        }
    }

    private func buildDockerArgs(config: LanguageConfig, submissionDir: String) -> [String] {
        [
            "run",
            "--rm",                             // 컨테이너 자동 삭제
            "--network", "none",                // 네트워크 격리
            "--memory", memoryLimit,            // 메모리 제한
            "--cpus", cpuLimit,                 // CPU 제한
            "--read-only",                      // 읽기 전용 파일시스템
            "--tmpfs", "/tmp:size=50m,mode=1777", // 임시 쓰기 공간 (캐시 포함)
            "-e", "HOME=/tmp",                  // 홈 디렉토리를 /tmp로 설정 (캐시용)
            "--user", "nobody:nogroup",         // 비특권 사용자
            "--pids-limit", "50",               // 프로세스 수 제한
            "--security-opt", "no-new-privileges", // 권한 상승 방지
            "-v", "\(submissionDir):/app:ro",   // 코드 마운트 (읽기 전용)
            "-w", "/app",                       // 작업 디렉토리
            config.dockerImage,
            "timeout", String(timeout),         // 타임아웃
            "sh", "-c", config.runCommand
        ]
    }
}
