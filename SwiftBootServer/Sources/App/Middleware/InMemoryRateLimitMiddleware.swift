import Vapor
import Foundation

/// 메모리 기반 Rate Limiting 미들웨어
/// Redis 없이 동작하며, 단일 인스턴스 환경에 적합
struct InMemoryRateLimitMiddleware: AsyncMiddleware {

    struct Configuration: Sendable {
        let maxRequests: Int
        let windowSeconds: Int
        let keyPrefix: String

        static let `default` = Configuration(
            maxRequests: 100,
            windowSeconds: 60,
            keyPrefix: "ratelimit"
        )

        static let codeExecution = Configuration(
            maxRequests: 20,
            windowSeconds: 60,
            keyPrefix: "ratelimit:code"
        )

        static let auth = Configuration(
            maxRequests: 10,
            windowSeconds: 60,
            keyPrefix: "ratelimit:auth"
        )
    }

    let config: Configuration

    init(config: Configuration = .default) {
        self.config = config
    }

    func respond(to request: Request, chainingTo next: AsyncResponder) async throws -> Response {
        let identifier = resolveIdentifier(from: request)
        let key = "\(config.keyPrefix):\(identifier)"

        let result = await RateLimitStore.shared.incrementAndCheck(
            key: key,
            maxRequests: config.maxRequests,
            windowSeconds: config.windowSeconds
        )

        guard result.currentCount <= config.maxRequests else {
            let response = Response(status: .tooManyRequests)
            response.body = .init(string: #"{"error":true,"reason":"Rate limit exceeded. Try again in \#(result.ttl) seconds."}"#)
            response.headers.contentType = HTTPMediaType.json
            addRateLimitHeaders(to: response, result: result)
            return response
        }

        let response: Response
        do {
            response = try await next.respond(to: request)
        } catch {
            let abortError = error as? AbortError
            let statusCode = abortError?.status ?? .internalServerError
            let reason = abortError?.reason ?? error.localizedDescription
            let errorResponse = Response(status: statusCode)
            errorResponse.body = .init(string: #"{"error":true,"reason":"\#(reason)"}"#)
            errorResponse.headers.contentType = HTTPMediaType.json
            addRateLimitHeaders(to: errorResponse, result: result)
            return errorResponse
        }

        addRateLimitHeaders(to: response, result: result)
        return response
    }

    private func addRateLimitHeaders(to response: Response, result: (currentCount: Int, ttl: Int)) {
        response.headers.add(name: "X-RateLimit-Limit", value: "\(config.maxRequests)")
        response.headers.add(name: "X-RateLimit-Remaining", value: "\(max(0, config.maxRequests - result.currentCount))")
        response.headers.add(name: "X-RateLimit-Reset", value: "\(result.ttl)")
    }

    private func resolveIdentifier(from request: Request) -> String {
        if let userId = request.authenticatedUserId {
            return "user:\(userId.uuidString)"
        }

        if let forwardedFor = request.headers.first(name: "X-Forwarded-For") {
            let clientIP = forwardedFor.split(separator: ",").first.map(String.init) ?? forwardedFor
            return "ip:\(clientIP.trimmingCharacters(in: .whitespaces))"
        }

        return "ip:\(request.remoteAddress?.hostname ?? "unknown")"
    }
}

// MARK: - Rate Limit Store (Thread-safe Actor)

/// Thread-safe 메모리 기반 Rate Limit 저장소
actor RateLimitStore {
    static let shared = RateLimitStore()

    private struct Entry {
        var count: Int
        var expiresAt: Date
    }

    private var store: [String: Entry] = [:]
    private var lastCleanup: Date = Date()
    private let cleanupInterval: TimeInterval = 60

    private init() {}

    func incrementAndCheck(
        key: String,
        maxRequests: Int,
        windowSeconds: Int
    ) -> (currentCount: Int, ttl: Int) {
        let now = Date()

        // 주기적 정리 (오래된 항목 제거)
        if now.timeIntervalSince(lastCleanup) > cleanupInterval {
            cleanup()
            lastCleanup = now
        }

        if let entry = store[key], entry.expiresAt > now {
            // 기존 윈도우 내 - 카운트 증가
            let newCount = entry.count + 1
            store[key] = Entry(count: newCount, expiresAt: entry.expiresAt)
            let ttl = max(1, Int(entry.expiresAt.timeIntervalSince(now)))
            return (newCount, ttl)
        } else {
            // 새 윈도우 시작
            let expiresAt = now.addingTimeInterval(TimeInterval(windowSeconds))
            store[key] = Entry(count: 1, expiresAt: expiresAt)
            return (1, windowSeconds)
        }
    }

    private func cleanup() {
        let now = Date()
        store = store.filter { $0.value.expiresAt > now }
    }
}

// MARK: - RoutesBuilder Extension

extension RoutesBuilder {
    func inMemoryRateLimited(_ config: InMemoryRateLimitMiddleware.Configuration = .default) -> RoutesBuilder {
        grouped(InMemoryRateLimitMiddleware(config: config))
    }
}
