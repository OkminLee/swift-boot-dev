import Fluent

struct CreateChapter: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema("chapters")
            .id()
            .field("course_id", .uuid, .required, .references("courses", "id", onDelete: .cascade))
            .field("title", .string, .required)
            .field("description", .string)
            .field("order", .int, .required, .sql(.default(0)))
            .field("created_at", .datetime)
            .create()
    }

    func revert(on database: Database) async throws {
        try await database.schema("chapters").delete()
    }
}
