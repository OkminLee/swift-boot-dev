import Fluent
import Vapor

/// 레슨 유형
enum LessonType: String, Codable {
    case reading          // 읽기 자료
    case multipleChoice   // 객관식 퀴즈
    case codeExercise     // 코드 작성
    case codeOutput       // 출력 예측
}

/// 코드 실행 언어
enum ProgrammingLanguage: String, Codable {
    case swift
    case python
    case go
    case javascript
}

/// 레슨 (실제 학습 단위)
final class Lesson: Model, Content, @unchecked Sendable {
    static let schema = "lessons"

    @ID(key: .id)
    var id: UUID?

    @Parent(key: "chapter_id")
    var chapter: Chapter

    @Field(key: "title")
    var title: String

    @Field(key: "content")
    var content: String  // MDX 콘텐츠

    @Field(key: "type")
    var type: LessonType

    @Field(key: "language")
    var language: ProgrammingLanguage?

    @Field(key: "starter_code")
    var starterCode: String?

    @Field(key: "solution_code")
    var solutionCode: String?

    @Field(key: "test_code")
    var testCode: String?  // 히든 테스트

    @Field(key: "expected_output")
    var expectedOutput: String?

    @Field(key: "xp_reward")
    var xpReward: Int

    @Field(key: "order")
    var order: Int

    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?

    @Timestamp(key: "updated_at", on: .update)
    var updatedAt: Date?

    init() {}

    init(
        id: UUID? = nil,
        chapterId: UUID,
        title: String,
        content: String,
        type: LessonType,
        language: ProgrammingLanguage? = nil,
        starterCode: String? = nil,
        solutionCode: String? = nil,
        testCode: String? = nil,
        expectedOutput: String? = nil,
        xpReward: Int = 10,
        order: Int = 0
    ) {
        self.id = id
        self.$chapter.id = chapterId
        self.title = title
        self.content = content
        self.type = type
        self.language = language
        self.starterCode = starterCode
        self.solutionCode = solutionCode
        self.testCode = testCode
        self.expectedOutput = expectedOutput
        self.xpReward = xpReward
        self.order = order
    }
}
