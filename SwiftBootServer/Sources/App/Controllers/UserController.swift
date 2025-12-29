import Fluent
import Vapor

struct UserController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let users = routes.grouped("users")

        // 인증 필요 라우트
        // let protected = users.grouped(JWTAuthMiddleware())
        users.get("me", use: getCurrentUser)
        users.patch("me", use: updateCurrentUser)
        users.get("me", "stats", use: getUserStats)
        users.get("me", "progress", use: getUserProgress)
    }

    /// 현재 사용자 조회
    @Sendable
    func getCurrentUser(req: Request) async throws -> UserResponse {
        // TODO: JWT에서 사용자 ID 추출
        throw Abort(.notImplemented, reason: "Authentication required")
    }

    /// 현재 사용자 정보 수정
    @Sendable
    func updateCurrentUser(req: Request) async throws -> UserResponse {
        throw Abort(.notImplemented, reason: "Authentication required")
    }

    /// 사용자 통계 (레벨, XP, Gems 등)
    @Sendable
    func getUserStats(req: Request) async throws -> UserStatsResponse {
        throw Abort(.notImplemented, reason: "Authentication required")
    }

    /// 사용자 학습 진행 상황
    @Sendable
    func getUserProgress(req: Request) async throws -> [ProgressResponse] {
        throw Abort(.notImplemented, reason: "Authentication required")
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
}
