import Fluent
import Vapor

/// 기본 Track 시드 데이터 (코스는 별도 파일에서 관리)
struct SeedContent: AsyncMigration {
    func prepare(on database: Database) async throws {
        // MARK: - Track: Swift Developer
        let swiftTrack = Track(
            id: UUID(uuidString: "11111111-1111-1111-1111-111111111111"),
            title: "Swift Developer",
            description: "Swift 프로그래밍 언어를 마스터하고 iOS/macOS 앱 개발자가 되세요.",
            icon: "swift",
            order: 1,
            isPublished: true
        )
        try await swiftTrack.save(on: database)
    }

    func revert(on database: Database) async throws {
        try await Track.query(on: database)
            .filter(\.$id == UUID(uuidString: "11111111-1111-1111-1111-111111111111")!)
            .delete()
    }
}
