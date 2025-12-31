import Fluent
import FluentPostgresDriver
import JWT
import NIOSSL
import Vapor

/// SwiftBoot 서버 설정
func configure(_ app: Application) async throws {
    // MARK: - CORS
    let allowedOrigin: CORSMiddleware.AllowOriginSetting
    if let frontendURL = Environment.get("FRONTEND_URL") {
        // 프로덕션: 특정 도메인만 허용
        allowedOrigin = .custom(frontendURL)
    } else {
        // 개발: 모든 도메인 허용
        allowedOrigin = .all
    }

    let corsConfiguration = CORSMiddleware.Configuration(
        allowedOrigin: allowedOrigin,
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
    // Supabase 연결을 위한 TLS 설정 (인증서 검증 비활성화)
    var tlsConfig = TLSConfiguration.makeClientConfiguration()
    tlsConfig.certificateVerification = .none

    app.databases.use(
        .postgres(
            configuration: SQLPostgresConfiguration(
                hostname: Environment.get("DATABASE_HOST") ?? "localhost",
                port: Environment.get("DATABASE_PORT").flatMap(Int.init) ?? SQLPostgresConfiguration.ianaPortNumber,
                username: Environment.get("DATABASE_USERNAME") ?? "swiftboot",
                password: Environment.get("DATABASE_PASSWORD") ?? "swiftboot",
                database: Environment.get("DATABASE_NAME") ?? "swiftboot",
                tls: .require(try .init(configuration: tlsConfig))
            )
        ),
        as: .psql
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
    app.migrations.add(SeedSwifty2Content())
    app.migrations.add(SeedPixelQuestContent())
    app.migrations.add(CreateShopItem())
    app.migrations.add(CreateUserInventory())
    app.migrations.add(SeedShopItems())
    app.migrations.add(CreateChest())
    app.migrations.add(CreateUserChest())
    app.migrations.add(SeedChest())
    app.migrations.add(UpdateLessonWithMdxComponents())

    // MARK: - Routes
    try routes(app)
}
