import Vapor

struct AuthController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let auth = routes.grouped("auth")

        auth.post("github", "callback", use: githubCallback)
        auth.post("refresh", use: refreshToken)
        auth.post("logout", use: logout)
    }

    /// GitHub OAuth 콜백
    @Sendable
    func githubCallback(req: Request) async throws -> TokenResponse {
        // TODO: GitHub OAuth 구현
        // 1. code로 access_token 교환
        // 2. GitHub API로 사용자 정보 조회
        // 3. DB에서 사용자 찾기 또는 생성
        // 4. JWT 토큰 발급
        throw Abort(.notImplemented, reason: "GitHub OAuth not implemented yet")
    }

    /// 토큰 갱신
    @Sendable
    func refreshToken(req: Request) async throws -> TokenResponse {
        // TODO: Refresh token 검증 및 새 토큰 발급
        throw Abort(.notImplemented, reason: "Token refresh not implemented yet")
    }

    /// 로그아웃
    @Sendable
    func logout(req: Request) async throws -> HTTPStatus {
        // TODO: Refresh token 무효화
        return .ok
    }
}

// MARK: - DTOs
struct TokenResponse: Content {
    let accessToken: String
    let refreshToken: String
    let expiresIn: Int
    let tokenType: String

    init(accessToken: String, refreshToken: String, expiresIn: Int = 900) {
        self.accessToken = accessToken
        self.refreshToken = refreshToken
        self.expiresIn = expiresIn
        self.tokenType = "Bearer"
    }
}
