import Fluent
import JWT
import Vapor

struct AuthController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let auth = routes.grouped("auth")

        auth.post("github", "callback", use: githubCallback)
        auth.post("refresh", use: refreshToken)
        auth.post("logout", use: logout)
    }

    // MARK: - GitHub OAuth

    /// GitHub OAuth 콜백 - code를 받아 토큰 발급
    @Sendable
    func githubCallback(req: Request) async throws -> TokenResponse {
        let callbackRequest = try req.content.decode(GitHubCallbackRequest.self)

        // 1. GitHub에서 access token 교환
        let githubToken = try await exchangeCodeForToken(code: callbackRequest.code, req: req)

        // 2. GitHub API로 사용자 정보 조회
        let githubUser = try await fetchGitHubUser(accessToken: githubToken.accessToken, req: req)

        // 3. 이메일 조회 (private일 경우 별도 API 호출)
        let email = try await resolveEmail(githubUser: githubUser, accessToken: githubToken.accessToken, req: req)

        // 4. DB에서 사용자 찾기 또는 생성
        let user = try await findOrCreateUser(
            githubId: String(githubUser.id),
            username: githubUser.login,
            email: email,
            avatarUrl: githubUser.avatarUrl,
            db: req.db
        )

        // 5. 토큰 발급
        return try await generateTokens(for: user, req: req)
    }

    // MARK: - Token Refresh

    /// Refresh token으로 새 access token 발급
    @Sendable
    func refreshToken(req: Request) async throws -> TokenResponse {
        let refreshRequest = try req.content.decode(RefreshTokenRequest.self)

        // DB에서 refresh token 조회
        guard let storedToken = try await RefreshToken.query(on: req.db)
            .filter(\.$token == refreshRequest.refreshToken)
            .with(\.$user)
            .first()
        else {
            throw Abort(.unauthorized, reason: "Invalid refresh token")
        }

        // 유효성 검사
        guard storedToken.isValid else {
            throw Abort(.unauthorized, reason: "Refresh token expired or revoked")
        }

        // 기존 토큰 폐기
        storedToken.isRevoked = true
        try await storedToken.save(on: req.db)

        // 새 토큰 발급
        return try await generateTokens(for: storedToken.user, req: req)
    }

    // MARK: - Logout

    /// 로그아웃 - refresh token 무효화
    @Sendable
    func logout(req: Request) async throws -> HTTPStatus {
        let refreshRequest = try req.content.decode(RefreshTokenRequest.self)

        // DB에서 해당 refresh token 무효화
        if let storedToken = try await RefreshToken.query(on: req.db)
            .filter(\.$token == refreshRequest.refreshToken)
            .first()
        {
            storedToken.isRevoked = true
            try await storedToken.save(on: req.db)
        }

        return .ok
    }
}

// MARK: - Private Helpers

private extension AuthController {

    /// GitHub code를 access token으로 교환
    func exchangeCodeForToken(code: String, req: Request) async throws -> GitHubTokenResponse {
        let clientId = Environment.get("GITHUB_CLIENT_ID") ?? ""
        let clientSecret = Environment.get("GITHUB_CLIENT_SECRET") ?? ""

        guard !clientId.isEmpty, !clientSecret.isEmpty else {
            throw Abort(.internalServerError, reason: "GitHub OAuth not configured")
        }

        let response = try await req.client.post("https://github.com/login/oauth/access_token") { clientReq in
            clientReq.headers.add(name: .accept, value: "application/json")
            try clientReq.content.encode([
                "client_id": clientId,
                "client_secret": clientSecret,
                "code": code
            ])
        }

        guard response.status == .ok else {
            throw Abort(.unauthorized, reason: "Failed to exchange GitHub code")
        }

        return try response.content.decode(GitHubTokenResponse.self)
    }

    /// GitHub API로 사용자 정보 조회
    func fetchGitHubUser(accessToken: String, req: Request) async throws -> GitHubUserResponse {
        let response = try await req.client.get("https://api.github.com/user") { clientReq in
            clientReq.headers.add(name: .authorization, value: "Bearer \(accessToken)")
            clientReq.headers.add(name: .accept, value: "application/json")
            clientReq.headers.add(name: "User-Agent", value: "SwiftBoot")
        }

        guard response.status == .ok else {
            throw Abort(.unauthorized, reason: "Failed to fetch GitHub user")
        }

        return try response.content.decode(GitHubUserResponse.self)
    }

    /// 이메일 조회 - public이면 사용자 정보에서, private이면 별도 API 호출
    func resolveEmail(githubUser: GitHubUserResponse, accessToken: String, req: Request) async throws -> String {
        if let email = githubUser.email {
            return email
        }

        // Private 이메일인 경우 별도 API 호출
        let response = try await req.client.get("https://api.github.com/user/emails") { clientReq in
            clientReq.headers.add(name: .authorization, value: "Bearer \(accessToken)")
            clientReq.headers.add(name: .accept, value: "application/json")
            clientReq.headers.add(name: "User-Agent", value: "SwiftBoot")
        }

        guard response.status == .ok else {
            throw Abort(.badRequest, reason: "Failed to fetch GitHub emails")
        }

        let emails = try response.content.decode([GitHubEmailResponse].self)

        // Primary 이메일 우선, 없으면 첫 번째 verified 이메일
        if let primaryEmail = emails.first(where: { $0.primary && $0.verified }) {
            return primaryEmail.email
        }
        if let verifiedEmail = emails.first(where: { $0.verified }) {
            return verifiedEmail.email
        }

        throw Abort(.badRequest, reason: "No verified email found")
    }

    /// 사용자 찾기 또는 새로 생성
    func findOrCreateUser(
        githubId: String,
        username: String,
        email: String,
        avatarUrl: String?,
        db: Database
    ) async throws -> User {
        // 기존 사용자 찾기 (GitHub ID로)
        if let existingUser = try await User.query(on: db)
            .filter(\.$githubId == githubId)
            .first()
        {
            // 프로필 정보 업데이트
            existingUser.username = username
            existingUser.avatarUrl = avatarUrl
            try await existingUser.save(on: db)
            return existingUser
        }

        // 새 사용자 생성
        let newUser = User(
            username: username,
            email: email,
            githubId: githubId,
            avatarUrl: avatarUrl,
            gems: 50  // 신규 가입 보너스
        )
        try await newUser.save(on: db)
        return newUser
    }

    /// JWT Access Token + Refresh Token 생성
    func generateTokens(for user: User, req: Request) async throws -> TokenResponse {
        guard let userId = user.id else {
            throw Abort(.internalServerError, reason: "User ID not found")
        }

        // Access Token 생성
        let payload = AccessTokenPayload(userId: userId)
        let accessToken = try req.jwt.sign(payload)

        // Refresh Token 생성 및 저장
        let refreshToken = RefreshToken.generate(for: userId)
        try await refreshToken.save(on: req.db)

        return TokenResponse(
            accessToken: accessToken,
            refreshToken: refreshToken.token
        )
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
