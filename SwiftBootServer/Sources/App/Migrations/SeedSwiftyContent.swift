import Fluent
import Vapor

/// Course: "Swifty 만들기" - AI 챗봇을 만들며 Swift 기초 배우기
struct SeedSwiftyContent: AsyncMigration {
    func prepare(on database: Database) async throws {
        // 기존 Track 조회
        guard let swiftTrack = try await Track.query(on: database)
            .filter(\.$id == UUID(uuidString: "11111111-1111-1111-1111-111111111111")!)
            .first() else {
            throw Abort(.internalServerError, reason: "Swift Track not found")
        }

        // MARK: - Course: Swifty 만들기
        let swiftyCourse = Course(
            id: UUID(uuidString: "22222222-2222-2222-2222-222222222210"),
            trackId: swiftTrack.id!,
            title: "Swifty 만들기",
            description: "나만의 AI 챗봇 'Swifty'를 만들며 Swift 기초를 배웁니다. 매 레슨마다 Swifty에게 새로운 능력을 부여하세요!",
            icon: "bubble.left.and.bubble.right",
            difficulty: .beginner,
            order: 0,  // 첫 번째 코스로 설정
            isPublished: true
        )
        try await swiftyCourse.save(on: database)

        // MARK: - Chapter 1: Swifty 깨우기
        let chapter1 = Chapter(
            id: UUID(uuidString: "33333333-3333-3333-3333-333333331001"),
            courseId: swiftyCourse.id!,
            title: "Swifty 깨우기",
            description: "Swifty가 말을 하고, 이름을 기억하게 만듭니다.",
            order: 1
        )
        try await chapter1.save(on: database)

        // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        // MARK: Lesson 1: Swifty의 첫 마디
        // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        let lesson1 = Lesson(
            id: UUID(uuidString: "44444444-4444-4444-4444-444444100101"),
            chapterId: chapter1.id!,
            title: "Swifty의 첫 마디",
            content: """
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
            """,
            type: .codeExercise,
            language: .swift,
            starterCode: """
            // Swifty가 인사하게 만드세요

            """,
            solutionCode: """
            print("안녕하세요! 저는 Swifty입니다.")
            """,
            expectedOutput: "안녕하세요! 저는 Swifty입니다.",
            xpReward: 20,
            order: 1
        )
        try await lesson1.save(on: database)

        // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        // MARK: Lesson 2: 이름 기억하기
        // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        let lesson2 = Lesson(
            id: UUID(uuidString: "44444444-4444-4444-4444-444444100102"),
            chapterId: chapter1.id!,
            title: "이름 기억하기",
            content: """
            # 🧠 Swifty에게 기억력 부여하기

            Swifty가 인사는 할 수 있게 되었지만, 사용자의 이름을 기억하지 못합니다.
            **변수(Variable)**를 사용하면 데이터를 저장할 수 있어요!

            ---

            ## 📚 변수와 문자열 보간

            `var` 키워드로 변수를 만들고, `\\(변수명)`으로 문자열 안에 변수를 넣습니다.

            ```swift
            var name = "철수"
            print("안녕, \\(name)!")
            // 출력: 안녕, 철수!
            ```

            ---

            ## 🎯 미션

            사용자 이름을 저장하고, Swifty가 그 이름을 불러 인사하게 만드세요.
            출력 형식: `안녕하세요, [이름]님! 만나서 반가워요.`
            """,
            type: .codeExercise,
            language: .swift,
            starterCode: """
            // 1. userName 변수에 "민수" 저장

            // 2. Swifty가 이름을 불러 인사하게 만드세요
            // 출력: "안녕하세요, 민수님! 만나서 반가워요."

            """,
            solutionCode: """
            var userName = "민수"
            print("안녕하세요, \\(userName)님! 만나서 반가워요.")
            """,
            expectedOutput: "안녕하세요, 민수님! 만나서 반가워요.",
            xpReward: 25,
            order: 2
        )
        try await lesson2.save(on: database)

        // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        // MARK: Lesson 3: 나이 계산기
        // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        let lesson3 = Lesson(
            id: UUID(uuidString: "44444444-4444-4444-4444-444444100103"),
            chapterId: chapter1.id!,
            title: "나이 계산기",
            content: """
            # 🔢 Swifty의 계산 능력

            사용자가 "몇 살이야?"라고 물으면 Swifty가 태어난 연도를 계산해주면 좋겠죠?
            **숫자 타입**과 **연산**을 배워봅시다.

            ---

            ## 📚 Int 타입과 연산자

            `Int`는 정수(소수점 없는 숫자)를 저장합니다.

            ```swift
            let currentYear = 2025
            let age = 25
            let birthYear = currentYear - age
            print(birthYear)  // 2000
            ```

            **연산자**: `+` (더하기), `-` (빼기), `*` (곱하기), `/` (나누기)

            ---

            ## 🎯 미션

            사용자 나이가 20살일 때, 태어난 연도를 계산해서 출력하세요.
            현재 연도는 2025년입니다.
            출력 형식: `당신은 [연도]년에 태어났군요!`
            """,
            type: .codeExercise,
            language: .swift,
            starterCode: """
            let currentYear = 2025
            let userAge = 20

            // birthYear를 계산하세요

            // 출력: "당신은 2005년에 태어났군요!"

            """,
            solutionCode: """
            let currentYear = 2025
            let userAge = 20
            let birthYear = currentYear - userAge
            print("당신은 \\(birthYear)년에 태어났군요!")
            """,
            expectedOutput: "당신은 2005년에 태어났군요!",
            xpReward: 25,
            order: 3
        )
        try await lesson3.save(on: database)

        // MARK: - Chapter 2: Swifty의 판단력
        let chapter2 = Chapter(
            id: UUID(uuidString: "33333333-3333-3333-3333-333333331002"),
            courseId: swiftyCourse.id!,
            title: "Swifty의 판단력",
            description: "Swifty가 상황에 따라 다르게 반응하게 만듭니다.",
            order: 2
        )
        try await chapter2.save(on: database)

        // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        // MARK: Lesson 4: 성격 테스트
        // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        let lesson4 = Lesson(
            id: UUID(uuidString: "44444444-4444-4444-4444-444444100201"),
            chapterId: chapter2.id!,
            title: "성격 테스트",
            content: """
            # 🎭 Swifty의 조건부 반응

            Swifty가 사용자의 상태에 따라 다르게 반응하면 더 똑똑해 보이겠죠?
            **if문**을 사용하면 조건에 따라 다른 코드를 실행할 수 있습니다.

            ---

            ## 📚 if-else 문

            ```swift
            let mood = "happy"

            if mood == "happy" {
                print("좋은 하루네요! 😊")
            } else {
                print("무슨 일 있어요? 🤔")
            }
            ```

            **비교 연산자**: `==` (같다), `!=` (다르다), `>`, `<`, `>=`, `<=`

            ---

            ## 🎯 미션

            사용자 점수가 80점 이상이면 `"축하해요! 합격입니다! 🎉"`
            미만이면 `"아쉽네요. 다음에 도전하세요!"` 를 출력하세요.
            """,
            type: .codeExercise,
            language: .swift,
            starterCode: """
            let score = 85

            // if문으로 합격/불합격 메시지를 출력하세요

            """,
            solutionCode: """
            let score = 85

            if score >= 80 {
                print("축하해요! 합격입니다! 🎉")
            } else {
                print("아쉽네요. 다음에 도전하세요!")
            }
            """,
            expectedOutput: "축하해요! 합격입니다! 🎉",
            xpReward: 30,
            order: 1
        )
        try await lesson4.save(on: database)

        // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        // MARK: Lesson 5: 명령어 파서
        // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        let lesson5 = Lesson(
            id: UUID(uuidString: "44444444-4444-4444-4444-444444100202"),
            chapterId: chapter2.id!,
            title: "명령어 파서",
            content: """
            # 🎮 Swifty 명령어 시스템

            Swifty가 여러 명령어를 이해하게 만들어봅시다!
            여러 조건을 깔끔하게 처리하려면 **switch문**이 좋습니다.

            ---

            ## 📚 switch 문

            ```swift
            let command = "날씨"

            switch command {
            case "인사":
                print("안녕하세요!")
            case "날씨":
                print("오늘 날씨는 맑음이에요 ☀️")
            case "시간":
                print("지금은 오후 3시입니다")
            default:
                print("알 수 없는 명령어예요")
            }
            ```

            `default`는 어떤 case에도 해당하지 않을 때 실행됩니다.

            ---

            ## 🎯 미션

            명령어가 `"도움말"`이면 `"사용 가능한 명령어: 인사, 날씨, 시간"`
            `"인사"`면 `"안녕하세요! Swifty입니다."`
            `"종료"`면 `"안녕히 가세요! 👋"`
            그 외에는 `"알 수 없는 명령어입니다."` 를 출력하세요.
            """,
            type: .codeExercise,
            language: .swift,
            starterCode: """
            let command = "도움말"

            // switch문으로 명령어를 처리하세요

            """,
            solutionCode: """
            let command = "도움말"

            switch command {
            case "도움말":
                print("사용 가능한 명령어: 인사, 날씨, 시간")
            case "인사":
                print("안녕하세요! Swifty입니다.")
            case "종료":
                print("안녕히 가세요! 👋")
            default:
                print("알 수 없는 명령어입니다.")
            }
            """,
            expectedOutput: "사용 가능한 명령어: 인사, 날씨, 시간",
            xpReward: 30,
            order: 2
        )
        try await lesson5.save(on: database)

        // MARK: - Chapter 3: Swifty의 기억 저장소
        let chapter3 = Chapter(
            id: UUID(uuidString: "33333333-3333-3333-3333-333333331003"),
            courseId: swiftyCourse.id!,
            title: "Swifty의 기억 저장소",
            description: "Swifty가 여러 정보를 저장하고 관리하게 만듭니다.",
            order: 3
        )
        try await chapter3.save(on: database)

        // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        // MARK: Lesson 6: 대화 저장소
        // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        let lesson6 = Lesson(
            id: UUID(uuidString: "44444444-4444-4444-4444-444444100301"),
            chapterId: chapter3.id!,
            title: "대화 저장소",
            content: """
            # 📝 Swifty의 대화 기록

            Swifty가 이전 대화를 기억하면 더 자연스러운 대화가 가능해요!
            여러 데이터를 순서대로 저장하려면 **Array(배열)**을 사용합니다.

            ---

            ## 📚 Array 기초

            ```swift
            var messages = ["안녕", "반가워", "오늘 뭐해?"]

            // 요소 접근 (0부터 시작)
            print(messages[0])  // "안녕"

            // 요소 추가
            messages.append("잘가!")

            // 개수 확인
            print(messages.count)  // 4
            ```

            ---

            ## 🎯 미션

            대화 기록 배열에서 마지막 메시지와 총 대화 수를 출력하세요.
            출력 형식:
            ```
            마지막 대화: [메시지]
            총 대화 수: [개수]개
            ```
            """,
            type: .codeExercise,
            language: .swift,
            starterCode: """
            var chatHistory = ["안녕하세요", "오늘 날씨 어때요?", "좋은 하루 되세요"]

            // 마지막 메시지 출력 (힌트: chatHistory.count - 1)

            // 총 대화 수 출력

            """,
            solutionCode: """
            var chatHistory = ["안녕하세요", "오늘 날씨 어때요?", "좋은 하루 되세요"]

            let lastMessage = chatHistory[chatHistory.count - 1]
            print("마지막 대화: \\(lastMessage)")
            print("총 대화 수: \\(chatHistory.count)개")
            """,
            expectedOutput: """
            마지막 대화: 좋은 하루 되세요
            총 대화 수: 3개
            """,
            xpReward: 30,
            order: 1
        )
        try await lesson6.save(on: database)

        // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        // MARK: Lesson 7: 단어 사전
        // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        let lesson7 = Lesson(
            id: UUID(uuidString: "44444444-4444-4444-4444-444444100302"),
            chapterId: chapter3.id!,
            title: "단어 사전",
            content: """
            # 📖 Swifty의 지식 베이스

            Swifty가 특정 단어에 대해 정의를 알려주면 좋겠죠?
            **Dictionary(딕셔너리)**를 사용하면 키-값 쌍으로 데이터를 저장할 수 있습니다.

            ---

            ## 📚 Dictionary 기초

            ```swift
            var dictionary = [
                "Swift": "Apple이 만든 프로그래밍 언어",
                "iOS": "iPhone 운영체제"
            ]

            // 값 조회
            if let definition = dictionary["Swift"] {
                print(definition)
            }

            // 값 추가/수정
            dictionary["macOS"] = "Mac 운영체제"
            ```

            `[키: 값]` 형태로 저장하고, `dictionary[키]`로 조회합니다.

            ---

            ## 🎯 미션

            사용자가 물어본 단어 "변수"의 정의를 출력하세요.
            없는 단어면 `"해당 단어를 찾을 수 없어요."`를 출력하세요.
            """,
            type: .codeExercise,
            language: .swift,
            starterCode: """
            let swiftyDictionary = [
                "변수": "값을 저장하는 공간 (var)",
                "상수": "변하지 않는 값 (let)",
                "함수": "재사용 가능한 코드 블록"
            ]

            let searchWord = "변수"

            // searchWord의 정의를 출력하세요
            // 없으면 "해당 단어를 찾을 수 없어요." 출력

            """,
            solutionCode: """
            let swiftyDictionary = [
                "변수": "값을 저장하는 공간 (var)",
                "상수": "변하지 않는 값 (let)",
                "함수": "재사용 가능한 코드 블록"
            ]

            let searchWord = "변수"

            if let definition = swiftyDictionary[searchWord] {
                print("\\(searchWord): \\(definition)")
            } else {
                print("해당 단어를 찾을 수 없어요.")
            }
            """,
            expectedOutput: "변수: 값을 저장하는 공간 (var)",
            xpReward: 35,
            order: 2
        )
        try await lesson7.save(on: database)

        // MARK: - Chapter 4: Swifty 고급 기능
        let chapter4 = Chapter(
            id: UUID(uuidString: "33333333-3333-3333-3333-333333331004"),
            courseId: swiftyCourse.id!,
            title: "Swifty 고급 기능",
            description: "반복과 함수로 Swifty를 더 강력하게 만듭니다.",
            order: 4
        )
        try await chapter4.save(on: database)

        // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        // MARK: Lesson 8: 반복 인사
        // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        let lesson8 = Lesson(
            id: UUID(uuidString: "44444444-4444-4444-4444-444444100401"),
            chapterId: chapter4.id!,
            title: "반복 인사",
            content: """
            # 🔄 Swifty의 반복 능력

            여러 사용자에게 한 번에 인사하려면? **for-in 반복문**을 사용하세요!

            ---

            ## 📚 for-in 반복문

            ```swift
            let fruits = ["🍎", "🍌", "🍊"]

            for fruit in fruits {
                print("\\(fruit) 맛있다!")
            }
            // 🍎 맛있다!
            // 🍌 맛있다!
            // 🍊 맛있다!
            ```

            배열의 각 요소를 순서대로 처리합니다.

            ---

            ## 🎯 미션

            Swifty가 사용자 목록의 모든 사람에게 인사하게 만드세요.
            출력 형식: `안녕하세요, [이름]님!`
            """,
            type: .codeExercise,
            language: .swift,
            starterCode: """
            let users = ["민수", "영희", "철수"]

            // for문으로 모든 사용자에게 인사하세요

            """,
            solutionCode: """
            let users = ["민수", "영희", "철수"]

            for user in users {
                print("안녕하세요, \\(user)님!")
            }
            """,
            expectedOutput: """
            안녕하세요, 민수님!
            안녕하세요, 영희님!
            안녕하세요, 철수님!
            """,
            xpReward: 30,
            order: 1
        )
        try await lesson8.save(on: database)

        // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        // MARK: Lesson 9: 계산기 기능
        // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        let lesson9 = Lesson(
            id: UUID(uuidString: "44444444-4444-4444-4444-444444100402"),
            chapterId: chapter4.id!,
            title: "계산기 기능",
            content: """
            # 🧮 Swifty 계산기

            Swifty에게 계산 기능을 추가합니다!
            **함수(Function)**를 사용하면 재사용 가능한 코드 블록을 만들 수 있어요.

            ---

            ## 📚 함수 정의와 호출

            ```swift
            // 함수 정의
            func greet(name: String) -> String {
                return "안녕, \\(name)!"
            }

            // 함수 호출
            let message = greet(name: "민수")
            print(message)  // "안녕, 민수!"
            ```

            - `func` 키워드로 함수 선언
            - `->` 뒤에 반환 타입 지정
            - `return`으로 값 반환

            ---

            ## 🎯 미션

            두 숫자를 더하는 `add` 함수를 완성하고, 결과를 출력하세요.
            출력 형식: `[a] + [b] = [결과]`
            """,
            type: .codeExercise,
            language: .swift,
            starterCode: """
            // add 함수를 완성하세요
            func add(a: Int, b: Int) -> Int {
                // 두 수의 합을 반환하세요

            }

            let result = add(a: 15, b: 27)
            print("15 + 27 = \\(result)")
            """,
            solutionCode: """
            func add(a: Int, b: Int) -> Int {
                return a + b
            }

            let result = add(a: 15, b: 27)
            print("15 + 27 = \\(result)")
            """,
            expectedOutput: "15 + 27 = 42",
            xpReward: 35,
            order: 2
        )
        try await lesson9.save(on: database)

        // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        // MARK: Lesson 10: Swifty 완성!
        // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        let lesson10 = Lesson(
            id: UUID(uuidString: "44444444-4444-4444-4444-444444100403"),
            chapterId: chapter4.id!,
            title: "Swifty 완성!",
            content: """
            # 🎉 Swifty 최종 테스트

            축하합니다! 지금까지 배운 모든 것을 활용해 Swifty를 완성합니다.

            Swifty는 이제:
            - ✅ 인사할 수 있고
            - ✅ 이름을 기억하고
            - ✅ 계산하고
            - ✅ 명령어를 처리할 수 있습니다!

            ---

            ## 🎯 최종 미션

            `processCommand` 함수를 완성하세요:

            - `"인사"` → `"안녕하세요! Swifty입니다."`
            - `"더하기"` → 10 + 20 계산 후 `"결과: 30"`
            - `"목록"` → users 배열의 모든 이름을 한 줄에 출력 `"사용자: 민수, 영희, 철수"`
            - 그 외 → `"알 수 없는 명령어입니다."`
            """,
            type: .codeExercise,
            language: .swift,
            starterCode: """
            let users = ["민수", "영희", "철수"]

            func processCommand(_ command: String) -> String {
                // switch문으로 명령어를 처리하세요

            }

            // 테스트
            print(processCommand("인사"))
            print(processCommand("더하기"))
            print(processCommand("목록"))
            """,
            solutionCode: """
            let users = ["민수", "영희", "철수"]

            func processCommand(_ command: String) -> String {
                switch command {
                case "인사":
                    return "안녕하세요! Swifty입니다."
                case "더하기":
                    let result = 10 + 20
                    return "결과: \\(result)"
                case "목록":
                    return "사용자: \\(users.joined(separator: ", "))"
                default:
                    return "알 수 없는 명령어입니다."
                }
            }

            print(processCommand("인사"))
            print(processCommand("더하기"))
            print(processCommand("목록"))
            """,
            expectedOutput: """
            안녕하세요! Swifty입니다.
            결과: 30
            사용자: 민수, 영희, 철수
            """,
            xpReward: 50,
            order: 3
        )
        try await lesson10.save(on: database)
    }

    func revert(on database: Database) async throws {
        // Course ID로 관련 데이터 삭제
        let courseId = UUID(uuidString: "22222222-2222-2222-2222-222222222210")!

        // Chapters 조회
        let chapters = try await Chapter.query(on: database)
            .filter(\.$course.$id == courseId)
            .all()

        // 각 Chapter의 Lessons 삭제
        for chapter in chapters {
            try await Lesson.query(on: database)
                .filter(\.$chapter.$id == chapter.id!)
                .delete()
        }

        // Chapters 삭제
        try await Chapter.query(on: database)
            .filter(\.$course.$id == courseId)
            .delete()

        // Course 삭제
        try await Course.query(on: database)
            .filter(\.$id == courseId)
            .delete()
    }
}
