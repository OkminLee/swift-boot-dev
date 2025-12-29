import JWT
import Vapor

// MARK: - JWT Payload

/// Access Token에 포함되는 JWT Payload
struct AccessTokenPayload: JWTPayload {
    /// 사용자 ID
    var sub: SubjectClaim
    /// 발급 시간
    var iat: IssuedAtClaim
    /// 만료 시간
    var exp: ExpirationClaim

    init(userId: UUID) {
        self.sub = SubjectClaim(value: userId.uuidString)
        self.iat = IssuedAtClaim(value: Date())
        self.exp = ExpirationClaim(value: Date().addingTimeInterval(15 * 60)) // 15분
    }

    func verify(using signer: JWTSigner) throws {
        try exp.verifyNotExpired()
    }

    var userId: UUID? {
        UUID(uuidString: sub.value)
    }
}

// MARK: - GitHub OAuth DTOs

/// 프론트엔드에서 받는 GitHub 콜백 요청
struct GitHubCallbackRequest: Content {
    let code: String
}

/// GitHub OAuth Access Token 응답
struct GitHubTokenResponse: Content {
    let accessToken: String
    let tokenType: String
    let scope: String

    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case tokenType = "token_type"
        case scope
    }
}

/// GitHub 사용자 정보 응답
struct GitHubUserResponse: Content {
    let id: Int
    let login: String
    let email: String?
    let avatarUrl: String?

    enum CodingKeys: String, CodingKey {
        case id
        case login
        case email
        case avatarUrl = "avatar_url"
    }
}

/// GitHub 이메일 정보 (별도 API 호출용)
struct GitHubEmailResponse: Content {
    let email: String
    let primary: Bool
    let verified: Bool
}

// MARK: - Refresh Token Request

/// 토큰 갱신 요청
struct RefreshTokenRequest: Content {
    let refreshToken: String
}
