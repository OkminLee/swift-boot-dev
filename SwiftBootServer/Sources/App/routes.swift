import Vapor

func routes(_ app: Application) throws {
    // Health check (Rate Limit 제외)
    app.get { _ async in
        ["status": "ok", "service": "SwiftBoot API"]
    }

    app.get("health") { _ async in
        ["status": "healthy"]
    }

    // API v1 routes - 메모리 기반 Rate Limit 적용 (Redis 불필요)
    let api = app.grouped("api", "v1")
        .grouped(InMemoryRateLimitMiddleware(config: .default))

    // Auth routes - 더 엄격한 Rate Limit
    let authApi = app.grouped("api", "v1")
        .grouped(InMemoryRateLimitMiddleware(config: .auth))
    try authApi.register(collection: AuthController())

    // User routes
    try api.register(collection: UserController())

    // Learning routes
    try api.register(collection: TrackController())
    try api.register(collection: CourseController())
    try api.register(collection: LessonController())

    // Shop routes
    try api.register(collection: ShopController())
    try api.register(collection: InventoryController())

    // Chest routes
    try api.register(collection: ChestController())
}
