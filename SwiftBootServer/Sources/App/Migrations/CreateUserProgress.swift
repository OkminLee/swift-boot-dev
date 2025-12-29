import Fluent

struct CreateUserProgress: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema("user_progress")
            .id()
            .field("user_id", .uuid, .required, .references("users", "id", onDelete: .cascade))
            .field("lesson_id", .uuid, .required, .references("lessons", "id", onDelete: .cascade))
            .field("status", .string, .required, .sql(.default("notStarted")))
            .field("submitted_code", .string)
            .field("attempts", .int, .required, .sql(.default(0)))
            .field("xp_earned", .int, .required, .sql(.default(0)))
            .field("started_at", .datetime)
            .field("completed_at", .datetime)
            .field("created_at", .datetime)
            .field("updated_at", .datetime)
            .unique(on: "user_id", "lesson_id")
            .create()
    }

    func revert(on database: Database) async throws {
        try await database.schema("user_progress").delete()
    }
}
