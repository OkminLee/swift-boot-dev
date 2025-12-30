import Fluent

struct SeedShopItems: AsyncMigration {
    func prepare(on database: Database) async throws {
        // Seer Stone - 정답 보기 아이템
        let seerStone = ShopItem(
            name: "Seer Stone",
            description: "정답 코드를 확인할 수 있습니다. 막혔을 때 사용하세요!",
            itemType: .seerStone,
            price: 50,
            icon: "🔮",
            isActive: true,
            sortOrder: 1
        )
        try await seerStone.save(on: database)
    }

    func revert(on database: Database) async throws {
        try await ShopItem.query(on: database)
            .filter(\.$itemType == .seerStone)
            .delete()
    }
}
