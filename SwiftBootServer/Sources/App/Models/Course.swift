import Fluent
import Vapor

/// 코스 (예: "Swift 기초", "Vapor 입문")
final class Course: Model, Content, @unchecked Sendable {
    static let schema = "courses"

    @ID(key: .id)
    var id: UUID?

    @Parent(key: "track_id")
    var track: Track

    @Field(key: "title")
    var title: String

    @Field(key: "description")
    var description: String

    @Field(key: "icon")
    var icon: String?

    @Field(key: "difficulty")
    var difficulty: CourseDifficulty

    @Field(key: "order")
    var order: Int

    @Field(key: "is_published")
    var isPublished: Bool

    @OptionalParent(key: "prerequisite_id")
    var prerequisite: Course?

    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?

    @Children(for: \.$course)
    var chapters: [Chapter]

    init() {}

    init(
        id: UUID? = nil,
        trackId: UUID,
        title: String,
        description: String,
        icon: String? = nil,
        difficulty: CourseDifficulty = .beginner,
        order: Int = 0,
        isPublished: Bool = false,
        prerequisiteId: UUID? = nil
    ) {
        self.id = id
        self.$track.id = trackId
        self.title = title
        self.description = description
        self.icon = icon
        self.difficulty = difficulty
        self.order = order
        self.isPublished = isPublished
        self.$prerequisite.id = prerequisiteId
    }
}

enum CourseDifficulty: String, Codable {
    case beginner
    case intermediate
    case advanced
}
