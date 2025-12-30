import Fluent
import Vapor

struct SeedChest: AsyncMigration {
    func prepare(on database: Database) async throws {
        let chests: [Chest] = [
            Chest(
                name: "Common Chest",
                description: "기본 보상이 담긴 상자입니다.",
                rarity: .common,
                iconUrl: "📦"
            ),
            Chest(
                name: "Rare Chest",
                description: "더 좋은 보상이 담긴 희귀 상자입니다.",
                rarity: .rare,
                iconUrl: "🎁"
            ),
            Chest(
                name: "Epic Chest",
                description: "훌륭한 보상이 담긴 에픽 상자입니다!",
                rarity: .epic,
                iconUrl: "💎"
            ),
            Chest(
                name: "Legendary Chest",
                description: "최고의 보상이 담긴 전설 상자입니다!",
                rarity: .legendary,
                iconUrl: "👑"
            )
        ]

        for chest in chests {
            try await chest.save(on: database)
        }
    }

    func revert(on database: Database) async throws {
        try await Chest.query(on: database).delete()
    }
}
