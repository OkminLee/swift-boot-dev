import Fluent

struct CreateChest: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema("chests")
            .id()
            .field("name", .string, .required)
            .field("description", .string, .required)
            .field("rarity", .string, .required)
            .field("icon_url", .string, .required, .sql(.default("")))
            .field("is_active", .bool, .required, .sql(.default(true)))
            .field("created_at", .datetime)
            .field("updated_at", .datetime)
            .create()
    }

    func revert(on database: Database) async throws {
        try await database.schema("chests").delete()
    }
}
