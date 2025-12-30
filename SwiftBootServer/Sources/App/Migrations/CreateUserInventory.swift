import Fluent

struct CreateUserInventory: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema("user_inventory")
            .id()
            .field("user_id", .uuid, .required, .references("users", "id", onDelete: .cascade))
            .field("item_id", .uuid, .required, .references("shop_items", "id", onDelete: .cascade))
            .field("quantity", .int, .required, .sql(.default(1)))
            .field("acquired_at", .datetime)
            .field("updated_at", .datetime)
            .unique(on: "user_id", "item_id")
            .create()
    }

    func revert(on database: Database) async throws {
        try await database.schema("user_inventory").delete()
    }
}
