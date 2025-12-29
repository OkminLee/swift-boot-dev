// swift-tools-version:6.0
import PackageDescription

let package = Package(
    name: "SwiftBootServer",
    platforms: [
        .macOS(.v14)
    ],
    dependencies: [
        // Vapor
        .package(url: "https://github.com/vapor/vapor.git", from: "4.99.0"),
        // Fluent ORM
        .package(url: "https://github.com/vapor/fluent.git", from: "4.9.0"),
        // PostgreSQL Driver
        .package(url: "https://github.com/vapor/fluent-postgres-driver.git", from: "2.8.0"),
        // Redis
        .package(url: "https://github.com/vapor/redis.git", from: "4.10.0"),
        // Queues (Job Queue)
        .package(url: "https://github.com/vapor/queues.git", from: "1.13.0"),
        .package(url: "https://github.com/vapor/queues-redis-driver.git", from: "1.1.0"),
        // JWT
        .package(url: "https://github.com/vapor/jwt.git", from: "4.2.0"),
    ],
    targets: [
        .executableTarget(
            name: "App",
            dependencies: [
                .product(name: "Vapor", package: "vapor"),
                .product(name: "Fluent", package: "fluent"),
                .product(name: "FluentPostgresDriver", package: "fluent-postgres-driver"),
                .product(name: "Redis", package: "redis"),
                .product(name: "Queues", package: "queues"),
                .product(name: "QueuesRedisDriver", package: "queues-redis-driver"),
                .product(name: "JWT", package: "jwt"),
            ],
            swiftSettings: swiftSettings
        ),
        .testTarget(
            name: "AppTests",
            dependencies: [
                .target(name: "App"),
                .product(name: "XCTVapor", package: "vapor"),
            ],
            swiftSettings: swiftSettings
        ),
    ]
)

var swiftSettings: [SwiftSetting] {
    [
        .enableUpcomingFeature("DisableOutwardActorInference"),
        .enableExperimentalFeature("StrictConcurrency"),
    ]
}
