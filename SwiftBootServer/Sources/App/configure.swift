import Fluent
import FluentPostgresDriver
import JWT
import Redis
import Vapor

/// SwiftBoot 서버 설정
func configure(_ app: Application) async throws {
    // MARK: - CORS
    let corsConfiguration = CORSMiddleware.Configuration(
        allowedOrigin: .all,
        allowedMethods: [.GET, .POST, .PUT, .OPTIONS, .DELETE, .PATCH],
        allowedHeaders: [
            .accept,
            .authorization,
            .contentType,
            .origin,
            .xRequestedWith,
            .userAgent,
            .accessControlAllowOrigin,
        ]
    )
    let cors = CORSMiddleware(configuration: corsConfiguration)
    app.middleware.use(cors, at: .beginning)

    // MARK: - Database
    app.databases.use(
        .postgres(
            configuration: SQLPostgresConfiguration(
                hostname: Environment.get("DATABASE_HOST") ?? "localhost",
                port: Environment.get("DATABASE_PORT").flatMap(Int.init) ?? SQLPostgresConfiguration.ianaPortNumber,
                username: Environment.get("DATABASE_USERNAME") ?? "swiftboot",
                password: Environment.get("DATABASE_PASSWORD") ?? "swiftboot",
                database: Environment.get("DATABASE_NAME") ?? "swiftboot",
                tls: .prefer(try .init(configuration: .clientDefault))
            )
        ),
        as: .psql
    )

    // MARK: - Redis
    app.redis.configuration = try RedisConfiguration(
        hostname: Environment.get("REDIS_HOST") ?? "localhost",
        port: Environment.get("REDIS_PORT").flatMap(Int.init) ?? 6379
    )

    // MARK: - JWT
    let jwtSecret = Environment.get("JWT_SECRET") ?? "swiftboot-dev-secret-change-in-production"
    app.jwt.signers.use(.hs256(key: jwtSecret))

    // MARK: - Migrations
    app.migrations.add(CreateUser())
    app.migrations.add(CreateTrack())
    app.migrations.add(CreateCourse())
    app.migrations.add(CreateChapter())
    app.migrations.add(CreateLesson())
    app.migrations.add(CreateUserProgress())
    app.migrations.add(CreateRefreshToken())
    app.migrations.add(SeedContent())
    app.migrations.add(SeedSwiftyContent())
    app.migrations.add(CreateShopItem())
    app.migrations.add(CreateUserInventory())
    app.migrations.add(SeedShopItems())

    // MARK: - Routes
    try routes(app)
}
