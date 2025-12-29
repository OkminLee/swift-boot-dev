import Fluent
import Vapor

/// Refresh Token 모델 - DB에 저장하여 만료/무효화 관리
final class RefreshToken: Model, Content, @unchecked Sendable {
    static let schema = "refresh_tokens"

    @ID(key: .id)
    var id: UUID?

    @Field(key: "token")
    var token: String

    @Parent(key: "user_id")
    var user: User

    @Field(key: "expires_at")
    var expiresAt: Date

    @Field(key: "is_revoked")
    var isRevoked: Bool

    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?

    init() {}

    init(
        id: UUID? = nil,
        token: String,
        userID: UUID,
        expiresAt: Date,
        isRevoked: Bool = false
    ) {
        self.id = id
        self.token = token
        self.$user.id = userID
        self.expiresAt = expiresAt
        self.isRevoked = isRevoked
    }
}

extension RefreshToken {
    /// 7일 후 만료되는 새 토큰 생성
    static func generate(for userID: UUID) -> RefreshToken {
        let token = [UInt8].random(count: 32).base64
        let expiresAt = Date().addingTimeInterval(7 * 24 * 60 * 60) // 7일
        return RefreshToken(token: token, userID: userID, expiresAt: expiresAt)
    }

    /// 토큰 유효성 검사
    var isValid: Bool {
        !isRevoked && expiresAt > Date()
    }
}
