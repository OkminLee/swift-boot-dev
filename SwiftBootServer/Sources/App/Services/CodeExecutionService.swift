import Fluent
import Vapor

/// 코드 실행 에러
enum CodeExecutionError: Error, AbortError {
    case unsupportedLanguage
    case codeTooLong
    case dockerNotAvailable
    case executionFailed(String)

    var status: HTTPResponseStatus {
        switch self {
        case .unsupportedLanguage, .codeTooLong:
            return .badRequest
        case .dockerNotAvailable, .executionFailed:
            return .internalServerError
        }
    }

    var reason: String {
        switch self {
        case .unsupportedLanguage:
            return "지원하지 않는 프로그래밍 언어입니다."
        case .codeTooLong:
            return "코드가 너무 깁니다. (최대 10,000자)"
        case .dockerNotAvailable:
            return "코드 실행 환경을 사용할 수 없습니다."
        case .executionFailed(let message):
            return "코드 실행 실패: \(message)"
        }
    }
}

/// 코드 실행 서비스
struct CodeExecutionService {
    private let dockerRunner = DockerRunner()
    private let maxCodeLength = 10_000

    /// 코드 실행 및 결과 평가
    func execute(
        submission: CodeSubmission,
        lesson: Lesson,
        userId: UUID,
        db: Database
    ) async throws -> SubmissionResponse {
        guard let lessonId = lesson.id else {
            throw Abort(.internalServerError, reason: "Lesson ID not found")
        }

        // 1. 입력 검증
        guard submission.code.count <= maxCodeLength else {
            return SubmissionResponse(
                lessonId: lessonId,
                status: .failure,
                message: "코드가 너무 깁니다. (최대 10,000자)"
            )
        }

        // 2. 언어 설정 조회
        guard let config = LanguageConfig.config(for: submission.language) else {
            return SubmissionResponse(
                lessonId: lessonId,
                status: .failure,
                message: "지원하지 않는 프로그래밍 언어입니다."
            )
        }

        // 3. 코드 실행
        let result: DockerRunner.ExecutionResult
        do {
            result = try await dockerRunner.execute(code: submission.code, config: config)
        } catch {
            return SubmissionResponse(
                lessonId: lessonId,
                status: .error,
                message: "코드 실행 중 오류가 발생했습니다: \(error.localizedDescription)"
            )
        }

        // 4. 타임아웃 처리
        if result.timedOut {
            return SubmissionResponse(
                lessonId: lessonId,
                status: .failure,
                message: "실행 시간 초과 (5초)",
                output: result.stderr.isEmpty ? nil : result.stderr
            )
        }

        // 5. 컴파일/런타임 에러 처리
        if result.exitCode != 0 {
            let errorOutput = result.stderr.isEmpty ? result.stdout : result.stderr
            return SubmissionResponse(
                lessonId: lessonId,
                status: .failure,
                message: "코드 실행 중 오류가 발생했습니다.",
                output: String(errorOutput.prefix(2000)) // 출력 길이 제한
            )
        }

        // 6. 결과 평가
        let isCorrect = evaluateResult(
            output: result.stdout,
            expectedOutput: lesson.expectedOutput
        )

        // 7. 정답인 경우 진행 상황 업데이트
        var xpEarned: Int? = nil
        if isCorrect {
            xpEarned = try await updateProgress(
                userId: userId,
                lesson: lesson,
                code: submission.code,
                db: db
            )
        }

        return SubmissionResponse(
            lessonId: lessonId,
            status: isCorrect ? .success : .failure,
            message: isCorrect ? "정답입니다!" : "출력이 예상과 다릅니다.",
            output: String(result.stdout.prefix(2000)),
            isCorrect: isCorrect,
            xpEarned: xpEarned
        )
    }

    // MARK: - Private Helpers

    /// 출력 비교 (공백/줄바꿈 정규화)
    private func evaluateResult(output: String, expectedOutput: String?) -> Bool {
        guard let expected = expectedOutput else {
            // expectedOutput이 없으면 실행만 성공하면 정답
            return true
        }

        let normalizedOutput = normalizeOutput(output)
        let normalizedExpected = normalizeOutput(expected)

        return normalizedOutput == normalizedExpected
    }

    /// 출력 정규화 (앞뒤 공백 제거, 줄 끝 공백 제거)
    private func normalizeOutput(_ output: String) -> String {
        output
            .split(separator: "\n", omittingEmptySubsequences: false)
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .joined(separator: "\n")
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }

    /// 진행 상황 업데이트 및 XP 지급
    private func updateProgress(
        userId: UUID,
        lesson: Lesson,
        code: String,
        db: Database
    ) async throws -> Int {
        guard let lessonId = lesson.id else { return 0 }

        // 이미 완료한 레슨인지 확인
        let existingProgress = try await UserProgress.query(on: db)
            .filter(\.$user.$id == userId)
            .filter(\.$lesson.$id == lessonId)
            .filter(\.$status == .completed)
            .first()

        // 이미 완료했으면 XP 중복 지급 안함
        if existingProgress != nil {
            return 0
        }

        // 진행 상황 저장/업데이트
        if let progress = try await UserProgress.query(on: db)
            .filter(\.$user.$id == userId)
            .filter(\.$lesson.$id == lessonId)
            .first()
        {
            progress.status = .completed
            progress.submittedCode = code
            progress.completedAt = Date()
            try await progress.save(on: db)
        } else {
            let newProgress = UserProgress(
                userId: userId,
                lessonId: lessonId,
                status: .completed,
                submittedCode: code
            )
            try await newProgress.save(on: db)
        }

        // 사용자 XP 및 Gems 업데이트
        guard let user = try await User.find(userId, on: db) else {
            return 0
        }

        let xpEarned = lesson.xpReward
        _ = user.addXp(xpEarned)

        // 첫 레슨 완료 시 Gems 지급 (5💎)
        let gemsReward = 5
        user.gems += gemsReward

        try await user.save(on: db)

        return xpEarned
    }
}
