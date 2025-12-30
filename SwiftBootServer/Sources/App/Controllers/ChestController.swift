import Fluent
import Vapor

struct ChestController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let chests = routes.grouped("chests")

        // 인증 필요
        let protected = chests.grouped(JWTAuthMiddleware())
        protected.get(use: getMyChests)
        protected.get("unopened", use: getUnopenedChests)
        protected.post(":userChestId", "open", use: openChest)
        protected.get("history", use: getOpenHistory)
    }

    /// 사용자의 모든 chest 조회
    @Sendable
    func getMyChests(req: Request) async throws -> [UserChestResponse] {
        let userId = try req.requireAuthenticatedUserId()

        let userChests = try await UserChest.query(on: req.db)
            .filter(\.$user.$id == userId)
            .with(\.$chest)
            .sort(\.$acquiredAt, .descending)
            .all()

        return userChests.map { UserChestResponse(from: $0) }
    }

    /// 미개봉 chest만 조회
    @Sendable
    func getUnopenedChests(req: Request) async throws -> [UserChestResponse] {
        let userId = try req.requireAuthenticatedUserId()

        let userChests = try await UserChest.query(on: req.db)
            .filter(\.$user.$id == userId)
            .filter(\.$isOpened == false)
            .with(\.$chest)
            .sort(\.$acquiredAt, .descending)
            .all()

        return userChests.map { UserChestResponse(from: $0) }
    }

    /// Chest 개봉
    @Sendable
    func openChest(req: Request) async throws -> ChestOpenResponse {
        let userId = try req.requireAuthenticatedUserId()

        guard let userChestIdString = req.parameters.get("userChestId"),
              let userChestId = UUID(uuidString: userChestIdString) else {
            throw Abort(.badRequest, reason: "Invalid chest ID")
        }

        // 트랜잭션으로 chest 개봉 및 보상 지급
        return try await req.db.transaction { db in
            // chest 조회
            guard let userChest = try await UserChest.query(on: db)
                .filter(\.$id == userChestId)
                .filter(\.$user.$id == userId)
                .with(\.$chest)
                .first() else {
                throw Abort(.notFound, reason: "Chest not found")
            }

            // 이미 개봉한 chest인지 확인
            if userChest.isOpened {
                throw Abort(.badRequest, reason: "Chest already opened")
            }

            // 보상 계산
            let reward = generateReward(for: userChest.chest.rarity, db: db)

            // 사용자 정보 업데이트
            guard let user = try await User.find(userId, on: db) else {
                throw Abort(.notFound, reason: "User not found")
            }

            user.gems += reward.gems
            let didLevelUp = user.addXp(reward.xp)
            try await user.save(on: db)

            // 아이템 보상이 있으면 인벤토리에 추가
            for item in reward.items {
                if let existingInventory = try await UserInventory.query(on: db)
                    .filter(\.$user.$id == userId)
                    .filter(\.$item.$id == item.itemId)
                    .first() {
                    existingInventory.quantity += item.quantity
                    try await existingInventory.save(on: db)
                } else {
                    let newInventory = UserInventory(
                        userId: userId,
                        itemId: item.itemId,
                        quantity: item.quantity
                    )
                    try await newInventory.save(on: db)
                }
            }

            // chest 개봉 처리
            userChest.isOpened = true
            userChest.openedAt = Date()
            try await userChest.save(on: db)

            return ChestOpenResponse(
                userChestId: userChestId,
                chestRarity: userChest.chest.rarity.rawValue,
                chestName: userChest.chest.name,
                reward: reward,
                didLevelUp: didLevelUp,
                newLevel: user.level,
                newTotalXp: user.totalXp,
                newGems: user.gems
            )
        }
    }

    /// 개봉 기록 조회
    @Sendable
    func getOpenHistory(req: Request) async throws -> [UserChestResponse] {
        let userId = try req.requireAuthenticatedUserId()

        let userChests = try await UserChest.query(on: req.db)
            .filter(\.$user.$id == userId)
            .filter(\.$isOpened == true)
            .with(\.$chest)
            .sort(\.$openedAt, .descending)
            .range(..<20) // 최근 20개
            .all()

        return userChests.map { UserChestResponse(from: $0) }
    }

    // MARK: - Private Methods

    /// 보상 생성
    private func generateReward(for rarity: ChestRarity, db: Database) -> ChestReward {
        let gems = Int.random(in: rarity.gemsRange)
        let xp = Int.random(in: rarity.xpRange)

        // 아이템 드롭 (확률 기반)
        var items: [ChestReward.RewardItem] = []

        // TODO: 실제 아이템 드롭 로직 구현
        // 현재는 확률에 따라 Seer Stone 드롭
        if Double.random(in: 0...1) < rarity.itemDropChance {
            // Seer Stone ID는 Seed에서 생성된 것을 사용해야 함
            // 여기서는 임시로 빈 배열 유지
        }

        return ChestReward(gems: gems, xp: xp, items: items)
    }
}

// MARK: - Response DTOs

struct UserChestResponse: Content {
    let id: UUID
    let chestId: UUID
    let chestName: String
    let chestRarity: String
    let chestIcon: String
    let source: String
    let isOpened: Bool
    let acquiredAt: Date?
    let openedAt: Date?

    init(from userChest: UserChest) {
        self.id = userChest.id!
        self.chestId = userChest.$chest.id
        self.chestName = userChest.chest.name
        self.chestRarity = userChest.chest.rarity.rawValue
        self.chestIcon = userChest.chest.iconUrl
        self.source = userChest.source
        self.isOpened = userChest.isOpened
        self.acquiredAt = userChest.acquiredAt
        self.openedAt = userChest.openedAt
    }
}

struct ChestOpenResponse: Content {
    let userChestId: UUID
    let chestRarity: String
    let chestName: String
    let reward: ChestReward
    let didLevelUp: Bool
    let newLevel: Int
    let newTotalXp: Int
    let newGems: Int
}
