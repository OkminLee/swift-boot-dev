import Fluent
import Vapor

/// 사용자가 보유한 Chest
final class UserChest: Model, Content, @unchecked Sendable {
    static let schema = "user_chests"

    @ID(key: .id)
    var id: UUID?

    @Parent(key: "user_id")
    var user: User

    @Parent(key: "chest_id")
    var chest: Chest

    /// 획득 경로 (lesson_complete, achievement, purchase 등)
    @Field(key: "source")
    var source: String

    /// 연관된 레슨 ID (레슨 완료로 획득한 경우)
    @OptionalField(key: "source_lesson_id")
    var sourceLessonId: UUID?

    /// 개봉 여부
    @Field(key: "is_opened")
    var isOpened: Bool

    /// 개봉 시간
    @OptionalField(key: "opened_at")
    var openedAt: Date?

    @Timestamp(key: "acquired_at", on: .create)
    var acquiredAt: Date?

    init() {}

    init(
        id: UUID? = nil,
        userId: UUID,
        chestId: UUID,
        source: String,
        sourceLessonId: UUID? = nil,
        isOpened: Bool = false,
        openedAt: Date? = nil
    ) {
        self.id = id
        self.$user.id = userId
        self.$chest.id = chestId
        self.source = source
        self.sourceLessonId = sourceLessonId
        self.isOpened = isOpened
        self.openedAt = openedAt
    }
}

/// Chest 획득 소스
enum ChestSource: String, Codable {
    case lessonComplete = "lesson_complete"
    case achievement = "achievement"
    case dailyReward = "daily_reward"
    case purchase = "purchase"
    case levelUp = "level_up"
}
