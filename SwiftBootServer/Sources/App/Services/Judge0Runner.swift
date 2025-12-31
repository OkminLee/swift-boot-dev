import Vapor
import Foundation

/// Judge0 API를 통한 코드 실행
struct Judge0Runner {
    private let baseURL = "https://ce.judge0.com"
    private let client: Client

    init(client: Client) {
        self.client = client
    }

    /// 코드 실행 결과
    struct ExecutionResult {
        let stdout: String
        let stderr: String
        let exitCode: Int32
        let timedOut: Bool
        let executionTime: TimeInterval
    }

    /// Judge0 API 응답 구조
    struct Judge0Response: Content {
        let stdout: String?
        let stderr: String?
        let compileOutput: String?
        let message: String?
        let time: String?
        let memory: Int?
        let status: Status

        struct Status: Content {
            let id: Int
            let description: String
        }

        enum CodingKeys: String, CodingKey {
            case stdout, stderr, message, time, memory, status
            case compileOutput = "compile_output"
        }
    }

    /// Judge0 API 요청 구조
    struct Judge0Request: Content {
        let languageId: Int
        let sourceCode: String

        enum CodingKeys: String, CodingKey {
            case languageId = "language_id"
            case sourceCode = "source_code"
        }
    }

    /// 코드 실행
    func execute(code: String, config: LanguageConfig) async throws -> ExecutionResult {
        let startTime = Date()

        // Base64 인코딩
        let base64Code = Data(code.utf8).base64EncodedString()

        let request = Judge0Request(
            languageId: config.judge0LanguageId,
            sourceCode: base64Code
        )

        let response = try await client.post(
            URI(string: "\(baseURL)/submissions?base64_encoded=true&wait=true")
        ) { req in
            req.headers.contentType = .json
            try req.content.encode(request, as: .json)
        }

        guard response.status == .ok || response.status == .created else {
            let body = response.body.map { String(buffer: $0) } ?? "No body"
            throw Abort(.internalServerError, reason: "Judge0 API 오류: \(response.status) - \(body)")
        }

        let judge0Response = try response.content.decode(Judge0Response.self)
        let executionTime = Date().timeIntervalSince(startTime)

        // 상태 코드 확인
        let timedOut = judge0Response.status.id == 5

        // 종료 코드 결정
        let exitCode: Int32
        switch judge0Response.status.id {
        case 3: // Accepted
            exitCode = 0
        case 6: // Compilation Error
            exitCode = 1
        case 5: // Time Limit Exceeded
            exitCode = 124
        default: // Runtime errors and others
            exitCode = 1
        }

        // Base64 디코딩 헬퍼
        func decodeBase64(_ str: String?) -> String {
            guard let str = str, !str.isEmpty,
                  let data = Data(base64Encoded: str),
                  let decoded = String(data: data, encoding: .utf8) else {
                return ""
            }
            return decoded
        }

        // stderr 구성 (컴파일 에러 포함)
        var stderr = decodeBase64(judge0Response.stderr)
        let compileOutput = decodeBase64(judge0Response.compileOutput)
        if !compileOutput.isEmpty {
            stderr = compileOutput + (stderr.isEmpty ? "" : "\n" + stderr)
        }
        let message = decodeBase64(judge0Response.message)
        if !message.isEmpty {
            stderr = message + (stderr.isEmpty ? "" : "\n" + stderr)
        }

        return ExecutionResult(
            stdout: decodeBase64(judge0Response.stdout),
            stderr: stderr,
            exitCode: exitCode,
            timedOut: timedOut,
            executionTime: executionTime
        )
    }
}
