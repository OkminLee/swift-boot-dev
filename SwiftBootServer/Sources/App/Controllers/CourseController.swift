import Fluent
import Vapor

struct CourseController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let courses = routes.grouped("courses")

        courses.get(use: getAllCourses)
        courses.get(":courseId", use: getCourse)
        courses.get(":courseId", "chapters", use: getCourseChapters)
    }

    /// 모든 코스 목록
    @Sendable
    func getAllCourses(req: Request) async throws -> [CourseResponse] {
        let courses = try await Course.query(on: req.db)
            .filter(\.$isPublished == true)
            .sort(\.$order)
            .all()

        return courses.map { CourseResponse(from: $0) }
    }

    /// 특정 코스 상세
    @Sendable
    func getCourse(req: Request) async throws -> CourseDetailResponse {
        guard let courseId = req.parameters.get("courseId", as: UUID.self) else {
            throw Abort(.badRequest)
        }

        guard let course = try await Course.query(on: req.db)
            .filter(\.$id == courseId)
            .filter(\.$isPublished == true)
            .with(\.$chapters)
            .first() else {
            throw Abort(.notFound)
        }

        // 각 챕터의 레슨을 별도로 로드
        for chapter in course.chapters {
            try await chapter.$lessons.load(on: req.db)
        }

        return CourseDetailResponse(from: course)
    }

    /// 코스의 챕터 목록
    @Sendable
    func getCourseChapters(req: Request) async throws -> [ChapterResponse] {
        guard let courseId = req.parameters.get("courseId", as: UUID.self) else {
            throw Abort(.badRequest)
        }

        let chapters = try await Chapter.query(on: req.db)
            .filter(\.$course.$id == courseId)
            .sort(\.$order)
            .with(\.$lessons)
            .all()

        return chapters.map { ChapterResponse(from: $0) }
    }
}

// MARK: - DTOs
struct CourseResponse: Content {
    let id: UUID
    let title: String
    let description: String
    let icon: String?
    let difficulty: CourseDifficulty

    init(from course: Course) {
        self.id = course.id!
        self.title = course.title
        self.description = course.description
        self.icon = course.icon
        self.difficulty = course.difficulty
    }
}

struct CourseDetailResponse: Content {
    let id: UUID
    let title: String
    let description: String
    let icon: String?
    let difficulty: CourseDifficulty
    let chapters: [ChapterResponse]

    init(from course: Course) {
        self.id = course.id!
        self.title = course.title
        self.description = course.description
        self.icon = course.icon
        self.difficulty = course.difficulty
        self.chapters = course.chapters.map { ChapterResponse(from: $0) }
    }
}

struct ChapterResponse: Content {
    let id: UUID
    let title: String
    let description: String?
    let lessons: [LessonSummaryResponse]

    init(from chapter: Chapter) {
        self.id = chapter.id!
        self.title = chapter.title
        self.description = chapter.description
        self.lessons = chapter.lessons.map { LessonSummaryResponse(from: $0) }
    }
}

struct LessonSummaryResponse: Content {
    let id: UUID
    let title: String
    let type: LessonType
    let xpReward: Int

    init(from lesson: Lesson) {
        self.id = lesson.id!
        self.title = lesson.title
        self.type = lesson.type
        self.xpReward = lesson.xpReward
    }
}
