import Fluent

struct CreateUser: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema("users")
            .id()
            .field("username", .string, .required)
            .field("email", .string, .required)
            .field("github_id", .string)
            .field("avatar_url", .string)
            .field("total_xp", .int, .required, .sql(.default(0)))
            .field("level", .int, .required, .sql(.default(1)))
            .field("gems", .int, .required, .sql(.default(0)))
            .field("streak_days", .int, .required, .sql(.default(0)))
            .field("last_activity_at", .datetime)
            .field("created_at", .datetime)
            .field("updated_at", .datetime)
            .unique(on: "email")
            .unique(on: "github_id")
            .create()
    }

    func revert(on database: Database) async throws {
        try await database.schema("users").delete()
    }
}
