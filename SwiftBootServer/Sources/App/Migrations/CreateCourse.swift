import Fluent

struct CreateCourse: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema("courses")
            .id()
            .field("track_id", .uuid, .required, .references("tracks", "id", onDelete: .cascade))
            .field("title", .string, .required)
            .field("description", .string, .required)
            .field("icon", .string)
            .field("difficulty", .string, .required, .sql(.default("beginner")))
            .field("order", .int, .required, .sql(.default(0)))
            .field("is_published", .bool, .required, .sql(.default(false)))
            .field("prerequisite_id", .uuid, .references("courses", "id", onDelete: .setNull))
            .field("created_at", .datetime)
            .create()
    }

    func revert(on database: Database) async throws {
        try await database.schema("courses").delete()
    }
}
