import Fluent

struct CreateUserChest: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema("user_chests")
            .id()
            .field("user_id", .uuid, .required, .references("users", "id", onDelete: .cascade))
            .field("chest_id", .uuid, .required, .references("chests", "id", onDelete: .cascade))
            .field("source", .string, .required)
            .field("source_lesson_id", .uuid)
            .field("is_opened", .bool, .required, .sql(.default(false)))
            .field("opened_at", .datetime)
            .field("acquired_at", .datetime)
            .create()
    }

    func revert(on database: Database) async throws {
        try await database.schema("user_chests").delete()
    }
}
