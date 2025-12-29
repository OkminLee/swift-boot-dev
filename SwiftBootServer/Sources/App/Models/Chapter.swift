import Fluent
import Vapor

/// 챕터 (코스의 섹션)
final class Chapter: Model, Content, @unchecked Sendable {
    static let schema = "chapters"

    @ID(key: .id)
    var id: UUID?

    @Parent(key: "course_id")
    var course: Course

    @Field(key: "title")
    var title: String

    @Field(key: "description")
    var description: String?

    @Field(key: "order")
    var order: Int

    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?

    @Children(for: \.$chapter)
    var lessons: [Lesson]

    init() {}

    init(
        id: UUID? = nil,
        courseId: UUID,
        title: String,
        description: String? = nil,
        order: Int = 0
    ) {
        self.id = id
        self.$course.id = courseId
        self.title = title
        self.description = description
        self.order = order
    }
}
