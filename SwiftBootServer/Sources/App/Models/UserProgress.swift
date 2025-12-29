import Fluent
import Vapor

/// 진행 상태
enum ProgressStatus: String, Codable {
    case notStarted
    case inProgress
    case completed
}

/// 사용자 학습 진행 상황
final class UserProgress: Model, Content, @unchecked Sendable {
    static let schema = "user_progress"

    @ID(key: .id)
    var id: UUID?

    @Parent(key: "user_id")
    var user: User

    @Parent(key: "lesson_id")
    var lesson: Lesson

    @Field(key: "status")
    var status: ProgressStatus

    @Field(key: "submitted_code")
    var submittedCode: String?

    @Field(key: "attempts")
    var attempts: Int

    @Field(key: "xp_earned")
    var xpEarned: Int

    @Timestamp(key: "started_at", on: .none)
    var startedAt: Date?

    @Timestamp(key: "completed_at", on: .none)
    var completedAt: Date?

    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?

    @Timestamp(key: "updated_at", on: .update)
    var updatedAt: Date?

    init() {}

    init(
        id: UUID? = nil,
        userId: UUID,
        lessonId: UUID,
        status: ProgressStatus = .notStarted,
        submittedCode: String? = nil,
        attempts: Int = 0,
        xpEarned: Int = 0
    ) {
        self.id = id
        self.$user.id = userId
        self.$lesson.id = lessonId
        self.status = status
        self.submittedCode = submittedCode
        self.attempts = attempts
        self.xpEarned = xpEarned
    }
}
