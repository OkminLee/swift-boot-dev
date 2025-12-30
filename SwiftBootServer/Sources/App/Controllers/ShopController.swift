import Fluent
import Vapor

struct ShopController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let shop = routes.grouped("shop")

        // 공개 라우트
        shop.get(use: getShopItems)

        // 인증 필요 라우트
        let protected = shop.grouped(JWTAuthMiddleware())
        protected.post("purchase", ":itemId", use: purchaseItem)
    }

    /// 상점 아이템 목록 조회
    @Sendable
    func getShopItems(req: Request) async throws -> [ShopItemResponse] {
        let items = try await ShopItem.query(on: req.db)
            .filter(\.$isActive == true)
            .sort(\.$sortOrder)
            .all()

        return items.map { ShopItemResponse(from: $0) }
    }

    /// 아이템 구매
    @Sendable
    func purchaseItem(req: Request) async throws -> PurchaseResponse {
        guard let itemIdString = req.parameters.get("itemId"),
              let itemId = UUID(uuidString: itemIdString) else {
            throw Abort(.badRequest, reason: "유효하지 않은 아이템 ID입니다.")
        }

        let user = try await req.authenticatedUser()
        let userId = try req.requireAuthenticatedUserId()

        // 아이템 조회
        guard let item = try await ShopItem.find(itemId, on: req.db) else {
            throw Abort(.notFound, reason: "아이템을 찾을 수 없습니다.")
        }

        // 판매 중인지 확인
        guard item.isActive else {
            throw Abort(.badRequest, reason: "현재 판매하지 않는 아이템입니다.")
        }

        // Gems 잔액 확인
        guard user.gems >= item.price else {
            return PurchaseResponse(
                success: false,
                message: "Gems가 부족합니다. (보유: \(user.gems)💎, 필요: \(item.price)💎)",
                remainingGems: user.gems,
                inventoryItem: nil
            )
        }

        // 트랜잭션으로 구매 처리
        return try await req.db.transaction { db in
            // Gems 차감
            user.gems -= item.price
            try await user.save(on: db)

            // 인벤토리 추가 또는 수량 증가
            if let existingInventory = try await UserInventory.query(on: db)
                .filter(\.$user.$id == userId)
                .filter(\.$item.$id == itemId)
                .first()
            {
                existingInventory.quantity += 1
                try await existingInventory.save(on: db)

                return PurchaseResponse(
                    success: true,
                    message: "\(item.name)을(를) 구매했습니다!",
                    remainingGems: user.gems,
                    inventoryItem: InventoryItemResponse(
                        id: existingInventory.id!,
                        item: ShopItemResponse(from: item),
                        quantity: existingInventory.quantity
                    )
                )
            } else {
                let newInventory = UserInventory(
                    userId: userId,
                    itemId: itemId,
                    quantity: 1
                )
                try await newInventory.save(on: db)

                return PurchaseResponse(
                    success: true,
                    message: "\(item.name)을(를) 구매했습니다!",
                    remainingGems: user.gems,
                    inventoryItem: InventoryItemResponse(
                        id: newInventory.id!,
                        item: ShopItemResponse(from: item),
                        quantity: 1
                    )
                )
            }
        }
    }
}

// MARK: - DTOs

struct ShopItemResponse: Content {
    let id: UUID
    let name: String
    let description: String
    let itemType: ShopItemType
    let price: Int
    let icon: String

    init(from item: ShopItem) {
        self.id = item.id!
        self.name = item.name
        self.description = item.description
        self.itemType = item.itemType
        self.price = item.price
        self.icon = item.icon
    }
}

struct PurchaseResponse: Content {
    let success: Bool
    let message: String
    let remainingGems: Int
    let inventoryItem: InventoryItemResponse?
}

struct InventoryItemResponse: Content {
    let id: UUID
    let item: ShopItemResponse
    let quantity: Int
}
