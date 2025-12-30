import Fluent
import Vapor

struct InventoryController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let inventory = routes.grouped("inventory")
            .grouped(JWTAuthMiddleware())

        inventory.get(use: getInventory)
        inventory.post("use", "seer-stone", ":lessonId", use: useSeerStone)
    }

    /// 인벤토리 조회
    @Sendable
    func getInventory(req: Request) async throws -> [InventoryItemResponse] {
        let userId = try req.requireAuthenticatedUserId()

        let inventoryItems = try await UserInventory.query(on: req.db)
            .filter(\.$user.$id == userId)
            .filter(\.$quantity > 0)
            .with(\.$item)
            .all()

        return inventoryItems.map { inventory in
            InventoryItemResponse(
                id: inventory.id!,
                item: ShopItemResponse(from: inventory.item),
                quantity: inventory.quantity
            )
        }
    }

    /// Seer Stone 사용 - 정답 코드 확인
    @Sendable
    func useSeerStone(req: Request) async throws -> SeerStoneResponse {
        guard let lessonIdString = req.parameters.get("lessonId"),
              let lessonId = UUID(uuidString: lessonIdString) else {
            throw Abort(.badRequest, reason: "유효하지 않은 레슨 ID입니다.")
        }

        let userId = try req.requireAuthenticatedUserId()

        // 레슨 조회
        guard let lesson = try await Lesson.find(lessonId, on: req.db) else {
            throw Abort(.notFound, reason: "레슨을 찾을 수 없습니다.")
        }

        // 정답 코드가 있는지 확인
        guard let solutionCode = lesson.solutionCode, !solutionCode.isEmpty else {
            throw Abort(.badRequest, reason: "이 레슨에는 정답 코드가 없습니다.")
        }

        // Seer Stone 아이템 찾기
        guard let seerStoneItem = try await ShopItem.query(on: req.db)
            .filter(\.$itemType == .seerStone)
            .first() else {
            throw Abort(.internalServerError, reason: "Seer Stone 아이템을 찾을 수 없습니다.")
        }

        // 사용자 인벤토리에서 Seer Stone 찾기
        guard let inventoryItem = try await UserInventory.query(on: req.db)
            .filter(\.$user.$id == userId)
            .filter(\.$item.$id == seerStoneItem.id!)
            .filter(\.$quantity > 0)
            .first() else {
            return SeerStoneResponse(
                success: false,
                message: "Seer Stone이 없습니다. 상점에서 구매해주세요!",
                solutionCode: nil,
                remainingQuantity: 0
            )
        }

        // Seer Stone 수량 차감
        inventoryItem.quantity -= 1
        try await inventoryItem.save(on: req.db)

        return SeerStoneResponse(
            success: true,
            message: "Seer Stone을 사용했습니다!",
            solutionCode: solutionCode,
            remainingQuantity: inventoryItem.quantity
        )
    }
}

// MARK: - DTOs

struct SeerStoneResponse: Content {
    let success: Bool
    let message: String
    let solutionCode: String?
    let remainingQuantity: Int
}
