import Vapor

/// 프로그래밍 언어별 실행 설정
struct LanguageConfig {
    let language: ProgrammingLanguage
    let fileExtension: String
    let judge0LanguageId: Int

    /// 언어별 설정 매핑 (Judge0 CE 언어 ID)
    static let configs: [ProgrammingLanguage: LanguageConfig] = [
        .swift: LanguageConfig(
            language: .swift,
            fileExtension: "swift",
            judge0LanguageId: 83  // Swift 5.2.3
        ),
        .python: LanguageConfig(
            language: .python,
            fileExtension: "py",
            judge0LanguageId: 100  // Python 3.12.5
        ),
        .go: LanguageConfig(
            language: .go,
            fileExtension: "go",
            judge0LanguageId: 107  // Go 1.23.5
        ),
        .javascript: LanguageConfig(
            language: .javascript,
            fileExtension: "js",
            judge0LanguageId: 102  // Node.js 22.08.0
        )
    ]

    /// 언어에 맞는 설정 조회
    static func config(for language: ProgrammingLanguage) -> LanguageConfig? {
        configs[language]
    }
}
