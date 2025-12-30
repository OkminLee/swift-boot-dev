import Fluent

struct CreateShopItem: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema("shop_items")
            .id()
            .field("name", .string, .required)
            .field("description", .string, .required)
            .field("item_type", .string, .required)
            .field("price", .int, .required)
            .field("icon", .string, .required)
            .field("is_active", .bool, .required, .sql(.default(true)))
            .field("sort_order", .int, .required, .sql(.default(0)))
            .field("created_at", .datetime)
            .field("updated_at", .datetime)
            .create()
    }

    func revert(on database: Database) async throws {
        try await database.schema("shop_items").delete()
    }
}
