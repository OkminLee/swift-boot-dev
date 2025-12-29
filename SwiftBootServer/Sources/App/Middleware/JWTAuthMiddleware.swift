import JWT
import Vapor

/// JWT 인증 미들웨어 - 보호된 라우트에서 사용
struct JWTAuthMiddleware: AsyncMiddleware {
    func respond(to request: Request, chainingTo next: AsyncResponder) async throws -> Response {
        // Authorization 헤더에서 Bearer 토큰 확인
        guard request.headers.bearerAuthorization != nil else {
            throw Abort(.unauthorized, reason: "Missing authorization header")
        }

        do {
            // JWT 검증 및 페이로드 추출
            let payload = try request.jwt.verify(as: AccessTokenPayload.self)

            // 사용자 ID를 request storage에 저장
            guard let userId = payload.userId else {
                throw Abort(.unauthorized, reason: "Invalid token payload")
            }

            request.auth.login(AuthenticatedUser(id: userId))

            return try await next.respond(to: request)
        } catch {
            throw Abort(.unauthorized, reason: "Invalid or expired token")
        }
    }
}

/// 인증된 사용자 정보 (request storage용)
struct AuthenticatedUser: Authenticatable {
    let id: UUID
}

// MARK: - Request Extension

extension Request {
    /// 현재 인증된 사용자 ID 조회
    var authenticatedUserId: UUID? {
        auth.get(AuthenticatedUser.self)?.id
    }

    /// 인증된 사용자 ID 필수 조회 (없으면 에러)
    func requireAuthenticatedUserId() throws -> UUID {
        guard let userId = authenticatedUserId else {
            throw Abort(.unauthorized, reason: "Not authenticated")
        }
        return userId
    }

    /// 인증된 사용자 모델 조회
    func authenticatedUser() async throws -> User {
        let userId = try requireAuthenticatedUserId()
        guard let user = try await User.find(userId, on: db) else {
            throw Abort(.notFound, reason: "User not found")
        }
        return user
    }
}
