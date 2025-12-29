import Vapor

func routes(_ app: Application) throws {
    // Health check
    app.get { _ async in
        ["status": "ok", "service": "SwiftBoot API"]
    }

    app.get("health") { _ async in
        ["status": "healthy"]
    }

    // API v1 routes
    let api = app.grouped("api", "v1")

    // Auth routes
    try api.register(collection: AuthController())

    // User routes
    try api.register(collection: UserController())

    // Learning routes
    try api.register(collection: TrackController())
    try api.register(collection: CourseController())
    try api.register(collection: LessonController())
}
