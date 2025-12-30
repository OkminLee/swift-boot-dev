import Fluent
import Vapor

/// 사용자 인벤토리 모델
final class UserInventory: Model, Content, @unchecked Sendable {
    static let schema = "user_inventory"

    @ID(key: .id)
    var id: UUID?

    @Parent(key: "user_id")
    var user: User

    @Parent(key: "item_id")
    var item: ShopItem

    @Field(key: "quantity")
    var quantity: Int

    @Timestamp(key: "acquired_at", on: .create)
    var acquiredAt: Date?

    @Timestamp(key: "updated_at", on: .update)
    var updatedAt: Date?

    init() {}

    init(
        id: UUID? = nil,
        userId: UUID,
        itemId: UUID,
        quantity: Int = 1
    ) {
        self.id = id
        self.$user.id = userId
        self.$item.id = itemId
        self.quantity = quantity
    }
}
