import Fluent
import Vapor

/// Chest 등급
enum ChestRarity: String, Codable, CaseIterable {
    case common = "common"
    case rare = "rare"
    case epic = "epic"
    case legendary = "legendary"

    /// 등급별 보상 범위
    var gemsRange: ClosedRange<Int> {
        switch self {
        case .common: return 1...5
        case .rare: return 5...15
        case .epic: return 15...30
        case .legendary: return 30...100
        }
    }

    var xpRange: ClosedRange<Int> {
        switch self {
        case .common: return 10...30
        case .rare: return 30...60
        case .epic: return 60...120
        case .legendary: return 120...300
        }
    }

    /// 등급별 아이템 드롭 확률 (0.0 ~ 1.0)
    var itemDropChance: Double {
        switch self {
        case .common: return 0.1
        case .rare: return 0.25
        case .epic: return 0.5
        case .legendary: return 0.8
        }
    }

    /// 등급별 표시 이름
    var displayName: String {
        switch self {
        case .common: return "Common Chest"
        case .rare: return "Rare Chest"
        case .epic: return "Epic Chest"
        case .legendary: return "Legendary Chest"
        }
    }

    /// 등급별 아이콘 이모지
    var icon: String {
        switch self {
        case .common: return "📦"
        case .rare: return "🎁"
        case .epic: return "💎"
        case .legendary: return "👑"
        }
    }
}

/// Chest 정의 모델 (어떤 종류의 chest가 있는지)
final class Chest: Model, Content, @unchecked Sendable {
    static let schema = "chests"

    @ID(key: .id)
    var id: UUID?

    @Field(key: "name")
    var name: String

    @Field(key: "description")
    var description: String

    @Enum(key: "rarity")
    var rarity: ChestRarity

    @Field(key: "icon_url")
    var iconUrl: String

    @Field(key: "is_active")
    var isActive: Bool

    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?

    @Timestamp(key: "updated_at", on: .update)
    var updatedAt: Date?

    init() {}

    init(
        id: UUID? = nil,
        name: String,
        description: String,
        rarity: ChestRarity,
        iconUrl: String = "",
        isActive: Bool = true
    ) {
        self.id = id
        self.name = name
        self.description = description
        self.rarity = rarity
        self.iconUrl = iconUrl
        self.isActive = isActive
    }
}

/// Chest 개봉 시 보상 결과
struct ChestReward: Content {
    let gems: Int
    let xp: Int
    let items: [RewardItem]

    struct RewardItem: Content {
        let itemId: UUID
        let itemName: String
        let quantity: Int
    }
}
