import Fluent

struct CreateLesson: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema("lessons")
            .id()
            .field("chapter_id", .uuid, .required, .references("chapters", "id", onDelete: .cascade))
            .field("title", .string, .required)
            .field("content", .string, .required)  // MDX 콘텐츠
            .field("type", .string, .required)
            .field("language", .string)
            .field("starter_code", .string)
            .field("solution_code", .string)
            .field("test_code", .string)
            .field("expected_output", .string)
            .field("xp_reward", .int, .required, .sql(.default(10)))
            .field("order", .int, .required, .sql(.default(0)))
            .field("created_at", .datetime)
            .field("updated_at", .datetime)
            .create()
    }

    func revert(on database: Database) async throws {
        try await database.schema("lessons").delete()
    }
}
