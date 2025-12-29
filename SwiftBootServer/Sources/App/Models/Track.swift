import Fluent
import Vapor

/// 학습 트랙 (예: "Backend Developer", "iOS Developer")
final class Track: Model, Content, @unchecked Sendable {
    static let schema = "tracks"

    @ID(key: .id)
    var id: UUID?

    @Field(key: "title")
    var title: String

    @Field(key: "description")
    var description: String

    @Field(key: "icon")
    var icon: String?

    @Field(key: "order")
    var order: Int

    @Field(key: "is_published")
    var isPublished: Bool

    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?

    @Children(for: \.$track)
    var courses: [Course]

    init() {}

    init(
        id: UUID? = nil,
        title: String,
        description: String,
        icon: String? = nil,
        order: Int = 0,
        isPublished: Bool = false
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.icon = icon
        self.order = order
        self.isPublished = isPublished
    }
}
