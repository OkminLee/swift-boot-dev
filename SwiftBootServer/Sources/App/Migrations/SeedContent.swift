import Fluent
import Vapor

/// 샘플 학습 콘텐츠 시드 데이터
struct SeedContent: AsyncMigration {
    func prepare(on database: Database) async throws {
        // MARK: - Track: Swift Developer
        let swiftTrack = Track(
            id: UUID(uuidString: "11111111-1111-1111-1111-111111111111"),
            title: "Swift Developer",
            description: "Swift 프로그래밍 언어를 마스터하고 iOS/macOS 앱 개발자가 되세요.",
            icon: "swift",
            order: 1,
            isPublished: true
        )
        try await swiftTrack.save(on: database)

        // MARK: - Course 1: Swift 기초
        let course1 = Course(
            id: UUID(uuidString: "22222222-2222-2222-2222-222222222201"),
            trackId: swiftTrack.id!,
            title: "Swift 기초",
            description: "Swift 프로그래밍의 기본 문법과 개념을 배웁니다.",
            icon: "book",
            difficulty: .beginner,
            order: 1,
            isPublished: true
        )
        try await course1.save(on: database)

        // Chapter 1-1: 변수와 상수
        let chapter1_1 = Chapter(
            id: UUID(uuidString: "33333333-3333-3333-3333-333333330101"),
            courseId: course1.id!,
            title: "변수와 상수",
            description: "데이터를 저장하는 기본적인 방법을 배웁니다.",
            order: 1
        )
        try await chapter1_1.save(on: database)

        // Lesson 1-1-1: 변수 선언하기
        let lesson1_1_1 = Lesson(
            id: UUID(uuidString: "44444444-4444-4444-4444-444444010101"),
            chapterId: chapter1_1.id!,
            title: "변수 선언하기",
            content: """
            # 변수란?

            **변수(Variable)**는 데이터를 저장하는 공간입니다. Swift에서는 `var` 키워드를 사용해 변수를 선언합니다.

            ```swift
            var name = "SwiftBoot"
            var age = 25
            ```

            변수는 이름처럼 **변할 수 있는 값**을 저장합니다. 나중에 다른 값으로 변경할 수 있어요.

            ```swift
            var score = 100
            score = 200  // 값 변경 가능!
            ```

            ## 타입 추론

            Swift는 할당된 값을 보고 자동으로 타입을 추론합니다:
            - `"SwiftBoot"` → String
            - `25` → Int
            - `3.14` → Double
            """,
            type: .reading,
            language: .swift,
            xpReward: 10,
            order: 1
        )
        try await lesson1_1_1.save(on: database)

        // Lesson 1-1-2: 변수 사용하기 (코드 연습)
        let lesson1_1_2 = Lesson(
            id: UUID(uuidString: "44444444-4444-4444-4444-444444010102"),
            chapterId: chapter1_1.id!,
            title: "변수 사용하기",
            content: """
            # 변수 선언 연습

            `greeting`이라는 변수를 만들고 `"Hello, Swift!"`를 저장한 후 출력하세요.
            """,
            type: .codeExercise,
            language: .swift,
            starterCode: """
            // greeting 변수를 선언하고 값을 할당하세요

            print(greeting)
            """,
            solutionCode: """
            var greeting = "Hello, Swift!"
            print(greeting)
            """,
            expectedOutput: "Hello, Swift!",
            xpReward: 25,
            order: 2
        )
        try await lesson1_1_2.save(on: database)

        // Lesson 1-1-3: 상수 이해하기
        let lesson1_1_3 = Lesson(
            id: UUID(uuidString: "44444444-4444-4444-4444-444444010103"),
            chapterId: chapter1_1.id!,
            title: "상수 이해하기",
            content: """
            # 상수란?

            **상수(Constant)**는 한 번 값을 할당하면 변경할 수 없는 저장 공간입니다.
            Swift에서는 `let` 키워드를 사용합니다.

            ```swift
            let pi = 3.14159
            let appName = "SwiftBoot"
            ```

            ## 왜 상수를 사용할까요?

            1. **안전성**: 실수로 값이 변경되는 것을 방지
            2. **가독성**: 이 값은 변하지 않는다는 의도 표현
            3. **성능**: 컴파일러 최적화 가능

            ```swift
            let maxScore = 100
            // maxScore = 200  // ❌ 에러! 상수는 변경 불가
            ```

            > 💡 **팁**: 값이 변하지 않는다면 항상 `let`을 사용하세요!
            """,
            type: .reading,
            language: .swift,
            xpReward: 10,
            order: 3
        )
        try await lesson1_1_3.save(on: database)

        // Lesson 1-1-4: let vs var 퀴즈
        let lesson1_1_4 = Lesson(
            id: UUID(uuidString: "44444444-4444-4444-4444-444444010104"),
            chapterId: chapter1_1.id!,
            title: "let vs var 퀴즈",
            content: """
            # 퀴즈

            다음 코드에서 에러가 발생하는 줄은?

            ```swift
            let name = "Swift"
            var version = 5
            name = "SwiftUI"    // Line 3
            version = 6         // Line 4
            ```
            """,
            type: .multipleChoice,
            language: .swift,
            xpReward: 15,
            order: 4
        )
        try await lesson1_1_4.save(on: database)

        // Chapter 1-2: 데이터 타입
        let chapter1_2 = Chapter(
            id: UUID(uuidString: "33333333-3333-3333-3333-333333330102"),
            courseId: course1.id!,
            title: "데이터 타입",
            description: "Swift의 기본 데이터 타입을 배웁니다.",
            order: 2
        )
        try await chapter1_2.save(on: database)

        // Lesson 1-2-1: 숫자 타입
        let lesson1_2_1 = Lesson(
            id: UUID(uuidString: "44444444-4444-4444-4444-444444010201"),
            chapterId: chapter1_2.id!,
            title: "숫자 타입",
            content: """
            # 숫자 타입

            Swift에서 숫자를 다루는 두 가지 기본 타입:

            ## Int (정수)
            소수점이 없는 숫자입니다.

            ```swift
            let age: Int = 25
            let count = 100  // 타입 추론
            ```

            ## Double (실수)
            소수점이 있는 숫자입니다.

            ```swift
            let pi: Double = 3.14159
            let price = 19.99  // 타입 추론
            ```

            ## 연산

            ```swift
            let sum = 10 + 5      // 15
            let diff = 10 - 5     // 5
            let product = 10 * 5  // 50
            let quotient = 10 / 3 // 3 (정수 나눗셈)
            let remainder = 10 % 3 // 1 (나머지)
            ```
            """,
            type: .reading,
            language: .swift,
            xpReward: 10,
            order: 1
        )
        try await lesson1_2_1.save(on: database)

        // Lesson 1-2-2: 문자열 다루기
        let lesson1_2_2 = Lesson(
            id: UUID(uuidString: "44444444-4444-4444-4444-444444010202"),
            chapterId: chapter1_2.id!,
            title: "문자열 연결하기",
            content: """
            # 문자열 보간법

            `firstName`과 `lastName`을 합쳐서 `fullName`을 만드세요.
            문자열 보간법 `\\(변수)`를 사용하세요.
            """,
            type: .codeExercise,
            language: .swift,
            starterCode: """
            let firstName = "Swift"
            let lastName = "Boot"

            // fullName을 만드세요 (예: "Swift Boot")

            print(fullName)
            """,
            solutionCode: """
            let firstName = "Swift"
            let lastName = "Boot"
            let fullName = "\\(firstName) \\(lastName)"
            print(fullName)
            """,
            expectedOutput: "Swift Boot",
            xpReward: 25,
            order: 2
        )
        try await lesson1_2_2.save(on: database)

        // Lesson 1-2-3: Bool 타입
        let lesson1_2_3 = Lesson(
            id: UUID(uuidString: "44444444-4444-4444-4444-444444010203"),
            chapterId: chapter1_2.id!,
            title: "Bool과 비교 연산",
            content: """
            # Bool 타입

            **Bool**은 `true` 또는 `false` 두 가지 값만 가질 수 있습니다.

            ```swift
            let isSwiftFun = true
            let isHard = false
            ```

            ## 비교 연산자

            비교 연산의 결과는 항상 Bool입니다.

            ```swift
            let a = 10
            let b = 5

            a > b   // true (크다)
            a < b   // false (작다)
            a >= b  // true (크거나 같다)
            a <= b  // false (작거나 같다)
            a == b  // false (같다)
            a != b  // true (다르다)
            ```

            ## 논리 연산자

            ```swift
            let sunny = true
            let warm = true

            sunny && warm  // true (AND: 둘 다 true)
            sunny || warm  // true (OR: 하나라도 true)
            !sunny         // false (NOT: 반대)
            ```
            """,
            type: .reading,
            language: .swift,
            xpReward: 10,
            order: 3
        )
        try await lesson1_2_3.save(on: database)

        // MARK: - Course 2: Swift 제어문
        let course2 = Course(
            id: UUID(uuidString: "22222222-2222-2222-2222-222222222202"),
            trackId: swiftTrack.id!,
            title: "Swift 제어문",
            description: "조건문과 반복문으로 프로그램 흐름을 제어합니다.",
            icon: "arrow.triangle.branch",
            difficulty: .beginner,
            order: 2,
            isPublished: true,
            prerequisiteId: course1.id
        )
        try await course2.save(on: database)

        // Chapter 2-1: 조건문
        let chapter2_1 = Chapter(
            id: UUID(uuidString: "33333333-3333-3333-3333-333333330201"),
            courseId: course2.id!,
            title: "조건문",
            description: "if, else, switch로 조건에 따라 다른 코드를 실행합니다.",
            order: 1
        )
        try await chapter2_1.save(on: database)

        // Lesson 2-1-1: if 문
        let lesson2_1_1 = Lesson(
            id: UUID(uuidString: "44444444-4444-4444-4444-444444020101"),
            chapterId: chapter2_1.id!,
            title: "if 문 이해하기",
            content: """
            # if 문

            조건이 `true`일 때만 코드를 실행합니다.

            ```swift
            let score = 85

            if score >= 90 {
                print("A등급")
            } else if score >= 80 {
                print("B등급")
            } else if score >= 70 {
                print("C등급")
            } else {
                print("재시험")
            }
            ```

            ## 문법

            ```swift
            if 조건 {
                // 조건이 true일 때 실행
            } else {
                // 조건이 false일 때 실행
            }
            ```

            > Swift에서는 조건에 괄호 `()`가 필요 없습니다!
            """,
            type: .reading,
            language: .swift,
            xpReward: 10,
            order: 1
        )
        try await lesson2_1_1.save(on: database)

        // Lesson 2-1-2: 조건문 연습
        let lesson2_1_2 = Lesson(
            id: UUID(uuidString: "44444444-4444-4444-4444-444444020102"),
            chapterId: chapter2_1.id!,
            title: "성인 여부 확인하기",
            content: """
            # 조건문 연습

            `age`가 18 이상이면 "성인입니다", 미만이면 "미성년자입니다"를 출력하세요.
            """,
            type: .codeExercise,
            language: .swift,
            starterCode: """
            let age = 20

            // if문을 사용해 성인 여부를 출력하세요

            """,
            solutionCode: """
            let age = 20

            if age >= 18 {
                print("성인입니다")
            } else {
                print("미성년자입니다")
            }
            """,
            expectedOutput: "성인입니다",
            xpReward: 25,
            order: 2
        )
        try await lesson2_1_2.save(on: database)

        // Chapter 2-2: 반복문
        let chapter2_2 = Chapter(
            id: UUID(uuidString: "33333333-3333-3333-3333-333333330202"),
            courseId: course2.id!,
            title: "반복문",
            description: "for, while로 코드를 반복 실행합니다.",
            order: 2
        )
        try await chapter2_2.save(on: database)

        // Lesson 2-2-1: for 문
        let lesson2_2_1 = Lesson(
            id: UUID(uuidString: "44444444-4444-4444-4444-444444020201"),
            chapterId: chapter2_2.id!,
            title: "for-in 반복문",
            content: """
            # for-in 문

            범위나 컬렉션의 각 요소에 대해 코드를 반복합니다.

            ```swift
            // 1부터 5까지 출력
            for i in 1...5 {
                print(i)
            }
            ```

            ## 범위 연산자

            - `1...5` : 1, 2, 3, 4, 5 (닫힌 범위)
            - `1..<5` : 1, 2, 3, 4 (반 열린 범위)

            ## 배열 순회

            ```swift
            let fruits = ["사과", "바나나", "오렌지"]

            for fruit in fruits {
                print(fruit)
            }
            ```
            """,
            type: .reading,
            language: .swift,
            xpReward: 10,
            order: 1
        )
        try await lesson2_2_1.save(on: database)

        // Lesson 2-2-2: 반복문 연습
        let lesson2_2_2 = Lesson(
            id: UUID(uuidString: "44444444-4444-4444-4444-444444020202"),
            chapterId: chapter2_2.id!,
            title: "1부터 5까지 합 구하기",
            content: """
            # 반복문 연습

            for 문을 사용해 1부터 5까지의 합을 구하고 출력하세요.
            """,
            type: .codeExercise,
            language: .swift,
            starterCode: """
            var sum = 0

            // for문으로 1부터 5까지 더하세요

            print(sum)
            """,
            solutionCode: """
            var sum = 0

            for i in 1...5 {
                sum += i
            }

            print(sum)
            """,
            expectedOutput: "15",
            xpReward: 25,
            order: 2
        )
        try await lesson2_2_2.save(on: database)
    }

    func revert(on database: Database) async throws {
        // 역순으로 삭제
        try await Lesson.query(on: database).delete()
        try await Chapter.query(on: database).delete()
        try await Course.query(on: database).delete()
        try await Track.query(on: database).delete()
    }
}
