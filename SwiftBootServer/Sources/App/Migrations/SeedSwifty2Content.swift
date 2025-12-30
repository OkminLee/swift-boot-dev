import Fluent
import Vapor

/// Course: "Swifty 2.0 - AI 업그레이드" - 중급 Swift 개념 학습
struct SeedSwifty2Content: AsyncMigration {
    func prepare(on database: Database) async throws {
        // 기존 Track 조회
        guard let swiftTrack = try await Track.query(on: database)
            .filter(\.$id == UUID(uuidString: "11111111-1111-1111-1111-111111111111")!)
            .first() else {
            throw Abort(.internalServerError, reason: "Swift Track not found")
        }

        // 기존 Swifty 만들기 코스 ID (선행 조건)
        let swifty1CourseId = UUID(uuidString: "22222222-2222-2222-2222-222222222210")!

        // MARK: - Course: Swifty 2.0 - AI 업그레이드
        let swifty2Course = Course(
            id: UUID(uuidString: "22222222-2222-2222-2222-222222222220"),
            trackId: swiftTrack.id!,
            title: "Swifty 2.0 - AI 업그레이드",
            description: "Swifty가 더 똑똑해집니다! 감정을 이해하고, 설정을 기억하고, 새로운 것을 학습하는 진정한 AI 비서로 업그레이드하세요.",
            icon: "brain.head.profile",
            difficulty: .intermediate,
            order: 1,
            isPublished: true,
            prerequisiteId: swifty1CourseId
        )
        try await swifty2Course.save(on: database)

        // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        // MARK: - Chapter 1: Swifty 감정 시스템
        // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        let chapter1 = Chapter(
            id: UUID(uuidString: "33333333-3333-3333-3333-333333332001"),
            courseId: swifty2Course.id!,
            title: "Swifty 감정 시스템",
            description: "Swifty가 사용자의 감정을 인식하고 적절히 반응합니다.",
            order: 1
        )
        try await chapter1.save(on: database)

        // Lesson 1-1: 감정 타입 정의하기
        let lesson1_1 = Lesson(
            id: UUID(uuidString: "44444444-4444-4444-4444-444444200101"),
            chapterId: chapter1.id!,
            title: "감정 타입 정의하기",
            content: """
            # 😊 Swifty 2.0: 감정 인식 기능

            Swifty 1.0은 사용자가 무슨 말을 해도 똑같이 반응했어요.
            2.0에서는 사용자의 **감정**을 인식해 다르게 반응합니다!

            ---

            ## 📚 Enum (열거형)

            **정해진 값들 중 하나**만 가질 수 있는 타입입니다.

            ```swift
            enum Weather {
                case sunny
                case cloudy
                case rainy
            }

            let today: Weather = .sunny
            ```

            감정처럼 **제한된 선택지**가 있을 때 완벽합니다!

            ---

            ## 🎯 미션

            사용자 감정을 나타내는 `Emotion` enum을 정의하세요.
            - happy, sad, angry, neutral 4가지 케이스 포함

            그리고 `userEmotion` 변수에 `.happy`를 할당 후 출력하세요.
            """,
            type: .codeExercise,
            language: .swift,
            starterCode: """
            // Emotion enum을 정의하세요


            // userEmotion에 happy 할당


            print(userEmotion)
            """,
            solutionCode: """
            enum Emotion {
                case happy
                case sad
                case angry
                case neutral
            }

            let userEmotion: Emotion = .happy
            print(userEmotion)
            """,
            expectedOutput: "happy",
            xpReward: 25,
            order: 1
        )
        try await lesson1_1.save(on: database)

        // Lesson 1-2: 감정별 응답 만들기
        let lesson1_2 = Lesson(
            id: UUID(uuidString: "44444444-4444-4444-4444-444444200102"),
            chapterId: chapter1.id!,
            title: "감정별 응답 만들기",
            content: """
            # 🎭 감정에 따른 반응

            Swifty가 사용자 감정에 맞게 다르게 대답해야 합니다.
            `switch`문으로 각 감정에 맞는 응답을 만들어보세요!

            ---

            ## 📚 Enum과 Switch

            enum의 모든 케이스를 처리할 때 switch가 완벽합니다.

            ```swift
            enum Direction {
                case north, south, east, west
            }

            let dir = Direction.north

            switch dir {
            case .north:
                print("북쪽으로 이동")
            case .south:
                print("남쪽으로 이동")
            case .east:
                print("동쪽으로 이동")
            case .west:
                print("서쪽으로 이동")
            }
            ```

            Swift는 모든 케이스를 처리하지 않으면 **컴파일 에러**를 냅니다!

            ---

            ## 🎯 미션

            `getResponse` 함수를 완성하세요:
            - happy → "기분이 좋아 보이네요! 😊"
            - sad → "무슨 일 있어요? 제가 도와드릴게요. 🤗"
            - angry → "진정하세요. 심호흡 한번 해볼까요? 🧘"
            - neutral → "무엇을 도와드릴까요?"
            """,
            type: .codeExercise,
            language: .swift,
            starterCode: """
            enum Emotion {
                case happy, sad, angry, neutral
            }

            func getResponse(for emotion: Emotion) -> String {
                // switch문으로 감정별 응답을 반환하세요

            }

            let response = getResponse(for: .sad)
            print(response)
            """,
            solutionCode: """
            enum Emotion {
                case happy, sad, angry, neutral
            }

            func getResponse(for emotion: Emotion) -> String {
                switch emotion {
                case .happy:
                    return "기분이 좋아 보이네요! 😊"
                case .sad:
                    return "무슨 일 있어요? 제가 도와드릴게요. 🤗"
                case .angry:
                    return "진정하세요. 심호흡 한번 해볼까요? 🧘"
                case .neutral:
                    return "무엇을 도와드릴까요?"
                }
            }

            let response = getResponse(for: .sad)
            print(response)
            """,
            expectedOutput: "무슨 일 있어요? 제가 도와드릴게요. 🤗",
            xpReward: 30,
            order: 2
        )
        try await lesson1_2.save(on: database)

        // Lesson 1-3: 감정 강도 추가하기
        let lesson1_3 = Lesson(
            id: UUID(uuidString: "44444444-4444-4444-4444-444444200103"),
            chapterId: chapter1.id!,
            title: "감정 강도 추가하기",
            content: """
            # 📊 감정의 강도

            "조금 슬픔"과 "매우 슬픔"은 다르게 대응해야 합니다!
            Enum에 **연관 값(Associated Value)**을 추가하면 추가 정보를 저장할 수 있어요.

            ---

            ## 📚 Associated Values

            enum 케이스에 추가 데이터를 붙일 수 있습니다.

            ```swift
            enum Barcode {
                case upc(Int, Int, Int, Int)
                case qrCode(String)
            }

            let productCode = Barcode.upc(8, 85909, 51226, 3)
            let webCode = Barcode.qrCode("https://swiftboot.dev")
            ```

            ---

            ## 🎯 미션

            감정에 강도(1~10)를 추가한 `DetailedEmotion` enum을 만드세요.
            강도가 7 이상이면 강한 반응, 미만이면 일반 반응을 출력하세요.

            힌트: `case happy(intensity: Int)` 형태로 정의
            """,
            type: .codeExercise,
            language: .swift,
            starterCode: """
            // DetailedEmotion enum 정의 (happy, sad에 intensity 추가)


            func analyzeEmotion(_ emotion: DetailedEmotion) {
                switch emotion {
                case .happy(let intensity):
                    // intensity가 7 이상이면 "강한 행복이 느껴져요! 🎉"
                    // 미만이면 "기분이 좋으시군요 😊"

                case .sad(let intensity):
                    // intensity가 7 이상이면 "많이 힘드시겠어요... 💙"
                    // 미만이면 "조금 우울하시군요 🤗"

                }
            }

            analyzeEmotion(.sad(intensity: 8))
            """,
            solutionCode: """
            enum DetailedEmotion {
                case happy(intensity: Int)
                case sad(intensity: Int)
            }

            func analyzeEmotion(_ emotion: DetailedEmotion) {
                switch emotion {
                case .happy(let intensity):
                    if intensity >= 7 {
                        print("강한 행복이 느껴져요! 🎉")
                    } else {
                        print("기분이 좋으시군요 😊")
                    }
                case .sad(let intensity):
                    if intensity >= 7 {
                        print("많이 힘드시겠어요... 💙")
                    } else {
                        print("조금 우울하시군요 🤗")
                    }
                }
            }

            analyzeEmotion(.sad(intensity: 8))
            """,
            expectedOutput: "많이 힘드시겠어요... 💙",
            xpReward: 35,
            order: 3
        )
        try await lesson1_3.save(on: database)

        // Lesson 1-4: 사용자 프로필 만들기
        let lesson1_4 = Lesson(
            id: UUID(uuidString: "44444444-4444-4444-4444-444444200104"),
            chapterId: chapter1.id!,
            title: "사용자 프로필 만들기",
            content: """
            # 👤 Swifty의 사용자 기억

            Swifty가 사용자 정보를 기억하려면 **여러 데이터를 하나로 묶어야** 합니다.
            `struct`로 사용자 프로필을 만들어봅시다!

            ---

            ## 📚 Struct (구조체)

            관련 데이터를 하나로 묶는 **사용자 정의 타입**입니다.

            ```swift
            struct Person {
                let name: String
                var age: Int
            }

            var user = Person(name: "민수", age: 25)
            print(user.name)  // "민수"
            user.age = 26     // 변경 가능 (var)
            ```

            **Memberwise Initializer**: Swift가 자동으로 생성자를 만들어줍니다!

            ---

            ## 🎯 미션

            `UserProfile` struct를 만들고 사용자 정보를 출력하세요:
            - name: String
            - currentEmotion: Emotion
            - messageCount: Int

            출력 형식: "[이름]님 (메시지 [N]개) - 현재 기분: [감정]"
            """,
            type: .codeExercise,
            language: .swift,
            starterCode: """
            enum Emotion {
                case happy, sad, angry, neutral
            }

            // UserProfile struct를 정의하세요


            let user = UserProfile(name: "영희", currentEmotion: .happy, messageCount: 42)

            // 출력: "영희님 (메시지 42개) - 현재 기분: happy"

            """,
            solutionCode: """
            enum Emotion {
                case happy, sad, angry, neutral
            }

            struct UserProfile {
                let name: String
                var currentEmotion: Emotion
                var messageCount: Int
            }

            let user = UserProfile(name: "영희", currentEmotion: .happy, messageCount: 42)
            print("\\(user.name)님 (메시지 \\(user.messageCount)개) - 현재 기분: \\(user.currentEmotion)")
            """,
            expectedOutput: "영희님 (메시지 42개) - 현재 기분: happy",
            xpReward: 30,
            order: 4
        )
        try await lesson1_4.save(on: database)

        // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        // MARK: - Chapter 2: Swifty 설정 시스템
        // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        let chapter2 = Chapter(
            id: UUID(uuidString: "33333333-3333-3333-3333-333333332002"),
            courseId: swifty2Course.id!,
            title: "Swifty 설정 시스템",
            description: "사용자 설정을 저장하고 안전하게 불러옵니다.",
            order: 2
        )
        try await chapter2.save(on: database)

        // Lesson 2-1: 선택적 설정값
        let lesson2_1 = Lesson(
            id: UUID(uuidString: "44444444-4444-4444-4444-444444200201"),
            chapterId: chapter2.id!,
            title: "선택적 설정값",
            content: """
            # ⚙️ Swifty 설정 화면

            사용자마다 설정이 다릅니다. 어떤 사용자는 닉네임을 설정했고,
            어떤 사용자는 아직 설정하지 않았어요.

            **"값이 있거나 없을 수 있다"**를 표현하는 게 **Optional**입니다!

            ---

            ## 📚 Optional이란?

            `?`를 붙이면 "이 값은 없을 수도 있다"는 뜻입니다.

            ```swift
            var nickname: String? = nil    // 값 없음
            nickname = "코딩왕"             // 값 있음

            var age: Int? = 25             // 값 있음
            age = nil                      // 값 없앰
            ```

            **nil** = "값이 없음"을 나타내는 특별한 값

            ---

            ## 🎯 미션

            설정 값들을 Optional로 선언하고,
            닉네임이 설정되어 있는지 확인하는 조건문을 작성하세요.
            """,
            type: .codeExercise,
            language: .swift,
            starterCode: """
            // Optional로 설정값 선언
            var userNickname: String? = "Swift마스터"
            var userAge: Int? = nil
            var notificationEnabled: Bool? = true

            // userNickname이 nil인지 확인
            // nil이면: "닉네임을 설정해주세요."
            // nil이 아니면: "닉네임: [값]"

            """,
            solutionCode: """
            var userNickname: String? = "Swift마스터"
            var userAge: Int? = nil
            var notificationEnabled: Bool? = true

            if userNickname != nil {
                print("닉네임: \\(userNickname!)")
            } else {
                print("닉네임을 설정해주세요.")
            }
            """,
            expectedOutput: "닉네임: Swift마스터",
            xpReward: 25,
            order: 1
        )
        try await lesson2_1.save(on: database)

        // Lesson 2-2: 안전하게 값 꺼내기
        let lesson2_2 = Lesson(
            id: UUID(uuidString: "44444444-4444-4444-4444-444444200202"),
            chapterId: chapter2.id!,
            title: "안전하게 값 꺼내기",
            content: """
            # 🔓 Optional 안전하게 열기

            이전 레슨에서 `!`로 강제로 값을 꺼냈는데, 이건 **위험합니다**!
            nil일 때 `!`를 쓰면 앱이 **크래시**됩니다. 💥

            ---

            ## 📚 if let (Optional Binding)

            안전하게 값을 꺼내는 방법입니다.

            ```swift
            var name: String? = "민수"

            if let unwrappedName = name {
                // name이 nil이 아닐 때만 실행
                print("이름: \\(unwrappedName)")
            } else {
                print("이름 없음")
            }
            ```

            값이 있으면 `unwrappedName`에 담기고, 없으면 else 실행!

            ---

            ## 🎯 미션

            `if let`을 사용해 사용자 설정을 안전하게 출력하세요.
            - nickname이 있으면: "환영합니다, [닉네임]님!"
            - nickname이 없으면: "환영합니다, 손님!"
            """,
            type: .codeExercise,
            language: .swift,
            starterCode: """
            var nickname: String? = nil

            // if let으로 안전하게 닉네임 출력


            """,
            solutionCode: """
            var nickname: String? = nil

            if let name = nickname {
                print("환영합니다, \\(name)님!")
            } else {
                print("환영합니다, 손님!")
            }
            """,
            expectedOutput: "환영합니다, 손님!",
            xpReward: 30,
            order: 2
        )
        try await lesson2_2.save(on: database)

        // Lesson 2-3: 기본값 설정하기
        let lesson2_3 = Lesson(
            id: UUID(uuidString: "44444444-4444-4444-4444-444444200203"),
            chapterId: chapter2.id!,
            title: "기본값 설정하기",
            content: """
            # 🎁 기본값으로 대체하기

            매번 if let 쓰기 귀찮을 때!
            **nil 병합 연산자 `??`**로 간단하게 기본값을 설정할 수 있어요.

            ---

            ## 📚 Nil Coalescing Operator (??)

            ```swift
            let nickname: String? = nil
            let displayName = nickname ?? "Guest"
            // nickname이 nil이면 "Guest" 사용
            print(displayName)  // "Guest"
            ```

            한 줄로 "값이 있으면 그거, 없으면 기본값" 처리!

            ---

            ## 🎯 미션

            Swifty 설정을 불러와서 인사 메시지를 만드세요.
            - 닉네임이 없으면 "User" 사용
            - 나이가 없으면 0 사용

            출력: "안녕하세요, [닉네임]님! ([나이]세)"
            """,
            type: .codeExercise,
            language: .swift,
            starterCode: """
            let savedNickname: String? = "개발자킴"
            let savedAge: Int? = nil

            // ?? 연산자로 기본값 설정
            let nickname = // savedNickname 또는 "User"
            let age = // savedAge 또는 0

            print("안녕하세요, \\(nickname)님! (\\(age)세)")
            """,
            solutionCode: """
            let savedNickname: String? = "개발자킴"
            let savedAge: Int? = nil

            let nickname = savedNickname ?? "User"
            let age = savedAge ?? 0

            print("안녕하세요, \\(nickname)님! (\\(age)세)")
            """,
            expectedOutput: "안녕하세요, 개발자킴님! (0세)",
            xpReward: 25,
            order: 3
        )
        try await lesson2_3.save(on: database)

        // Lesson 2-4: 조기 탈출
        let lesson2_4 = Lesson(
            id: UUID(uuidString: "44444444-4444-4444-4444-444444200204"),
            chapterId: chapter2.id!,
            title: "조기 탈출",
            content: """
            # 🚪 빠른 탈출: guard let

            함수에서 Optional을 다룰 때, `if let`은 들여쓰기가 깊어집니다.
            **guard let**은 조건이 실패하면 **즉시 함수를 종료**합니다!

            ---

            ## 📚 guard let vs if let

            ```swift
            // if let - 성공 시 코드가 안에 들어감
            func greet1(name: String?) {
                if let unwrapped = name {
                    print("Hello, \\(unwrapped)")
                    // 계속 들여쓰기...
                }
            }

            // guard let - 실패 시 즉시 탈출
            func greet2(name: String?) {
                guard let unwrapped = name else {
                    print("이름이 없습니다")
                    return
                }
                // unwrapped를 바로 사용! 들여쓰기 없음
                print("Hello, \\(unwrapped)")
            }
            ```

            ---

            ## 🎯 미션

            `processUserSettings` 함수에서 guard let으로 필수 설정을 검증하세요.
            닉네임이 없으면 "닉네임은 필수입니다!" 출력 후 종료.
            있으면 "[닉네임]님의 설정을 저장했습니다." 출력.
            """,
            type: .codeExercise,
            language: .swift,
            starterCode: """
            func processUserSettings(nickname: String?, theme: String) {
                // guard let으로 nickname 검증
                // 없으면 "닉네임은 필수입니다!" 출력 후 return


                // nickname이 있으면 저장 메시지 출력
                print("\\(validNickname)님의 설정을 저장했습니다.")
                print("테마: \\(theme)")
            }

            processUserSettings(nickname: nil, theme: "다크모드")
            """,
            solutionCode: """
            func processUserSettings(nickname: String?, theme: String) {
                guard let validNickname = nickname else {
                    print("닉네임은 필수입니다!")
                    return
                }

                print("\\(validNickname)님의 설정을 저장했습니다.")
                print("테마: \\(theme)")
            }

            processUserSettings(nickname: nil, theme: "다크모드")
            """,
            expectedOutput: "닉네임은 필수입니다!",
            xpReward: 35,
            order: 4
        )
        try await lesson2_4.save(on: database)

        // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        // MARK: - Chapter 3: Swifty 학습 시스템
        // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        let chapter3 = Chapter(
            id: UUID(uuidString: "33333333-3333-3333-3333-333333332003"),
            courseId: swifty2Course.id!,
            title: "Swifty 학습 시스템",
            description: "Swifty가 새로운 응답 패턴을 학습합니다.",
            order: 3
        )
        try await chapter3.save(on: database)

        // Lesson 3-1: 코드를 변수에 담기
        let lesson3_1 = Lesson(
            id: UUID(uuidString: "44444444-4444-4444-4444-444444200301"),
            chapterId: chapter3.id!,
            title: "코드를 변수에 담기",
            content: """
            # 🧠 Swifty의 학습 능력

            Swifty가 새로운 응답을 "배울" 수 있으면 좋겠죠?
            **Closure**는 코드 블록을 변수처럼 저장하고 전달할 수 있게 해줍니다!

            ---

            ## 📚 Closure란?

            **이름 없는 함수**입니다. 변수에 저장하고 나중에 실행할 수 있어요.

            ```swift
            // 일반 함수
            func sayHello() {
                print("안녕!")
            }

            // 클로저 (같은 기능)
            let sayHelloClosure = {
                print("안녕!")
            }

            sayHelloClosure()  // "안녕!"
            ```

            ---

            ## 🎯 미션

            "좋은 아침이에요! ☀️"를 출력하는 클로저를 만들고 실행하세요.
            """,
            type: .codeExercise,
            language: .swift,
            starterCode: """
            // morningGreeting 클로저 정의


            // 클로저 실행
            morningGreeting()
            """,
            solutionCode: """
            let morningGreeting = {
                print("좋은 아침이에요! ☀️")
            }

            morningGreeting()
            """,
            expectedOutput: "좋은 아침이에요! ☀️",
            xpReward: 25,
            order: 1
        )
        try await lesson3_1.save(on: database)

        // Lesson 3-2: 입력받는 클로저
        let lesson3_2 = Lesson(
            id: UUID(uuidString: "44444444-4444-4444-4444-444444200302"),
            chapterId: chapter3.id!,
            title: "입력받는 클로저",
            content: """
            # 📥 학습 데이터 입력받기

            Swifty가 사용자 이름을 받아서 맞춤 인사를 하려면?
            클로저도 함수처럼 **파라미터**를 받을 수 있습니다!

            ---

            ## 📚 파라미터가 있는 Closure

            ```swift
            let greet = { (name: String) in
                print("안녕, \\(name)!")
            }

            greet("민수")  // "안녕, 민수!"
            ```

            `in` 키워드가 파라미터와 본문을 구분합니다.

            ---

            ## 📚 반환값이 있는 Closure

            ```swift
            let add = { (a: Int, b: Int) -> Int in
                return a + b
            }

            let result = add(3, 5)  // 8
            ```

            ---

            ## 🎯 미션

            이름과 감정을 받아 맞춤 응답을 반환하는 클로저를 만드세요.
            출력: "[이름]님, [감정] 상태시군요!"
            """,
            type: .codeExercise,
            language: .swift,
            starterCode: """
            // customResponse 클로저 정의
            // 파라미터: name(String), emotion(String)
            // 반환: String


            let response = customResponse("영희", "행복한")
            print(response)
            """,
            solutionCode: """
            let customResponse = { (name: String, emotion: String) -> String in
                return "\\(name)님, \\(emotion) 상태시군요!"
            }

            let response = customResponse("영희", "행복한")
            print(response)
            """,
            expectedOutput: "영희님, 행복한 상태시군요!",
            xpReward: 30,
            order: 2
        )
        try await lesson3_2.save(on: database)

        // Lesson 3-3: 함수에 클로저 전달하기
        let lesson3_3 = Lesson(
            id: UUID(uuidString: "44444444-4444-4444-4444-444444200303"),
            chapterId: chapter3.id!,
            title: "함수에 클로저 전달하기",
            content: """
            # 📞 학습 완료 알림

            Swifty가 새 패턴을 학습하면 "완료!" 알림이 필요합니다.
            함수가 끝난 후 실행할 코드를 **Closure로 전달**할 수 있어요!

            ---

            ## 📚 Completion Handler 패턴

            ```swift
            func downloadFile(completion: () -> Void) {
                print("다운로드 중...")
                // 다운로드 로직
                completion()  // 완료 후 클로저 실행
            }

            downloadFile {
                print("다운로드 완료!")
            }
            // 다운로드 중...
            // 다운로드 완료!
            ```

            **Trailing Closure**: 마지막 파라미터가 클로저면 `{}` 밖으로 뺄 수 있어요.

            ---

            ## 🎯 미션

            `learnPattern` 함수를 완성하세요.
            새 패턴을 저장한 후 completion 클로저를 호출합니다.
            """,
            type: .codeExercise,
            language: .swift,
            starterCode: """
            func learnPattern(pattern: String, completion: () -> Void) {
                print("새 패턴 학습 중: \\(pattern)")
                // 학습 완료 후 completion 호출

            }

            learnPattern(pattern: "안녕 -> 반가워요!") {
                print("✅ 학습 완료!")
            }
            """,
            solutionCode: """
            func learnPattern(pattern: String, completion: () -> Void) {
                print("새 패턴 학습 중: \\(pattern)")
                completion()
            }

            learnPattern(pattern: "안녕 -> 반가워요!") {
                print("✅ 학습 완료!")
            }
            """,
            expectedOutput: """
            새 패턴 학습 중: 안녕 -> 반가워요!
            ✅ 학습 완료!
            """,
            xpReward: 35,
            order: 3
        )
        try await lesson3_3.save(on: database)

        // Lesson 3-4: 데이터 변환하기
        let lesson3_4 = Lesson(
            id: UUID(uuidString: "44444444-4444-4444-4444-444444200304"),
            chapterId: chapter3.id!,
            title: "데이터 변환하기",
            content: """
            # 🔄 대화 기록 처리

            Swifty의 대화 기록을 분석하려면 데이터를 변환해야 합니다.
            **고차함수**는 클로저를 활용해 컬렉션을 쉽게 처리합니다!

            ---

            ## 📚 map - 모든 요소 변환

            ```swift
            let numbers = [1, 2, 3]
            let doubled = numbers.map { $0 * 2 }
            // [2, 4, 6]
            ```

            `$0`은 클로저의 첫 번째 파라미터를 나타내는 축약 문법입니다.

            ## 📚 filter - 조건에 맞는 요소만

            ```swift
            let numbers = [1, 2, 3, 4, 5]
            let evens = numbers.filter { $0 % 2 == 0 }
            // [2, 4]
            ```

            ---

            ## 🎯 미션

            대화 기록에서:
            1. 모든 메시지 앞에 "📝 " 붙이기 (map)
            2. "안녕"이 포함된 메시지만 필터링 (filter)
            """,
            type: .codeExercise,
            language: .swift,
            starterCode: """
            let chatHistory = ["안녕하세요", "날씨 어때요?", "안녕히 가세요", "감사합니다"]

            // 1. 모든 메시지 앞에 "📝 " 붙이기
            let formatted = chatHistory.map { /* $0 앞에 "📝 " 붙이기 */ }

            // 2. "안녕"이 포함된 메시지만 필터링
            let greetings = chatHistory.filter { /* "안녕" 포함 여부 */ }

            print("포맷된 메시지: \\(formatted)")
            print("인사 메시지: \\(greetings)")
            """,
            solutionCode: """
            let chatHistory = ["안녕하세요", "날씨 어때요?", "안녕히 가세요", "감사합니다"]

            let formatted = chatHistory.map { "📝 " + $0 }
            let greetings = chatHistory.filter { $0.contains("안녕") }

            print("포맷된 메시지: \\(formatted)")
            print("인사 메시지: \\(greetings)")
            """,
            expectedOutput: """
            포맷된 메시지: ["📝 안녕하세요", "📝 날씨 어때요?", "📝 안녕히 가세요", "📝 감사합니다"]
            인사 메시지: ["안녕하세요", "안녕히 가세요"]
            """,
            xpReward: 40,
            order: 4
        )
        try await lesson3_4.save(on: database)

        // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        // MARK: - Chapter 4: Swifty 플러그인 시스템
        // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        let chapter4 = Chapter(
            id: UUID(uuidString: "33333333-3333-3333-3333-333333332004"),
            courseId: swifty2Course.id!,
            title: "Swifty 플러그인 시스템",
            description: "확장 가능한 기능 아키텍처를 만듭니다.",
            order: 4
        )
        try await chapter4.save(on: database)

        // Lesson 4-1: 기능 인터페이스 정의
        let lesson4_1 = Lesson(
            id: UUID(uuidString: "44444444-4444-4444-4444-444444200401"),
            chapterId: chapter4.id!,
            title: "기능 인터페이스 정의",
            content: """
            # 🔌 Swifty 플러그인 시스템

            Swifty에 날씨, 뉴스, 번역 등 다양한 기능을 추가하고 싶습니다.
            모든 플러그인이 **같은 방식으로 동작**하게 하려면?

            **Protocol**로 "이런 기능이 있어야 해!"라는 계약을 정의합니다.

            ---

            ## 📚 Protocol이란?

            "이 타입은 이런 메서드/프로퍼티를 가져야 한다"는 **청사진**입니다.

            ```swift
            protocol Drawable {
                func draw()
            }

            struct Circle: Drawable {
                func draw() {
                    print("⭕ 원 그리기")
                }
            }

            struct Square: Drawable {
                func draw() {
                    print("⬜ 사각형 그리기")
                }
            }
            ```

            ---

            ## 🎯 미션

            `SwiftyPlugin` 프로토콜을 정의하세요:
            - name: String (읽기 전용)
            - execute() 메서드

            그리고 `WeatherPlugin`이 이를 채택하게 만드세요.
            """,
            type: .codeExercise,
            language: .swift,
            starterCode: """
            // SwiftyPlugin 프로토콜 정의
            // - name: String { get }
            // - func execute()


            // WeatherPlugin이 SwiftyPlugin 채택
            struct WeatherPlugin {
                // ...
            }

            let weather = WeatherPlugin()
            print("플러그인: \\(weather.name)")
            weather.execute()
            """,
            solutionCode: """
            protocol SwiftyPlugin {
                var name: String { get }
                func execute()
            }

            struct WeatherPlugin: SwiftyPlugin {
                var name: String {
                    return "날씨 플러그인"
                }

                func execute() {
                    print("🌤️ 오늘 서울 날씨: 맑음, 15°C")
                }
            }

            let weather = WeatherPlugin()
            print("플러그인: \\(weather.name)")
            weather.execute()
            """,
            expectedOutput: """
            플러그인: 날씨 플러그인
            🌤️ 오늘 서울 날씨: 맑음, 15°C
            """,
            xpReward: 30,
            order: 1
        )
        try await lesson4_1.save(on: database)

        // Lesson 4-2: 여러 플러그인 관리
        let lesson4_2 = Lesson(
            id: UUID(uuidString: "44444444-4444-4444-4444-444444200402"),
            chapterId: chapter4.id!,
            title: "여러 플러그인 관리",
            content: """
            # 📦 플러그인 매니저

            여러 플러그인을 하나의 배열에서 관리하고 싶습니다.
            Protocol을 **타입처럼** 사용하면 가능해요!

            ---

            ## 📚 Protocol을 타입으로 사용

            ```swift
            protocol Animal {
                func speak()
            }

            struct Dog: Animal {
                func speak() { print("멍멍") }
            }

            struct Cat: Animal {
                func speak() { print("야옹") }
            }

            // Protocol 타입 배열!
            let animals: [Animal] = [Dog(), Cat()]

            for animal in animals {
                animal.speak()
            }
            // 멍멍
            // 야옹
            ```

            ---

            ## 🎯 미션

            `NewsPlugin`을 추가로 만들고,
            `plugins` 배열에 WeatherPlugin과 NewsPlugin을 담아
            모든 플러그인을 실행하세요.
            """,
            type: .codeExercise,
            language: .swift,
            starterCode: """
            protocol SwiftyPlugin {
                var name: String { get }
                func execute()
            }

            struct WeatherPlugin: SwiftyPlugin {
                var name: String { "날씨" }
                func execute() { print("🌤️ 날씨: 맑음") }
            }

            // NewsPlugin 정의 (이름: "뉴스", 실행: "📰 오늘의 헤드라인...")


            // 플러그인 배열 생성
            let plugins: [SwiftyPlugin] = [ /* 두 플러그인 추가 */ ]

            // 모든 플러그인 실행
            for plugin in plugins {
                print("[\\(plugin.name)] 실행:")
                plugin.execute()
            }
            """,
            solutionCode: """
            protocol SwiftyPlugin {
                var name: String { get }
                func execute()
            }

            struct WeatherPlugin: SwiftyPlugin {
                var name: String { "날씨" }
                func execute() { print("🌤️ 날씨: 맑음") }
            }

            struct NewsPlugin: SwiftyPlugin {
                var name: String { "뉴스" }
                func execute() { print("📰 오늘의 헤드라인: Swift 6.0 출시!") }
            }

            let plugins: [SwiftyPlugin] = [WeatherPlugin(), NewsPlugin()]

            for plugin in plugins {
                print("[\\(plugin.name)] 실행:")
                plugin.execute()
            }
            """,
            expectedOutput: """
            [날씨] 실행:
            🌤️ 날씨: 맑음
            [뉴스] 실행:
            📰 오늘의 헤드라인: Swift 6.0 출시!
            """,
            xpReward: 35,
            order: 2
        )
        try await lesson4_2.save(on: database)

        // Lesson 4-3: 기능 확장하기
        let lesson4_3 = Lesson(
            id: UUID(uuidString: "44444444-4444-4444-4444-444444200403"),
            chapterId: chapter4.id!,
            title: "기능 확장하기",
            content: """
            # ➕ 기존 타입에 기능 추가

            Swifty에서 문자열을 자주 다루는데,
            기본 String에 편리한 기능을 추가하고 싶어요!

            **Extension**으로 기존 타입을 확장할 수 있습니다.

            ---

            ## 📚 Extension

            ```swift
            extension String {
                func shout() -> String {
                    return self.uppercased() + "!!!"
                }
            }

            let greeting = "hello"
            print(greeting.shout())  // "HELLO!!!"
            ```

            심지어 **Int, Array** 같은 기본 타입도 확장 가능!

            ---

            ## 🎯 미션

            String에 `asSwiftyCommand` 프로퍼티를 추가하세요.
            "/명령어" 형태로 변환합니다.

            "날씨" → "/날씨"
            """,
            type: .codeExercise,
            language: .swift,
            starterCode: """
            extension String {
                // asSwiftyCommand 연산 프로퍼티 추가
                // "/" + self 반환

            }

            let command = "날씨"
            print(command.asSwiftyCommand)

            let help = "도움말"
            print(help.asSwiftyCommand)
            """,
            solutionCode: """
            extension String {
                var asSwiftyCommand: String {
                    return "/" + self
                }
            }

            let command = "날씨"
            print(command.asSwiftyCommand)

            let help = "도움말"
            print(help.asSwiftyCommand)
            """,
            expectedOutput: """
            /날씨
            /도움말
            """,
            xpReward: 30,
            order: 3
        )
        try await lesson4_3.save(on: database)

        // Lesson 4-4: Protocol과 Extension 조합
        let lesson4_4 = Lesson(
            id: UUID(uuidString: "44444444-4444-4444-4444-444444200404"),
            chapterId: chapter4.id!,
            title: "Protocol과 Extension 조합",
            content: """
            # 🎨 기본 구현 제공하기

            모든 플러그인이 공통으로 사용하는 기능이 있다면?
            Protocol Extension으로 **기본 구현**을 제공할 수 있어요!

            ---

            ## 📚 Protocol Extension

            ```swift
            protocol Describable {
                var description: String { get }
            }

            // 기본 구현 제공
            extension Describable {
                var description: String {
                    return "설명 없음"
                }
            }

            struct Item: Describable {
                // description 구현 안 해도 됨!
            }

            print(Item().description)  // "설명 없음"
            ```

            ---

            ## 🎯 미션

            `SwiftyPlugin`에 기본 `description` 구현을 추가하세요.
            기본값: "Swifty 플러그인입니다."

            TranslatePlugin은 커스텀 description을 제공합니다.
            """,
            type: .codeExercise,
            language: .swift,
            starterCode: """
            protocol SwiftyPlugin {
                var name: String { get }
                func execute()
                var description: String { get }
            }

            // Protocol Extension으로 description 기본 구현


            struct TranslatePlugin: SwiftyPlugin {
                var name: String { "번역" }
                func execute() { print("🌐 번역 중...") }
                // 커스텀 description: "텍스트를 다른 언어로 번역합니다."
                var description: String { "텍스트를 다른 언어로 번역합니다." }
            }

            struct SimplePlugin: SwiftyPlugin {
                var name: String { "심플" }
                func execute() { print("✨ 실행!") }
                // description 구현 안 함 -> 기본값 사용
            }

            print("번역: \\(TranslatePlugin().description)")
            print("심플: \\(SimplePlugin().description)")
            """,
            solutionCode: """
            protocol SwiftyPlugin {
                var name: String { get }
                func execute()
                var description: String { get }
            }

            extension SwiftyPlugin {
                var description: String {
                    return "Swifty 플러그인입니다."
                }
            }

            struct TranslatePlugin: SwiftyPlugin {
                var name: String { "번역" }
                func execute() { print("🌐 번역 중...") }
                var description: String { "텍스트를 다른 언어로 번역합니다." }
            }

            struct SimplePlugin: SwiftyPlugin {
                var name: String { "심플" }
                func execute() { print("✨ 실행!") }
            }

            print("번역: \\(TranslatePlugin().description)")
            print("심플: \\(SimplePlugin().description)")
            """,
            expectedOutput: """
            번역: 텍스트를 다른 언어로 번역합니다.
            심플: Swifty 플러그인입니다.
            """,
            xpReward: 40,
            order: 4
        )
        try await lesson4_4.save(on: database)

        // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        // MARK: - Chapter 5: Swifty 안정성 강화
        // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        let chapter5 = Chapter(
            id: UUID(uuidString: "33333333-3333-3333-3333-333333332005"),
            courseId: swifty2Course.id!,
            title: "Swifty 안정성 강화",
            description: "에러를 우아하게 처리합니다.",
            order: 5
        )
        try await chapter5.save(on: database)

        // Lesson 5-1: 에러 타입 정의하기
        let lesson5_1 = Lesson(
            id: UUID(uuidString: "44444444-4444-4444-4444-444444200501"),
            chapterId: chapter5.id!,
            title: "에러 타입 정의하기",
            content: """
            # 🚨 Swifty 에러 처리

            Swifty가 잘못된 입력을 받으면 어떻게 해야 할까요?
            **Error Handling**으로 예외 상황을 안전하게 처리합니다!

            ---

            ## 📚 Error 프로토콜

            Swift에서 에러는 `Error` 프로토콜을 채택한 타입입니다.
            보통 **enum**으로 정의합니다.

            ```swift
            enum LoginError: Error {
                case invalidEmail
                case wrongPassword
                case networkError
            }
            ```

            각 케이스가 하나의 에러 상황을 나타냅니다.

            ---

            ## 🎯 미션

            Swifty의 에러 타입 `SwiftyError`를 정의하세요:
            - emptyInput: 빈 입력
            - unknownCommand: 알 수 없는 명령어
            - pluginNotFound: 플러그인 없음
            """,
            type: .codeExercise,
            language: .swift,
            starterCode: """
            // SwiftyError enum 정의 (Error 프로토콜 채택)


            // 에러 출력 테스트
            let error1: SwiftyError = .emptyInput
            let error2: SwiftyError = .unknownCommand
            let error3: SwiftyError = .pluginNotFound

            print(error1)
            print(error2)
            print(error3)
            """,
            solutionCode: """
            enum SwiftyError: Error {
                case emptyInput
                case unknownCommand
                case pluginNotFound
            }

            let error1: SwiftyError = .emptyInput
            let error2: SwiftyError = .unknownCommand
            let error3: SwiftyError = .pluginNotFound

            print(error1)
            print(error2)
            print(error3)
            """,
            expectedOutput: """
            emptyInput
            unknownCommand
            pluginNotFound
            """,
            xpReward: 25,
            order: 1
        )
        try await lesson5_1.save(on: database)

        // Lesson 5-2: 에러 던지기
        let lesson5_2 = Lesson(
            id: UUID(uuidString: "44444444-4444-4444-4444-444444200502"),
            chapterId: chapter5.id!,
            title: "에러 던지기",
            content: """
            # 🎯 에러 발생시키기

            문제가 생기면 에러를 **던져서(throw)** 알려야 합니다.
            `throws` 키워드가 붙은 함수만 에러를 던질 수 있어요.

            ---

            ## 📚 throw와 throws

            ```swift
            enum DivisionError: Error {
                case divideByZero
            }

            // throws 키워드로 "이 함수는 에러를 던질 수 있다" 선언
            func divide(_ a: Int, by b: Int) throws -> Int {
                if b == 0 {
                    throw DivisionError.divideByZero  // 에러 던지기
                }
                return a / b
            }
            ```

            ---

            ## 🎯 미션

            `processInput` 함수를 완성하세요:
            - 빈 문자열이면 `.emptyInput` 에러 throw
            - "종료"면 "프로그램을 종료합니다." 반환
            - 그 외에는 "입력: [값]" 반환
            """,
            type: .codeExercise,
            language: .swift,
            starterCode: """
            enum SwiftyError: Error {
                case emptyInput
                case unknownCommand
            }

            func processInput(_ input: String) throws -> String {
                // 빈 문자열이면 에러 throw

                // "종료"면 종료 메시지 반환

                // 그 외 입력 메시지 반환

            }

            // 테스트는 다음 레슨에서!
            print("함수 정의 완료")
            """,
            solutionCode: """
            enum SwiftyError: Error {
                case emptyInput
                case unknownCommand
            }

            func processInput(_ input: String) throws -> String {
                if input.isEmpty {
                    throw SwiftyError.emptyInput
                }

                if input == "종료" {
                    return "프로그램을 종료합니다."
                }

                return "입력: \\(input)"
            }

            print("함수 정의 완료")
            """,
            expectedOutput: "함수 정의 완료",
            xpReward: 30,
            order: 2
        )
        try await lesson5_2.save(on: database)

        // Lesson 5-3: 에러 잡기
        let lesson5_3 = Lesson(
            id: UUID(uuidString: "44444444-4444-4444-4444-444444200503"),
            chapterId: chapter5.id!,
            title: "에러 잡기",
            content: """
            # 🥅 에러 안전하게 처리하기

            throws 함수를 호출할 때는 에러가 발생할 수 있으니
            **do-try-catch**로 감싸야 합니다!

            ---

            ## 📚 do-try-catch

            ```swift
            do {
                let result = try divide(10, by: 0)
                print(result)
            } catch DivisionError.divideByZero {
                print("0으로 나눌 수 없습니다!")
            } catch {
                print("알 수 없는 에러: \\(error)")
            }
            ```

            - `try`: throws 함수 호출 시 필수
            - `catch`: 특정 에러 타입 처리
            - `catch` (기본): 나머지 모든 에러 처리

            ---

            ## 🎯 미션

            `processInput`을 호출하고 에러를 처리하세요:
            - emptyInput → "❌ 입력이 비어있습니다."
            - 그 외 에러 → "⚠️ 에러 발생: [에러]"
            - 성공 → 결과 출력
            """,
            type: .codeExercise,
            language: .swift,
            starterCode: """
            enum SwiftyError: Error {
                case emptyInput
                case unknownCommand
            }

            func processInput(_ input: String) throws -> String {
                if input.isEmpty {
                    throw SwiftyError.emptyInput
                }
                return "입력: \\(input)"
            }

            // do-try-catch로 빈 문자열 처리
            let userInput = ""


            """,
            solutionCode: """
            enum SwiftyError: Error {
                case emptyInput
                case unknownCommand
            }

            func processInput(_ input: String) throws -> String {
                if input.isEmpty {
                    throw SwiftyError.emptyInput
                }
                return "입력: \\(input)"
            }

            let userInput = ""

            do {
                let result = try processInput(userInput)
                print(result)
            } catch SwiftyError.emptyInput {
                print("❌ 입력이 비어있습니다.")
            } catch {
                print("⚠️ 에러 발생: \\(error)")
            }
            """,
            expectedOutput: "❌ 입력이 비어있습니다.",
            xpReward: 35,
            order: 3
        )
        try await lesson5_3.save(on: database)

        // Lesson 5-4: Swifty 2.0 완성!
        let lesson5_4 = Lesson(
            id: UUID(uuidString: "44444444-4444-4444-4444-444444200504"),
            chapterId: chapter5.id!,
            title: "Swifty 2.0 완성!",
            content: """
            # 🎉 Swifty 2.0 최종 테스트

            축하합니다! 모든 개념을 배웠습니다.
            이제 모든 것을 합쳐 **Swifty 2.0**을 완성합니다!

            ---

            ## Swifty 2.0 기능 목록

            ✅ 감정 인식 (Enum)
            ✅ 사용자 프로필 (Struct)
            ✅ 설정 관리 (Optional)
            ✅ 학습 시스템 (Closure)
            ✅ 플러그인 시스템 (Protocol)
            ✅ 에러 처리 (Error Handling)

            ---

            ## 🎯 최종 미션

            `SwiftyBot` 클래스를 완성하세요:
            1. 빈 명령어면 에러 throw
            2. "감정 [happy/sad]" → 감정 응답
            3. "플러그인 [이름]" → 플러그인 실행
            4. 그 외 → unknownCommand 에러
            """,
            type: .codeExercise,
            language: .swift,
            starterCode: """
            enum Emotion { case happy, sad, neutral }

            enum SwiftyError: Error {
                case emptyInput
                case unknownCommand
            }

            protocol SwiftyPlugin {
                var name: String { get }
                func execute() -> String
            }

            struct WeatherPlugin: SwiftyPlugin {
                var name: String { "날씨" }
                func execute() -> String { "🌤️ 맑음, 18°C" }
            }

            class SwiftyBot {
                var currentEmotion: Emotion = .neutral
                var plugins: [String: SwiftyPlugin] = ["날씨": WeatherPlugin()]

                func process(_ command: String) throws -> String {
                    // 1. 빈 명령어 체크

                    // 2. "감정 happy" 또는 "감정 sad" 처리

                    // 3. "플러그인 날씨" 처리

                    // 4. 그 외 unknownCommand 에러

                }
            }

            // 테스트
            let bot = SwiftyBot()

            do {
                print(try bot.process("감정 happy"))
                print(try bot.process("플러그인 날씨"))
                print(try bot.process(""))
            } catch SwiftyError.emptyInput {
                print("❌ 빈 입력")
            } catch SwiftyError.unknownCommand {
                print("❓ 알 수 없는 명령")
            } catch {
                print("에러: \\(error)")
            }
            """,
            solutionCode: """
            enum Emotion { case happy, sad, neutral }

            enum SwiftyError: Error {
                case emptyInput
                case unknownCommand
            }

            protocol SwiftyPlugin {
                var name: String { get }
                func execute() -> String
            }

            struct WeatherPlugin: SwiftyPlugin {
                var name: String { "날씨" }
                func execute() -> String { "🌤️ 맑음, 18°C" }
            }

            class SwiftyBot {
                var currentEmotion: Emotion = .neutral
                var plugins: [String: SwiftyPlugin] = ["날씨": WeatherPlugin()]

                func process(_ command: String) throws -> String {
                    guard !command.isEmpty else {
                        throw SwiftyError.emptyInput
                    }

                    if command.hasPrefix("감정 ") {
                        let emotionStr = command.replacingOccurrences(of: "감정 ", with: "")
                        if emotionStr == "happy" {
                            currentEmotion = .happy
                            return "😊 기분이 좋으시군요!"
                        } else if emotionStr == "sad" {
                            currentEmotion = .sad
                            return "🤗 제가 위로해드릴게요."
                        }
                    }

                    if command.hasPrefix("플러그인 ") {
                        let pluginName = command.replacingOccurrences(of: "플러그인 ", with: "")
                        if let plugin = plugins[pluginName] {
                            return plugin.execute()
                        }
                    }

                    throw SwiftyError.unknownCommand
                }
            }

            let bot = SwiftyBot()

            do {
                print(try bot.process("감정 happy"))
                print(try bot.process("플러그인 날씨"))
                print(try bot.process(""))
            } catch SwiftyError.emptyInput {
                print("❌ 빈 입력")
            } catch SwiftyError.unknownCommand {
                print("❓ 알 수 없는 명령")
            } catch {
                print("에러: \\(error)")
            }
            """,
            expectedOutput: """
            😊 기분이 좋으시군요!
            🌤️ 맑음, 18°C
            ❌ 빈 입력
            """,
            xpReward: 60,
            order: 4
        )
        try await lesson5_4.save(on: database)
    }

    func revert(on database: Database) async throws {
        // Course ID로 관련 데이터 삭제
        let courseId = UUID(uuidString: "22222222-2222-2222-2222-222222222220")!

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
