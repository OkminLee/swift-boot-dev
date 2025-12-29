import Fluent
import Vapor

struct LessonController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let lessons = routes.grouped("lessons")

        lessons.get(":lessonId", use: getLesson)
        lessons.post(":lessonId", "submit", use: submitLesson)
    }

    /// 레슨 상세 (학습 콘텐츠 포함)
    @Sendable
    func getLesson(req: Request) async throws -> LessonDetailResponse {
        guard let lessonId = req.parameters.get("lessonId", as: UUID.self) else {
            throw Abort(.badRequest)
        }

        guard let lesson = try await Lesson.query(on: req.db)
            .filter(\.$id == lessonId)
            .first() else {
            throw Abort(.notFound)
        }

        return LessonDetailResponse(from: lesson)
    }

    /// 코드 제출
    @Sendable
    func submitLesson(req: Request) async throws -> SubmissionResponse {
        guard let lessonId = req.parameters.get("lessonId", as: UUID.self) else {
            throw Abort(.badRequest)
        }

        let submission = try req.content.decode(CodeSubmission.self)

        // TODO: 코드 실행 Job Queue에 추가
        // 1. Redis Queue에 CodeExecutionJob 추가
        // 2. Worker가 Docker 컨테이너에서 코드 실행
        // 3. WebSocket으로 결과 스트리밍

        return SubmissionResponse(
            lessonId: lessonId,
            status: .pending,
            message: "Code execution queued"
        )
    }
}

// MARK: - DTOs
struct LessonDetailResponse: Content {
    let id: UUID
    let title: String
    let content: String
    let type: LessonType
    let language: ProgrammingLanguage?
    let starterCode: String?
    let xpReward: Int

    init(from lesson: Lesson) {
        self.id = lesson.id!
        self.title = lesson.title
        self.content = lesson.content
        self.type = lesson.type
        self.language = lesson.language
        self.starterCode = lesson.starterCode
        self.xpReward = lesson.xpReward
    }
}

struct CodeSubmission: Content {
    let code: String
    let language: ProgrammingLanguage
}

struct SubmissionResponse: Content {
    let lessonId: UUID
    let status: SubmissionStatus
    let message: String
    let output: String?
    let isCorrect: Bool?
    let xpEarned: Int?

    init(
        lessonId: UUID,
        status: SubmissionStatus,
        message: String,
        output: String? = nil,
        isCorrect: Bool? = nil,
        xpEarned: Int? = nil
    ) {
        self.lessonId = lessonId
        self.status = status
        self.message = message
        self.output = output
        self.isCorrect = isCorrect
        self.xpEarned = xpEarned
    }
}

enum SubmissionStatus: String, Codable {
    case pending
    case running
    case success
    case failure
    case error
}
