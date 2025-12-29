import Fluent
import Vapor

struct TrackController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let tracks = routes.grouped("tracks")

        tracks.get(use: getAllTracks)
        tracks.get(":trackId", use: getTrack)
        tracks.get(":trackId", "courses", use: getTrackCourses)
    }

    /// 모든 트랙 목록
    @Sendable
    func getAllTracks(req: Request) async throws -> [TrackResponse] {
        let tracks = try await Track.query(on: req.db)
            .filter(\.$isPublished == true)
            .sort(\.$order)
            .all()

        return tracks.map { TrackResponse(from: $0) }
    }

    /// 특정 트랙 상세
    @Sendable
    func getTrack(req: Request) async throws -> TrackDetailResponse {
        guard let trackId = req.parameters.get("trackId", as: UUID.self) else {
            throw Abort(.badRequest)
        }

        guard let track = try await Track.query(on: req.db)
            .filter(\.$id == trackId)
            .filter(\.$isPublished == true)
            .with(\.$courses)
            .first() else {
            throw Abort(.notFound)
        }

        return TrackDetailResponse(from: track)
    }

    /// 트랙의 코스 목록
    @Sendable
    func getTrackCourses(req: Request) async throws -> [CourseResponse] {
        guard let trackId = req.parameters.get("trackId", as: UUID.self) else {
            throw Abort(.badRequest)
        }

        let courses = try await Course.query(on: req.db)
            .filter(\.$track.$id == trackId)
            .filter(\.$isPublished == true)
            .sort(\.$order)
            .all()

        return courses.map { CourseResponse(from: $0) }
    }
}

// MARK: - DTOs
struct TrackResponse: Content {
    let id: UUID
    let title: String
    let description: String
    let icon: String?

    init(from track: Track) {
        self.id = track.id!
        self.title = track.title
        self.description = track.description
        self.icon = track.icon
    }
}

struct TrackDetailResponse: Content {
    let id: UUID
    let title: String
    let description: String
    let icon: String?
    let courses: [CourseResponse]

    init(from track: Track) {
        self.id = track.id!
        self.title = track.title
        self.description = track.description
        self.icon = track.icon
        self.courses = track.courses.map { CourseResponse(from: $0) }
    }
}
