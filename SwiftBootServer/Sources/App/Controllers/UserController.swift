import Fluent
import Vapor

struct UserController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let users = routes.grouped("users")

        // 인증 필요 라우트
        let protected = users.grouped(JWTAuthMiddleware())
        protected.get("me", use: getCurrentUser)
        protected.patch("me", use: updateCurrentUser)
        protected.get("me", "stats", use: getUserStats)
        protected.get("me", "progress", use: getUserProgress)
    }

    /// 현재 사용자 조회
    @Sendable
    func getCurrentUser(req: Request) async throws -> UserResponse {
        let user = try await req.authenticatedUser()
        return UserResponse(from: user)
    }

    /// 현재 사용자 정보 수정
    @Sendable
    func updateCurrentUser(req: Request) async throws -> UserResponse {
        let user = try await req.authenticatedUser()
        let updateRequest = try req.content.decode(UpdateUserRequest.self)

        // 수정 가능한 필드만 업데이트
        if let username = updateRequest.username {
            user.username = username
        }

        try await user.save(on: req.db)
        return UserResponse(from: user)
    }

    /// 사용자 통계 (레벨, XP, Gems 등)
    @Sendable
    func getUserStats(req: Request) async throws -> UserStatsResponse {
        let user = try await req.authenticatedUser()
        let userId = try req.requireAuthenticatedUserId()

        // 완료한 레슨 수 조회
        let completedLessons = try await UserProgress.query(on: req.db)
            .filter(\.$user.$id == userId)
            .filter(\.$status == .completed)
            .count()

        // 전체 레슨 수 조회
        let totalLessons = try await Lesson.query(on: req.db).count()

        return UserStatsResponse(
            level: user.level,
            totalXp: user.totalXp,
            xpToNextLevel: user.xpToNextLevel,
            levelProgress: user.levelProgress,
            gems: user.gems,
            streakDays: user.streakDays,
            completedLessons: completedLessons,
            totalLessons: totalLessons
        )
    }

    /// 사용자 학습 진행 상황
    @Sendable
    func getUserProgress(req: Request) async throws -> [ProgressResponse] {
        let userId = try req.requireAuthenticatedUserId()

        let progress = try await UserProgress.query(on: req.db)
            .filter(\.$user.$id == userId)
            .all()

        return progress.map { ProgressResponse(from: $0) }
    }
}

// MARK: - DTOs

struct UserResponse: Content {
    let id: UUID
    let username: String
    let email: String
    let avatarUrl: String?
    let level: Int
    let totalXp: Int
    let gems: Int
    let streakDays: Int

    init(from user: User) {
        self.id = user.id!
        self.username = user.username
        self.email = user.email
        self.avatarUrl = user.avatarUrl
        self.level = user.level
        self.totalXp = user.totalXp
        self.gems = user.gems
        self.streakDays = user.streakDays
    }
}

struct UpdateUserRequest: Content {
    let username: String?
}

struct UserStatsResponse: Content {
    let level: Int
    let totalXp: Int
    let xpToNextLevel: Int
    let levelProgress: Double
    let gems: Int
    let streakDays: Int
    let completedLessons: Int
    let totalLessons: Int
}

struct ProgressResponse: Content {
    let lessonId: UUID
    let status: ProgressStatus
    let completedAt: Date?
    let xpEarned: Int

    init(from progress: UserProgress) {
        self.lessonId = progress.$lesson.id
        self.status = progress.status
        self.completedAt = progress.completedAt
        self.xpEarned = progress.xpEarned
    }
}
