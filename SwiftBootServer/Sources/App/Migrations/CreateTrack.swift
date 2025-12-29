import Fluent

struct CreateTrack: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema("tracks")
            .id()
            .field("title", .string, .required)
            .field("description", .string, .required)
            .field("icon", .string)
            .field("order", .int, .required, .sql(.default(0)))
            .field("is_published", .bool, .required, .sql(.default(false)))
            .field("created_at", .datetime)
            .create()
    }

    func revert(on database: Database) async throws {
        try await database.schema("tracks").delete()
    }
}
