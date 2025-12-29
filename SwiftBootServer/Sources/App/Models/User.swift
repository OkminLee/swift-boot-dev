import Fluent
import Vapor

/// 사용자 모델
final class User: Model, Content, @unchecked Sendable {
    static let schema = "users"

    @ID(key: .id)
    var id: UUID?

    @Field(key: "username")
    var username: String

    @Field(key: "email")
    var email: String

    @Field(key: "github_id")
    var githubId: String?

    @Field(key: "avatar_url")
    var avatarUrl: String?

    // 게이미피케이션
    @Field(key: "total_xp")
    var totalXp: Int

    @Field(key: "level")
    var level: Int

    @Field(key: "gems")
    var gems: Int

    @Field(key: "streak_days")
    var streakDays: Int

    @Field(key: "last_activity_at")
    var lastActivityAt: Date?

    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?

    @Timestamp(key: "updated_at", on: .update)
    var updatedAt: Date?

    // 관계
    @Children(for: \.$user)
    var progress: [UserProgress]

    init() {}

    init(
        id: UUID? = nil,
        username: String,
        email: String,
        githubId: String? = nil,
        avatarUrl: String? = nil,
        totalXp: Int = 0,
        level: Int = 1,
        gems: Int = 0,
        streakDays: Int = 0
    ) {
        self.id = id
        self.username = username
        self.email = email
        self.githubId = githubId
        self.avatarUrl = avatarUrl
        self.totalXp = totalXp
        self.level = level
        self.gems = gems
        self.streakDays = streakDays
    }
}

// MARK: - XP/Level 계산
extension User {
    /// XP 필요량 공식: 100 × Level^1.5
    static func xpRequiredForLevel(_ level: Int) -> Int {
        Int(100.0 * pow(Double(level), 1.5))
    }

    /// 현재 레벨에서 다음 레벨까지 필요한 XP
    var xpToNextLevel: Int {
        Self.xpRequiredForLevel(level)
    }

    /// 현재 레벨 진행률 (0.0 ~ 1.0)
    var levelProgress: Double {
        let previousLevelXp = level > 1 ? Self.xpRequiredForLevel(level - 1) : 0
        let currentLevelXp = Self.xpRequiredForLevel(level)
        let xpInCurrentLevel = totalXp - previousLevelXp
        return Double(xpInCurrentLevel) / Double(currentLevelXp - previousLevelXp)
    }

    /// XP 추가 및 레벨업 체크
    func addXp(_ amount: Int) -> Bool {
        totalXp += amount
        var leveledUp = false

        while totalXp >= Self.xpRequiredForLevel(level) {
            level += 1
            leveledUp = true
        }

        return leveledUp
    }
}
