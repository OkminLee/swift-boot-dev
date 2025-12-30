import Fluent
import Vapor

/// 상점 아이템 유형
enum ShopItemType: String, Codable {
    case seerStone     // 정답 보기
    case xpPotion      // XP 부스터
    case cosmetic      // 코스메틱
}

/// 상점 아이템 모델
final class ShopItem: Model, Content, @unchecked Sendable {
    static let schema = "shop_items"

    @ID(key: .id)
    var id: UUID?

    @Field(key: "name")
    var name: String

    @Field(key: "description")
    var description: String

    @Field(key: "item_type")
    var itemType: ShopItemType

    @Field(key: "price")
    var price: Int

    @Field(key: "icon")
    var icon: String

    @Field(key: "is_active")
    var isActive: Bool

    @Field(key: "sort_order")
    var sortOrder: Int

    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?

    @Timestamp(key: "updated_at", on: .update)
    var updatedAt: Date?

    // 관계
    @Children(for: \.$item)
    var inventoryItems: [UserInventory]

    init() {}

    init(
        id: UUID? = nil,
        name: String,
        description: String,
        itemType: ShopItemType,
        price: Int,
        icon: String,
        isActive: Bool = true,
        sortOrder: Int = 0
    ) {
        self.id = id
        self.name = name
        self.description = description
        self.itemType = itemType
        self.price = price
        self.icon = icon
        self.isActive = isActive
        self.sortOrder = sortOrder
    }
}
