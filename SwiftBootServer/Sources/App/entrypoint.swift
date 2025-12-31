import Vapor
import Logging

@main
enum Entrypoint {
    static func main() async throws {
        var env = try Environment.detect()
        try LoggingSystem.bootstrap(from: &env)

        print("🚀 SwiftBoot Server starting...")

        let app = try await Application.make(env)

        print("📦 Application created, configuring...")

        do {
            try await configure(app)
            print("✅ Configuration complete")

            app.logger.info("🔄 Starting auto-migration...")
            try await app.autoMigrate()
            app.logger.info("✅ Auto-migration completed successfully")
        } catch {
            print("❌ Error during startup: \(error)")
            app.logger.report(error: error)
            try? await app.asyncShutdown()
            throw error
        }

        try await app.execute()
        try await app.asyncShutdown()
    }
}
