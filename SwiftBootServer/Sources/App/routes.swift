import Vapor

func routes(_ app: Application) throws {
    // Health check (Rate Limit 제외)
    app.get { _ async in
        ["status": "ok", "service": "SwiftBoot API"]
    }

    app.get("health") { _ async in
        ["status": "healthy"]
    }

    // API v1 routes - 기본 Rate Limit 적용
    let api = app.grouped("api", "v1")
        .grouped(RateLimitMiddleware(config: .default))

    // Auth routes - 더 엄격한 Rate Limit
    let authApi = app.grouped("api", "v1")
        .grouped(RateLimitMiddleware(config: .auth))
    try authApi.register(collection: AuthController())

    // User routes
    try api.register(collection: UserController())

    // Learning routes
    try api.register(collection: TrackController())
    try api.register(collection: CourseController())
    try api.register(collection: LessonController())
}
