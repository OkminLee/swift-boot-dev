import Vapor

/// 프로그래밍 언어별 Docker 실행 설정
struct LanguageConfig {
    let language: ProgrammingLanguage
    let dockerImage: String
    let fileExtension: String
    let runCommand: String

    /// 언어별 설정 매핑
    static let configs: [ProgrammingLanguage: LanguageConfig] = [
        .swift: LanguageConfig(
            language: .swift,
            dockerImage: "swiftlang/swift:nightly-6.0-jammy",
            fileExtension: "swift",
            runCommand: "swift /app/main.swift"
        ),
        .python: LanguageConfig(
            language: .python,
            dockerImage: "python:3.12-slim",
            fileExtension: "py",
            runCommand: "python3 /app/main.py"
        ),
        .go: LanguageConfig(
            language: .go,
            dockerImage: "golang:1.22-alpine",
            fileExtension: "go",
            runCommand: "go run /app/main.go"
        ),
        .javascript: LanguageConfig(
            language: .javascript,
            dockerImage: "node:20-alpine",
            fileExtension: "js",
            runCommand: "node /app/main.js"
        )
    ]

    /// 언어에 맞는 설정 조회
    static func config(for language: ProgrammingLanguage) -> LanguageConfig? {
        configs[language]
    }
}
