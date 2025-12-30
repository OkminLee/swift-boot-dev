import Fluent
import Vapor

struct LessonController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let lessons = routes.grouped("lessons")

        // 레슨 조회는 인증 불필요
        lessons.get(":lessonId", use: getLesson)

        // 코드 제출은 인증 + 엄격한 Rate Limit 적용
        let protected = lessons
            .grouped(JWTAuthMiddleware())
            .grouped(RateLimitMiddleware(config: .codeExecution))
        protected.post(":lessonId", "submit", use: submitLesson)
    }

    /// 레슨 상세 (학습 콘텐츠 포함)
    @Sendable
    func getLesson(req: Request) async throws -> LessonDetailResponse {
        guard let lessonId = req.parameters.get("lessonId", as: UUID.self) else {
            throw Abort(.badRequest)
        }

        // 레슨과 챕터 정보 함께 로드
        guard let lesson = try await Lesson.query(on: req.db)
            .filter(\.$id == lessonId)
            .with(\.$chapter) { chapter in
                chapter.with(\.$course)
            }
            .first() else {
            throw Abort(.notFound)
        }

        let chapter = lesson.chapter
        let courseId = chapter.$course.id

        // 같은 코스의 모든 챕터와 레슨 조회 (순서대로)
        let allChapters = try await Chapter.query(on: req.db)
            .filter(\.$course.$id == courseId)
            .with(\.$lessons)
            .sort(\.$order)
            .all()

        // 모든 레슨을 순서대로 평탄화
        var allLessons: [(chapterId: UUID, lessonId: UUID, order: Int, chapterOrder: Int)] = []
        for ch in allChapters {
            let sortedLessons = ch.lessons.sorted { $0.order < $1.order }
            for l in sortedLessons {
                allLessons.append((ch.id!, l.id!, l.order, ch.order))
            }
        }

        // 현재 레슨 인덱스 찾기
        let currentIndex = allLessons.firstIndex { $0.lessonId == lessonId }

        var previousLessonId: UUID? = nil
        var nextLessonId: UUID? = nil

        if let idx = currentIndex {
            if idx > 0 {
                previousLessonId = allLessons[idx - 1].lessonId
            }
            if idx < allLessons.count - 1 {
                nextLessonId = allLessons[idx + 1].lessonId
            }
        }

        return LessonDetailResponse(
            from: lesson,
            courseId: courseId,
            chapterId: chapter.id!,
            previousLessonId: previousLessonId,
            nextLessonId: nextLessonId
        )
    }

    /// 코드 제출
    @Sendable
    func submitLesson(req: Request) async throws -> SubmissionResponse {
        guard let lessonId = req.parameters.get("lessonId", as: UUID.self) else {
            throw Abort(.badRequest)
        }

        // 인증된 사용자 확인
        let userId = try req.requireAuthenticatedUserId()

        // 레슨 조회
        guard let lesson = try await Lesson.find(lessonId, on: req.db) else {
            throw Abort(.notFound, reason: "레슨을 찾을 수 없습니다.")
        }

        // 코드 레슨인지 확인
        guard lesson.type == .codeExercise || lesson.type == .codeOutput else {
            throw Abort(.badRequest, reason: "코드 제출이 불가능한 레슨입니다.")
        }

        let submission = try req.content.decode(CodeSubmission.self)

        // 코드 실행 서비스 호출
        let executionService = CodeExecutionService()
        let result = try await executionService.execute(
            submission: submission,
            lesson: lesson,
            userId: userId,
            db: req.db
        )

        return result
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
    let courseId: UUID
    let chapterId: UUID
    let previousLessonId: UUID?
    let nextLessonId: UUID?

    init(
        from lesson: Lesson,
        courseId: UUID,
        chapterId: UUID,
        previousLessonId: UUID?,
        nextLessonId: UUID?
    ) {
        self.id = lesson.id!
        self.title = lesson.title
        self.content = lesson.content
        self.type = lesson.type
        self.language = lesson.language
        self.starterCode = lesson.starterCode
        self.xpReward = lesson.xpReward
        self.courseId = courseId
        self.chapterId = chapterId
        self.previousLessonId = previousLessonId
        self.nextLessonId = nextLessonId
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
