@preconcurrency import Redis
import Vapor

/// Rate Limiting 미들웨어 - API 남용 방지
struct RateLimitMiddleware: AsyncMiddleware {
    /// Rate Limit 설정
    struct Configuration: Sendable {
        /// 허용 요청 수
        let maxRequests: Int
        /// 시간 윈도우 (초)
        let windowSeconds: Int
        /// Redis 키 접두사
        let keyPrefix: String

        static let `default` = Configuration(
            maxRequests: 100,
            windowSeconds: 60,
            keyPrefix: "ratelimit"
        )

        /// 코드 실행 API용 (더 엄격)
        static let codeExecution = Configuration(
            maxRequests: 20,
            windowSeconds: 60,
            keyPrefix: "ratelimit:code"
        )

        /// 인증 API용 (브루트포스 방지)
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
        let key = RedisKey("\(config.keyPrefix):\(identifier)")

        // Redis에서 현재 요청 수 조회 및 증가
        let result = try await incrementAndCheck(key: key, on: request)

        // Rate Limit 초과 체크
        guard result.currentCount <= config.maxRequests else {
            let response = Response(status: .tooManyRequests)
            response.body = .init(string: #"{"error":true,"reason":"Rate limit exceeded. Try again in \#(result.ttl) seconds."}"#)
            response.headers.contentType = HTTPMediaType.json
            addRateLimitHeaders(to: response, result: result)
            return response
        }

        // 다음 미들웨어로 전달
        let response: Response
        do {
            response = try await next.respond(to: request)
        } catch {
            // 에러 발생시에도 Rate Limit 헤더 추가
            let abortError = error as? AbortError
            let statusCode = abortError?.status ?? .internalServerError
            let reason = abortError?.reason ?? error.localizedDescription
            let errorResponse = Response(status: statusCode)
            errorResponse.body = .init(string: #"{"error":true,"reason":"\#(reason)"}"#)
            errorResponse.headers.contentType = HTTPMediaType.json
            addRateLimitHeaders(to: errorResponse, result: result)
            return errorResponse
        }

        // Rate Limit 헤더 추가
        addRateLimitHeaders(to: response, result: result)
        return response
    }

    private func addRateLimitHeaders(to response: Response, result: (currentCount: Int, ttl: Int)) {
        response.headers.add(name: "X-RateLimit-Limit", value: "\(config.maxRequests)")
        response.headers.add(name: "X-RateLimit-Remaining", value: "\(max(0, config.maxRequests - result.currentCount))")
        response.headers.add(name: "X-RateLimit-Reset", value: "\(result.ttl)")
    }

    /// 요청자 식별자 결정 (인증된 사용자 ID 또는 IP)
    private func resolveIdentifier(from request: Request) -> String {
        // 인증된 사용자가 있으면 사용자 ID 사용
        if let userId = request.authenticatedUserId {
            return "user:\(userId.uuidString)"
        }

        // X-Forwarded-For 헤더 확인 (프록시 뒤에 있을 경우)
        if let forwardedFor = request.headers.first(name: "X-Forwarded-For") {
            let clientIP = forwardedFor.split(separator: ",").first.map(String.init) ?? forwardedFor
            return "ip:\(clientIP.trimmingCharacters(in: .whitespaces))"
        }

        // 직접 연결된 IP
        return "ip:\(request.remoteAddress?.hostname ?? "unknown")"
    }

    /// Redis에서 카운터 증가 및 TTL 조회
    private func incrementAndCheck(
        key: RedisKey,
        on request: Request
    ) async throws -> (currentCount: Int, ttl: Int) {
        let redis = request.redis

        // INCR로 카운터 증가
        let count = try await redis.increment(key).get()

        // 새로운 키면 TTL 설정
        if count == 1 {
            _ = try await redis.expire(key, after: .seconds(Int64(config.windowSeconds))).get()
        }

        // TTL 조회
        let ttl = try await redis.ttl(key).get()
        let ttlSeconds: Int
        switch ttl {
        case .keyDoesNotExist, .unlimited:
            ttlSeconds = config.windowSeconds
        case .limited(let duration):
            // RediStack Duration은 timeAmount 속성 사용
            let nanoseconds = duration.timeAmount.nanoseconds
            ttlSeconds = max(1, Int(nanoseconds / 1_000_000_000))
        }

        return (Int(count), ttlSeconds)
    }
}

// MARK: - RouteBuilder Extension

extension RoutesBuilder {
    /// Rate Limit이 적용된 그룹 생성
    func rateLimited(_ config: RateLimitMiddleware.Configuration = .default) -> RoutesBuilder {
        grouped(RateLimitMiddleware(config: config))
    }
}
