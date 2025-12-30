import Fluent
import Vapor

/// 기존 레슨에 MDX 커스텀 컴포넌트 예제 추가
struct UpdateLessonWithMdxComponents: AsyncMigration {
    func prepare(on database: Database) async throws {
        // Lesson 1 (Swifty의 첫 마디) 업데이트
        guard let lesson = try await Lesson.query(on: database)
            .filter(\.$id == UUID(uuidString: "44444444-4444-4444-4444-444444100101")!)
            .first() else {
            return
        }

        lesson.content = """
        # 🤖 Swifty 프로젝트 시작

        축하합니다! 오늘부터 당신은 AI 챗봇 **Swifty**의 개발자입니다.

        Swifty는 아직 아무것도 모르는 백지 상태예요. 첫 번째 미션은 Swifty가 처음으로 말을 할 수 있게 하는 것입니다.

        :::info{title="Swift란?"}
        Swift는 Apple이 개발한 현대적인 프로그래밍 언어입니다.
        iOS, macOS, watchOS, tvOS 앱을 만들 수 있어요.
        :::

        ---

        ## 📚 print() 함수

        Swift에서 화면에 텍스트를 출력하려면 `print()` 함수를 사용합니다.

        ```swift
        print("안녕하세요!")
        // 출력: 안녕하세요!
        ```

        문자열(텍스트)은 항상 **큰따옴표** `""`로 감싸야 합니다.

        :::warning{title="주의"}
        문자열을 감쌀 때 작은따옴표(`''`)가 아닌 **큰따옴표(`""`)**를 사용해야 합니다!
        Swift에서 작은따옴표는 문자열로 인식되지 않아요.
        :::

        ---

        ## 🎯 미션

        Swifty가 `"안녕하세요! 저는 Swifty입니다."` 라고 인사하게 만드세요.

        :::hint{title="힌트가 필요하면 클릭!"}
        `print()` 함수 안에 출력하고 싶은 텍스트를 큰따옴표로 감싸서 넣으세요.

        예: `print("원하는 텍스트")`
        :::
        """

        try await lesson.save(on: database)
    }

    func revert(on database: Database) async throws {
        // 원래 콘텐츠로 복원
        guard let lesson = try await Lesson.query(on: database)
            .filter(\.$id == UUID(uuidString: "44444444-4444-4444-4444-444444100101")!)
            .first() else {
            return
        }

        lesson.content = """
        # 🤖 Swifty 프로젝트 시작

        축하합니다! 오늘부터 당신은 AI 챗봇 **Swifty**의 개발자입니다.

        Swifty는 아직 아무것도 모르는 백지 상태예요. 첫 번째 미션은 Swifty가 처음으로 말을 할 수 있게 하는 것입니다.

        ---

        ## 📚 print() 함수

        Swift에서 화면에 텍스트를 출력하려면 `print()` 함수를 사용합니다.

        ```swift
        print("안녕하세요!")
        // 출력: 안녕하세요!
        ```

        문자열(텍스트)은 항상 **큰따옴표** `""`로 감싸야 합니다.

        ---

        ## 🎯 미션

        Swifty가 `"안녕하세요! 저는 Swifty입니다."` 라고 인사하게 만드세요.
        """

        try await lesson.save(on: database)
    }
}
