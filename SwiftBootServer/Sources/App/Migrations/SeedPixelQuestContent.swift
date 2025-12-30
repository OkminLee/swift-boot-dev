import Fluent
import Vapor

/// Course: "PixelQuest - 게임 개발자 되기" - 게임 개발하며 Swift 심화 학습
struct SeedPixelQuestContent: AsyncMigration {
    func prepare(on database: Database) async throws {
        // 기존 Track 조회
        guard let swiftTrack = try await Track.query(on: database)
            .filter(\.$id == UUID(uuidString: "11111111-1111-1111-1111-111111111111")!)
            .first() else {
            throw Abort(.internalServerError, reason: "Swift Track not found")
        }

        // Swifty 2.0 코스 ID (선행 조건)
        let swifty2CourseId = UUID(uuidString: "22222222-2222-2222-2222-222222222220")!

        // MARK: - Course: PixelQuest - 게임 개발자 되기
        let pixelQuestCourse = Course(
            id: UUID(uuidString: "22222222-2222-2222-2222-222222222230"),
            trackId: swiftTrack.id!,
            title: "PixelQuest - 게임 개발자 되기",
            description: "2D RPG 게임 'PixelQuest'를 만들며 Swift 심화 개념을 마스터하세요. 영웅을 만들고, 아이템을 장착하고, 몬스터와 전투하세요!",
            icon: "gamecontroller.fill",
            difficulty: .intermediate,
            order: 2,
            isPublished: true,
            prerequisiteId: swifty2CourseId
        )
        try await pixelQuestCourse.save(on: database)

        // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        // MARK: - Chapter 1: 영웅 탄생
        // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        let chapter1 = Chapter(
            id: UUID(uuidString: "33333333-3333-3333-3333-333333333001"),
            courseId: pixelQuestCourse.id!,
            title: "영웅 탄생",
            description: "게임의 주인공 Hero를 만들고 Class와 Struct의 차이를 깊이 이해합니다.",
            order: 1
        )
        try await chapter1.save(on: database)

        // Lesson 1-1: 캐릭터 스탯 정의
        let lesson1_1 = Lesson(
            id: UUID(uuidString: "44444444-4444-4444-4444-444444300101"),
            chapterId: chapter1.id!,
            title: "캐릭터 스탯 정의",
            content: """
            # 🎮 PixelQuest 프로젝트 시작!

            환영합니다, 게임 개발자님! 오늘부터 2D RPG **PixelQuest**를 만듭니다.

            첫 번째 미션은 주인공 **Hero**의 기본 스탯을 정의하는 것입니다.

            ---

            ## 📚 Struct로 데이터 모델링

            게임 캐릭터는 여러 속성을 가집니다. Struct로 깔끔하게 묶어봅시다.

            ```swift
            struct Stats {
                var hp: Int        // 체력
                var maxHp: Int     // 최대 체력
                var attack: Int    // 공격력
                var defense: Int   // 방어력
            }
            ```

            ---

            ## 🎯 미션

            `CharacterStats` struct를 만드세요:
            - hp, maxHp, attack, defense (모두 Int)
            - level: Int (기본값 1)

            전사 스탯을 생성하고 출력하세요.
            """,
            type: .codeExercise,
            language: .swift,
            starterCode: """
            // CharacterStats struct 정의
            // hp, maxHp, attack, defense, level 포함


            // 전사 스탯 생성: hp=100, maxHp=100, attack=15, defense=10, level=1
            let warriorStats = // ...

            print("⚔️ 전사 스탯")
            print("HP: \\(warriorStats.hp)/\\(warriorStats.maxHp)")
            print("공격력: \\(warriorStats.attack), 방어력: \\(warriorStats.defense)")
            print("레벨: \\(warriorStats.level)")
            """,
            solutionCode: """
            struct CharacterStats {
                var hp: Int
                var maxHp: Int
                var attack: Int
                var defense: Int
                var level: Int = 1
            }

            let warriorStats = CharacterStats(hp: 100, maxHp: 100, attack: 15, defense: 10)

            print("⚔️ 전사 스탯")
            print("HP: \\(warriorStats.hp)/\\(warriorStats.maxHp)")
            print("공격력: \\(warriorStats.attack), 방어력: \\(warriorStats.defense)")
            print("레벨: \\(warriorStats.level)")
            """,
            expectedOutput: """
            ⚔️ 전사 스탯
            HP: 100/100
            공격력: 15, 방어력: 10
            레벨: 1
            """,
            xpReward: 25,
            order: 1
        )
        try await lesson1_1.save(on: database)

        // Lesson 1-2: Hero 클래스 만들기
        let lesson1_2 = Lesson(
            id: UUID(uuidString: "44444444-4444-4444-4444-444444300102"),
            chapterId: chapter1.id!,
            title: "Hero 클래스 만들기",
            content: """
            # 🦸 Hero 클래스

            이제 진짜 영웅을 만들어봅시다!
            Hero는 **상태가 계속 변하므로** Class가 적합합니다.

            ---

            ## 📚 Class vs Struct

            | 특성 | Struct (값 타입) | Class (참조 타입) |
            |-----|----------------|-----------------|
            | 복사 | 독립적인 복사본 | 같은 객체 참조 |
            | 상속 | ❌ | ✅ |
            | 용도 | 데이터 컨테이너 | 상태를 가진 객체 |

            ```swift
            class Hero {
                var name: String
                var stats: CharacterStats

                init(name: String, stats: CharacterStats) {
                    self.name = name
                    self.stats = stats
                }
            }
            ```

            ---

            ## 🎯 미션

            `Hero` 클래스를 만드세요:
            - name: String
            - stats: CharacterStats
            - `takeDamage(_ amount: Int)` 메서드: hp 감소

            영웅이 데미지를 받으면 HP가 줄어드는지 확인하세요.
            """,
            type: .codeExercise,
            language: .swift,
            starterCode: """
            struct CharacterStats {
                var hp: Int
                var maxHp: Int
                var attack: Int
                var defense: Int
            }

            // Hero 클래스 정의
            class Hero {
                var name: String
                var stats: CharacterStats

                init(name: String, stats: CharacterStats) {
                    self.name = name
                    self.stats = stats
                }

                // takeDamage 메서드: hp에서 amount 빼기
                func takeDamage(_ amount: Int) {

                }
            }

            let hero = Hero(name: "아서", stats: CharacterStats(hp: 100, maxHp: 100, attack: 15, defense: 10))
            print("\\(hero.name)의 HP: \\(hero.stats.hp)")

            hero.takeDamage(30)
            print("30 데미지! HP: \\(hero.stats.hp)")
            """,
            solutionCode: """
            struct CharacterStats {
                var hp: Int
                var maxHp: Int
                var attack: Int
                var defense: Int
            }

            class Hero {
                var name: String
                var stats: CharacterStats

                init(name: String, stats: CharacterStats) {
                    self.name = name
                    self.stats = stats
                }

                func takeDamage(_ amount: Int) {
                    stats.hp -= amount
                    if stats.hp < 0 { stats.hp = 0 }
                }
            }

            let hero = Hero(name: "아서", stats: CharacterStats(hp: 100, maxHp: 100, attack: 15, defense: 10))
            print("\\(hero.name)의 HP: \\(hero.stats.hp)")

            hero.takeDamage(30)
            print("30 데미지! HP: \\(hero.stats.hp)")
            """,
            expectedOutput: """
            아서의 HP: 100
            30 데미지! HP: 70
            """,
            xpReward: 30,
            order: 2
        )
        try await lesson1_2.save(on: database)

        // Lesson 1-3: 참조 타입 이해하기
        let lesson1_3 = Lesson(
            id: UUID(uuidString: "44444444-4444-4444-4444-444444300103"),
            chapterId: chapter1.id!,
            title: "참조 타입 이해하기",
            content: """
            # 🔗 참조 타입의 힘

            Class는 **참조 타입**입니다. 같은 객체를 여러 곳에서 공유할 수 있어요.
            이게 게임에서 왜 중요할까요?

            ---

            ## 📚 참조 vs 값

            ```swift
            // Struct (값 타입)
            var stats1 = CharacterStats(hp: 100, ...)
            var stats2 = stats1  // 복사됨!
            stats2.hp = 50
            print(stats1.hp)  // 100 (영향 없음)

            // Class (참조 타입)
            let hero1 = Hero(name: "아서", ...)
            let hero2 = hero1  // 같은 객체!
            hero2.stats.hp = 50
            print(hero1.stats.hp)  // 50 (같이 변함!)
            ```

            ---

            ## 🎯 미션

            파티 시스템을 만드세요:
            - `hero`를 `partyLeader`에 할당
            - `partyLeader`의 HP를 50으로 변경
            - `hero`의 HP도 변경되었는지 확인
            """,
            type: .codeExercise,
            language: .swift,
            starterCode: """
            struct CharacterStats {
                var hp: Int
                var maxHp: Int
                var attack: Int
                var defense: Int
            }

            class Hero {
                var name: String
                var stats: CharacterStats

                init(name: String, stats: CharacterStats) {
                    self.name = name
                    self.stats = stats
                }
            }

            let hero = Hero(name: "아서", stats: CharacterStats(hp: 100, maxHp: 100, attack: 15, defense: 10))

            // partyLeader에 hero 할당 (참조)
            let partyLeader = // ...

            // partyLeader의 HP를 50으로 변경
            // ...

            print("hero HP: \\(hero.stats.hp)")
            print("partyLeader HP: \\(partyLeader.stats.hp)")
            print("같은 객체인가? \\(hero === partyLeader)")
            """,
            solutionCode: """
            struct CharacterStats {
                var hp: Int
                var maxHp: Int
                var attack: Int
                var defense: Int
            }

            class Hero {
                var name: String
                var stats: CharacterStats

                init(name: String, stats: CharacterStats) {
                    self.name = name
                    self.stats = stats
                }
            }

            let hero = Hero(name: "아서", stats: CharacterStats(hp: 100, maxHp: 100, attack: 15, defense: 10))

            let partyLeader = hero

            partyLeader.stats.hp = 50

            print("hero HP: \\(hero.stats.hp)")
            print("partyLeader HP: \\(partyLeader.stats.hp)")
            print("같은 객체인가? \\(hero === partyLeader)")
            """,
            expectedOutput: """
            hero HP: 50
            partyLeader HP: 50
            같은 객체인가? true
            """,
            xpReward: 30,
            order: 3
        )
        try await lesson1_3.save(on: database)

        // Lesson 1-4: 커스텀 초기화
        let lesson1_4 = Lesson(
            id: UUID(uuidString: "44444444-4444-4444-4444-444444300104"),
            chapterId: chapter1.id!,
            title: "커스텀 초기화",
            content: """
            # 🎨 직업별 영웅 생성

            전사, 마법사, 궁수... 직업마다 기본 스탯이 다릅니다.
            **편의 초기화(Convenience Init)**로 쉽게 만들어봅시다!

            ---

            ## 📚 Convenience Initializer

            ```swift
            class Hero {
                // 지정 초기화 (Designated)
                init(name: String, stats: CharacterStats) { ... }

                // 편의 초기화 (Convenience)
                convenience init(warriorNamed name: String) {
                    let stats = CharacterStats(hp: 120, attack: 20, ...)
                    self.init(name: name, stats: stats)
                }
            }
            ```

            ---

            ## 🎯 미션

            Hero 클래스에 3가지 편의 초기화를 추가하세요:
            - `warriorNamed`: HP 120, 공격 20, 방어 15
            - `mageNamed`: HP 80, 공격 30, 방어 5
            - `archerNamed`: HP 90, 공격 25, 방어 8
            """,
            type: .codeExercise,
            language: .swift,
            starterCode: """
            struct CharacterStats {
                var hp: Int
                var maxHp: Int
                var attack: Int
                var defense: Int
            }

            class Hero {
                var name: String
                var stats: CharacterStats
                var job: String

                init(name: String, stats: CharacterStats, job: String) {
                    self.name = name
                    self.stats = stats
                    self.job = job
                }

                // 전사 편의 초기화
                convenience init(warriorNamed name: String) {
                    // HP 120, 공격 20, 방어 15

                }

                // 마법사 편의 초기화
                convenience init(mageNamed name: String) {
                    // HP 80, 공격 30, 방어 5

                }
            }

            let warrior = Hero(warriorNamed: "아서")
            let mage = Hero(mageNamed: "멀린")

            print("\\(warrior.job) \\(warrior.name): HP \\(warrior.stats.hp), 공격 \\(warrior.stats.attack)")
            print("\\(mage.job) \\(mage.name): HP \\(mage.stats.hp), 공격 \\(mage.stats.attack)")
            """,
            solutionCode: """
            struct CharacterStats {
                var hp: Int
                var maxHp: Int
                var attack: Int
                var defense: Int
            }

            class Hero {
                var name: String
                var stats: CharacterStats
                var job: String

                init(name: String, stats: CharacterStats, job: String) {
                    self.name = name
                    self.stats = stats
                    self.job = job
                }

                convenience init(warriorNamed name: String) {
                    let stats = CharacterStats(hp: 120, maxHp: 120, attack: 20, defense: 15)
                    self.init(name: name, stats: stats, job: "전사")
                }

                convenience init(mageNamed name: String) {
                    let stats = CharacterStats(hp: 80, maxHp: 80, attack: 30, defense: 5)
                    self.init(name: name, stats: stats, job: "마법사")
                }
            }

            let warrior = Hero(warriorNamed: "아서")
            let mage = Hero(mageNamed: "멀린")

            print("\\(warrior.job) \\(warrior.name): HP \\(warrior.stats.hp), 공격 \\(warrior.stats.attack)")
            print("\\(mage.job) \\(mage.name): HP \\(mage.stats.hp), 공격 \\(mage.stats.attack)")
            """,
            expectedOutput: """
            전사 아서: HP 120, 공격 20
            마법사 멀린: HP 80, 공격 30
            """,
            xpReward: 35,
            order: 4
        )
        try await lesson1_4.save(on: database)

        // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        // MARK: - Chapter 2: 인벤토리 시스템
        // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        let chapter2 = Chapter(
            id: UUID(uuidString: "33333333-3333-3333-3333-333333333002"),
            courseId: pixelQuestCourse.id!,
            title: "인벤토리 시스템",
            description: "아이템을 장착하고 해제하는 인벤토리를 만들며 Optional을 심화 학습합니다.",
            order: 2
        )
        try await chapter2.save(on: database)

        // Lesson 2-1: 아이템 정의
        let lesson2_1 = Lesson(
            id: UUID(uuidString: "44444444-4444-4444-4444-444444300201"),
            chapterId: chapter2.id!,
            title: "아이템 정의",
            content: """
            # 🗡️ 게임 아이템

            PixelQuest에는 다양한 아이템이 있습니다.
            무기, 방어구, 포션... 각각 다른 효과를 가지죠!

            ---

            ## 📚 Enum으로 아이템 종류 정의

            ```swift
            enum ItemType {
                case weapon
                case armor
                case potion
                case accessory
            }
            ```

            ---

            ## 🎯 미션

            `Item` struct를 만드세요:
            - name: String
            - type: ItemType
            - attackBonus: Int
            - defenseBonus: Int
            - price: Int

            검과 방패 아이템을 생성하세요.
            """,
            type: .codeExercise,
            language: .swift,
            starterCode: """
            enum ItemType {
                case weapon
                case armor
                case potion
                case accessory
            }

            // Item struct 정의


            // 강철 검: weapon, 공격+10, 방어+0, 가격 100
            let steelSword = // ...

            // 나무 방패: armor, 공격+0, 방어+8, 가격 80
            let woodenShield = // ...

            print("🗡️ \\(steelSword.name): 공격+\\(steelSword.attackBonus)")
            print("🛡️ \\(woodenShield.name): 방어+\\(woodenShield.defenseBonus)")
            """,
            solutionCode: """
            enum ItemType {
                case weapon
                case armor
                case potion
                case accessory
            }

            struct Item {
                let name: String
                let type: ItemType
                let attackBonus: Int
                let defenseBonus: Int
                let price: Int
            }

            let steelSword = Item(name: "강철 검", type: .weapon, attackBonus: 10, defenseBonus: 0, price: 100)
            let woodenShield = Item(name: "나무 방패", type: .armor, attackBonus: 0, defenseBonus: 8, price: 80)

            print("🗡️ \\(steelSword.name): 공격+\\(steelSword.attackBonus)")
            print("🛡️ \\(woodenShield.name): 방어+\\(woodenShield.defenseBonus)")
            """,
            expectedOutput: """
            🗡️ 강철 검: 공격+10
            🛡️ 나무 방패: 방어+8
            """,
            xpReward: 25,
            order: 1
        )
        try await lesson2_1.save(on: database)

        // Lesson 2-2: 장비 슬롯
        let lesson2_2 = Lesson(
            id: UUID(uuidString: "44444444-4444-4444-4444-444444300202"),
            chapterId: chapter2.id!,
            title: "장비 슬롯",
            content: """
            # 🎒 장비 슬롯 시스템

            영웅은 무기와 방어구를 장착할 수 있습니다.
            하지만 **장착하지 않은 슬롯도 있을 수 있죠**!

            ---

            ## 📚 Optional로 빈 슬롯 표현

            ```swift
            class Hero {
                var weapon: Item? = nil      // 무기 미장착
                var armor: Item? = nil       // 방어구 미장착
            }
            ```

            `nil`은 "아무것도 장착 안 됨"을 의미합니다.

            ---

            ## 🎯 미션

            Hero에 장비 슬롯을 추가하고,
            무기를 장착한 후 총 공격력을 계산하세요.

            총 공격력 = 기본 공격력 + 무기 보너스
            """,
            type: .codeExercise,
            language: .swift,
            starterCode: """
            enum ItemType { case weapon, armor }

            struct Item {
                let name: String
                let type: ItemType
                let attackBonus: Int
                let defenseBonus: Int
            }

            class Hero {
                var name: String
                var baseAttack: Int
                var weapon: Item? = nil  // 무기 슬롯
                var armor: Item? = nil   // 방어구 슬롯

                init(name: String, baseAttack: Int) {
                    self.name = name
                    self.baseAttack = baseAttack
                }

                // 총 공격력 계산 (기본 + 무기 보너스)
                var totalAttack: Int {
                    // weapon이 있으면 보너스 추가, 없으면 기본값만

                }
            }

            let hero = Hero(name: "아서", baseAttack: 15)
            print("기본 공격력: \\(hero.totalAttack)")

            let sword = Item(name: "강철 검", type: .weapon, attackBonus: 10, defenseBonus: 0)
            hero.weapon = sword
            print("검 장착 후: \\(hero.totalAttack)")
            """,
            solutionCode: """
            enum ItemType { case weapon, armor }

            struct Item {
                let name: String
                let type: ItemType
                let attackBonus: Int
                let defenseBonus: Int
            }

            class Hero {
                var name: String
                var baseAttack: Int
                var weapon: Item? = nil
                var armor: Item? = nil

                init(name: String, baseAttack: Int) {
                    self.name = name
                    self.baseAttack = baseAttack
                }

                var totalAttack: Int {
                    return baseAttack + (weapon?.attackBonus ?? 0)
                }
            }

            let hero = Hero(name: "아서", baseAttack: 15)
            print("기본 공격력: \\(hero.totalAttack)")

            let sword = Item(name: "강철 검", type: .weapon, attackBonus: 10, defenseBonus: 0)
            hero.weapon = sword
            print("검 장착 후: \\(hero.totalAttack)")
            """,
            expectedOutput: """
            기본 공격력: 15
            검 장착 후: 25
            """,
            xpReward: 30,
            order: 2
        )
        try await lesson2_2.save(on: database)

        // Lesson 2-3: 아이템 장착/해제
        let lesson2_3 = Lesson(
            id: UUID(uuidString: "44444444-4444-4444-4444-444444300203"),
            chapterId: chapter2.id!,
            title: "아이템 장착/해제",
            content: """
            # 🔄 장비 교체 시스템

            새 장비를 장착하면 기존 장비는 어떻게 될까요?
            **기존 아이템을 반환**하고 새 아이템을 장착해야 합니다!

            ---

            ## 📚 Optional 반환

            ```swift
            func equip(_ item: Item) -> Item? {
                let oldItem = weapon  // 기존 아이템 (nil일 수 있음)
                weapon = item         // 새 아이템 장착
                return oldItem        // 기존 아이템 반환
            }
            ```

            ---

            ## 🎯 미션

            `equipWeapon` 메서드를 구현하세요:
            - 새 무기를 장착하고
            - 기존 무기가 있으면 반환, 없으면 nil 반환
            """,
            type: .codeExercise,
            language: .swift,
            starterCode: """
            enum ItemType { case weapon, armor }

            struct Item {
                let name: String
                let type: ItemType
                let attackBonus: Int
            }

            class Hero {
                var name: String
                var weapon: Item? = nil

                init(name: String) {
                    self.name = name
                }

                // 무기 장착: 기존 무기 반환
                func equipWeapon(_ newWeapon: Item) -> Item? {

                }
            }

            let hero = Hero(name: "아서")

            let sword = Item(name: "강철 검", type: .weapon, attackBonus: 10)
            let oldWeapon1 = hero.equipWeapon(sword)
            print("첫 장착 - 반환된 무기: \\(oldWeapon1?.name ?? "없음")")

            let axe = Item(name: "전투 도끼", type: .weapon, attackBonus: 15)
            let oldWeapon2 = hero.equipWeapon(axe)
            print("교체 후 - 반환된 무기: \\(oldWeapon2?.name ?? "없음")")
            print("현재 무기: \\(hero.weapon?.name ?? "없음")")
            """,
            solutionCode: """
            enum ItemType { case weapon, armor }

            struct Item {
                let name: String
                let type: ItemType
                let attackBonus: Int
            }

            class Hero {
                var name: String
                var weapon: Item? = nil

                init(name: String) {
                    self.name = name
                }

                func equipWeapon(_ newWeapon: Item) -> Item? {
                    let oldWeapon = weapon
                    weapon = newWeapon
                    return oldWeapon
                }
            }

            let hero = Hero(name: "아서")

            let sword = Item(name: "강철 검", type: .weapon, attackBonus: 10)
            let oldWeapon1 = hero.equipWeapon(sword)
            print("첫 장착 - 반환된 무기: \\(oldWeapon1?.name ?? "없음")")

            let axe = Item(name: "전투 도끼", type: .weapon, attackBonus: 15)
            let oldWeapon2 = hero.equipWeapon(axe)
            print("교체 후 - 반환된 무기: \\(oldWeapon2?.name ?? "없음")")
            print("현재 무기: \\(hero.weapon?.name ?? "없음")")
            """,
            expectedOutput: """
            첫 장착 - 반환된 무기: 없음
            교체 후 - 반환된 무기: 강철 검
            현재 무기: 전투 도끼
            """,
            xpReward: 35,
            order: 3
        )
        try await lesson2_3.save(on: database)

        // Lesson 2-4: 인벤토리 관리
        let lesson2_4 = Lesson(
            id: UUID(uuidString: "44444444-4444-4444-4444-444444300204"),
            chapterId: chapter2.id!,
            title: "인벤토리 관리",
            content: """
            # 📦 인벤토리 시스템

            영웅은 여러 아이템을 가방에 보관합니다.
            인벤토리에서 아이템을 검색하고 사용해봅시다!

            ---

            ## 📚 first(where:)

            배열에서 조건에 맞는 첫 번째 요소를 찾습니다.

            ```swift
            let items = [item1, item2, item3]
            let sword = items.first { $0.type == .weapon }
            // Optional<Item> 반환
            ```

            ---

            ## 🎯 미션

            `Inventory` 클래스의 메서드를 완성하세요:
            - `findItem(named:)`: 이름으로 아이템 찾기
            - `findWeapon()`: 첫 번째 무기 찾기
            """,
            type: .codeExercise,
            language: .swift,
            starterCode: """
            enum ItemType { case weapon, armor, potion }

            struct Item {
                let name: String
                let type: ItemType
            }

            class Inventory {
                var items: [Item] = []

                func add(_ item: Item) {
                    items.append(item)
                }

                // 이름으로 아이템 찾기
                func findItem(named name: String) -> Item? {

                }

                // 첫 번째 무기 찾기
                func findWeapon() -> Item? {

                }
            }

            let inventory = Inventory()
            inventory.add(Item(name: "체력 포션", type: .potion))
            inventory.add(Item(name: "강철 검", type: .weapon))
            inventory.add(Item(name: "가죽 갑옷", type: .armor))

            if let sword = inventory.findItem(named: "강철 검") {
                print("찾음: \\(sword.name)")
            }

            if let weapon = inventory.findWeapon() {
                print("무기 발견: \\(weapon.name)")
            }
            """,
            solutionCode: """
            enum ItemType { case weapon, armor, potion }

            struct Item {
                let name: String
                let type: ItemType
            }

            class Inventory {
                var items: [Item] = []

                func add(_ item: Item) {
                    items.append(item)
                }

                func findItem(named name: String) -> Item? {
                    return items.first { $0.name == name }
                }

                func findWeapon() -> Item? {
                    return items.first { $0.type == .weapon }
                }
            }

            let inventory = Inventory()
            inventory.add(Item(name: "체력 포션", type: .potion))
            inventory.add(Item(name: "강철 검", type: .weapon))
            inventory.add(Item(name: "가죽 갑옷", type: .armor))

            if let sword = inventory.findItem(named: "강철 검") {
                print("찾음: \\(sword.name)")
            }

            if let weapon = inventory.findWeapon() {
                print("무기 발견: \\(weapon.name)")
            }
            """,
            expectedOutput: """
            찾음: 강철 검
            무기 발견: 강철 검
            """,
            xpReward: 35,
            order: 4
        )
        try await lesson2_4.save(on: database)

        // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        // MARK: - Chapter 3: 스킬 시스템
        // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        let chapter3 = Chapter(
            id: UUID(uuidString: "33333333-3333-3333-3333-333333333003"),
            courseId: pixelQuestCourse.id!,
            title: "스킬 시스템",
            description: "다양한 스킬 효과를 Closure로 구현하며 함수형 프로그래밍을 배웁니다.",
            order: 3
        )
        try await chapter3.save(on: database)

        // Lesson 3-1: 스킬 효과 정의
        let lesson3_1 = Lesson(
            id: UUID(uuidString: "44444444-4444-4444-4444-444444300301"),
            chapterId: chapter3.id!,
            title: "스킬 효과 정의",
            content: """
            # ⚡ 스킬 시스템

            PixelQuest의 영웅은 다양한 스킬을 사용합니다.
            각 스킬은 **다른 효과**를 가지죠!

            ---

            ## 📚 Closure로 효과 정의

            스킬 효과를 Closure로 정의하면 유연하게 확장할 수 있습니다.

            ```swift
            // 타입 별칭으로 가독성 향상
            typealias SkillEffect = (Hero) -> Int  // 데미지 반환

            let fireball: SkillEffect = { hero in
                return hero.stats.attack * 2
            }
            ```

            ---

            ## 🎯 미션

            3가지 스킬을 Closure로 구현하세요:
            - `normalAttack`: 공격력 × 1
            - `powerStrike`: 공격력 × 2
            - `criticalHit`: 공격력 × 3
            """,
            type: .codeExercise,
            language: .swift,
            starterCode: """
            struct Hero {
                var name: String
                var attack: Int
            }

            typealias SkillEffect = (Hero) -> Int

            // 기본 공격
            let normalAttack: SkillEffect = { hero in

            }

            // 강타: 공격력 × 2
            let powerStrike: SkillEffect = // ...

            // 크리티컬: 공격력 × 3
            let criticalHit: SkillEffect = // ...

            let hero = Hero(name: "아서", attack: 20)

            print("기본 공격: \\(normalAttack(hero)) 데미지")
            print("강타: \\(powerStrike(hero)) 데미지")
            print("크리티컬: \\(criticalHit(hero)) 데미지")
            """,
            solutionCode: """
            struct Hero {
                var name: String
                var attack: Int
            }

            typealias SkillEffect = (Hero) -> Int

            let normalAttack: SkillEffect = { hero in
                return hero.attack
            }

            let powerStrike: SkillEffect = { hero in
                return hero.attack * 2
            }

            let criticalHit: SkillEffect = { hero in
                return hero.attack * 3
            }

            let hero = Hero(name: "아서", attack: 20)

            print("기본 공격: \\(normalAttack(hero)) 데미지")
            print("강타: \\(powerStrike(hero)) 데미지")
            print("크리티컬: \\(criticalHit(hero)) 데미지")
            """,
            expectedOutput: """
            기본 공격: 20 데미지
            강타: 40 데미지
            크리티컬: 60 데미지
            """,
            xpReward: 30,
            order: 1
        )
        try await lesson3_1.save(on: database)

        // Lesson 3-2: 스킬 객체화
        let lesson3_2 = Lesson(
            id: UUID(uuidString: "44444444-4444-4444-4444-444444300302"),
            chapterId: chapter3.id!,
            title: "스킬 객체화",
            content: """
            # 📜 스킬 카드

            스킬을 더 체계적으로 관리하려면 객체로 만들어야 합니다.
            이름, 설명, 마나 비용, 효과를 하나로 묶어봅시다!

            ---

            ## 📚 Closure를 프로퍼티로

            ```swift
            struct Skill {
                let name: String
                let manaCost: Int
                let effect: (Hero) -> Int
            }
            ```

            ---

            ## 🎯 미션

            `Skill` struct를 완성하고, `useSkill` 메서드를 구현하세요.
            마나가 부족하면 스킬 사용 실패!
            """,
            type: .codeExercise,
            language: .swift,
            starterCode: """
            class Hero {
                var name: String
                var attack: Int
                var mana: Int

                init(name: String, attack: Int, mana: Int) {
                    self.name = name
                    self.attack = attack
                    self.mana = mana
                }
            }

            struct Skill {
                let name: String
                let manaCost: Int
                let effect: (Hero) -> Int

                // 스킬 사용: 마나 소모 후 데미지 반환, 마나 부족시 nil
                func use(by hero: Hero) -> Int? {
                    // 마나 체크 후 사용

                }
            }

            let hero = Hero(name: "아서", attack: 20, mana: 30)
            let fireball = Skill(name: "파이어볼", manaCost: 25) { hero in
                return hero.attack * 3
            }

            if let damage = fireball.use(by: hero) {
                print("\\(fireball.name)! \\(damage) 데미지!")
                print("남은 마나: \\(hero.mana)")
            }

            // 마나 부족
            if let damage = fireball.use(by: hero) {
                print("\\(damage) 데미지!")
            } else {
                print("마나가 부족합니다!")
            }
            """,
            solutionCode: """
            class Hero {
                var name: String
                var attack: Int
                var mana: Int

                init(name: String, attack: Int, mana: Int) {
                    self.name = name
                    self.attack = attack
                    self.mana = mana
                }
            }

            struct Skill {
                let name: String
                let manaCost: Int
                let effect: (Hero) -> Int

                func use(by hero: Hero) -> Int? {
                    guard hero.mana >= manaCost else {
                        return nil
                    }
                    hero.mana -= manaCost
                    return effect(hero)
                }
            }

            let hero = Hero(name: "아서", attack: 20, mana: 30)
            let fireball = Skill(name: "파이어볼", manaCost: 25) { hero in
                return hero.attack * 3
            }

            if let damage = fireball.use(by: hero) {
                print("\\(fireball.name)! \\(damage) 데미지!")
                print("남은 마나: \\(hero.mana)")
            }

            if let damage = fireball.use(by: hero) {
                print("\\(damage) 데미지!")
            } else {
                print("마나가 부족합니다!")
            }
            """,
            expectedOutput: """
            파이어볼! 60 데미지!
            남은 마나: 5
            마나가 부족합니다!
            """,
            xpReward: 35,
            order: 2
        )
        try await lesson3_2.save(on: database)

        // Lesson 3-3: 스킬 조합
        let lesson3_3 = Lesson(
            id: UUID(uuidString: "44444444-4444-4444-4444-444444300303"),
            chapterId: chapter3.id!,
            title: "스킬 조합",
            content: """
            # 🔮 콤보 스킬

            여러 스킬을 조합해서 강력한 콤보를 만들어봅시다!
            **고차 함수**로 스킬을 합성할 수 있습니다.

            ---

            ## 📚 함수를 반환하는 함수

            ```swift
            func createComboSkill(skills: [Skill]) -> (Hero) -> Int {
                return { hero in
                    skills.reduce(0) { total, skill in
                        total + skill.effect(hero)
                    }
                }
            }
            ```

            ---

            ## 🎯 미션

            `createBuffedSkill` 함수를 구현하세요.
            기존 스킬에 배수(multiplier)를 적용한 새 스킬을 반환합니다.
            """,
            type: .codeExercise,
            language: .swift,
            starterCode: """
            struct Hero {
                var attack: Int
            }

            typealias SkillEffect = (Hero) -> Int

            // 기본 스킬에 버프를 적용한 새 스킬 생성
            func createBuffedSkill(base: @escaping SkillEffect, multiplier: Int) -> SkillEffect {
                // 기존 스킬 데미지 × multiplier 반환

            }

            let hero = Hero(attack: 20)

            let normalAttack: SkillEffect = { $0.attack }
            print("기본 공격: \\(normalAttack(hero))")

            let buffedAttack = createBuffedSkill(base: normalAttack, multiplier: 3)
            print("3배 버프 공격: \\(buffedAttack(hero))")

            let superBuffed = createBuffedSkill(base: buffedAttack, multiplier: 2)
            print("추가 2배 버프: \\(superBuffed(hero))")
            """,
            solutionCode: """
            struct Hero {
                var attack: Int
            }

            typealias SkillEffect = (Hero) -> Int

            func createBuffedSkill(base: @escaping SkillEffect, multiplier: Int) -> SkillEffect {
                return { hero in
                    return base(hero) * multiplier
                }
            }

            let hero = Hero(attack: 20)

            let normalAttack: SkillEffect = { $0.attack }
            print("기본 공격: \\(normalAttack(hero))")

            let buffedAttack = createBuffedSkill(base: normalAttack, multiplier: 3)
            print("3배 버프 공격: \\(buffedAttack(hero))")

            let superBuffed = createBuffedSkill(base: buffedAttack, multiplier: 2)
            print("추가 2배 버프: \\(superBuffed(hero))")
            """,
            expectedOutput: """
            기본 공격: 20
            3배 버프 공격: 60
            추가 2배 버프: 120
            """,
            xpReward: 40,
            order: 3
        )
        try await lesson3_3.save(on: database)

        // Lesson 3-4: 스킬 쿨다운
        let lesson3_4 = Lesson(
            id: UUID(uuidString: "44444444-4444-4444-4444-444444300304"),
            chapterId: chapter3.id!,
            title: "스킬 쿨다운",
            content: """
            # ⏱️ 쿨다운 시스템

            강력한 스킬은 재사용까지 시간이 필요합니다.
            **Closure가 외부 변수를 캡처**하는 특성을 활용해봅시다!

            ---

            ## 📚 Capturing Values

            Closure는 자신이 정의된 범위의 변수를 "캡처"합니다.

            ```swift
            func makeCounter() -> () -> Int {
                var count = 0
                return {
                    count += 1
                    return count
                }
            }

            let counter = makeCounter()
            print(counter())  // 1
            print(counter())  // 2
            ```

            ---

            ## 🎯 미션

            `createSkillWithCooldown` 함수를 구현하세요.
            쿨다운 중이면 nil, 아니면 데미지 반환.
            """,
            type: .codeExercise,
            language: .swift,
            starterCode: """
            struct Hero {
                var attack: Int
            }

            // 쿨다운이 있는 스킬 생성
            func createSkillWithCooldown(damage: Int, cooldown: Int) -> (Hero) -> Int? {
                var remainingCooldown = 0

                return { hero in
                    // 쿨다운 중이면 nil, 턴 감소
                    // 사용 가능하면 데미지 반환, 쿨다운 설정

                }
            }

            let hero = Hero(attack: 20)
            let ultimateSkill = createSkillWithCooldown(damage: 100, cooldown: 3)

            for turn in 1...5 {
                if let damage = ultimateSkill(hero) {
                    print("턴 \\(turn): 궁극기 발동! \\(damage) 데미지")
                } else {
                    print("턴 \\(turn): 쿨다운 중...")
                }
            }
            """,
            solutionCode: """
            struct Hero {
                var attack: Int
            }

            func createSkillWithCooldown(damage: Int, cooldown: Int) -> (Hero) -> Int? {
                var remainingCooldown = 0

                return { hero in
                    if remainingCooldown > 0 {
                        remainingCooldown -= 1
                        return nil
                    }
                    remainingCooldown = cooldown
                    return damage
                }
            }

            let hero = Hero(attack: 20)
            let ultimateSkill = createSkillWithCooldown(damage: 100, cooldown: 3)

            for turn in 1...5 {
                if let damage = ultimateSkill(hero) {
                    print("턴 \\(turn): 궁극기 발동! \\(damage) 데미지")
                } else {
                    print("턴 \\(turn): 쿨다운 중...")
                }
            }
            """,
            expectedOutput: """
            턴 1: 궁극기 발동! 100 데미지
            턴 2: 쿨다운 중...
            턴 3: 쿨다운 중...
            턴 4: 쿨다운 중...
            턴 5: 궁극기 발동! 100 데미지
            """,
            xpReward: 45,
            order: 4
        )
        try await lesson3_4.save(on: database)

        // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        // MARK: - Chapter 4: 전투 시스템
        // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        let chapter4 = Chapter(
            id: UUID(uuidString: "33333333-3333-3333-3333-333333333004"),
            courseId: pixelQuestCourse.id!,
            title: "전투 시스템",
            description: "Protocol을 사용해 유연한 전투 시스템을 구축합니다.",
            order: 4
        )
        try await chapter4.save(on: database)

        // Lesson 4-1: 전투 가능 유닛
        let lesson4_1 = Lesson(
            id: UUID(uuidString: "44444444-4444-4444-4444-444444300401"),
            chapterId: chapter4.id!,
            title: "전투 가능 유닛",
            content: """
            # ⚔️ 전투 인터페이스

            영웅, 몬스터, 보스... 모두 전투할 수 있어야 합니다.
            **Protocol**로 공통 인터페이스를 정의해봅시다!

            ---

            ## 📚 Combatant Protocol

            ```swift
            protocol Combatant {
                var name: String { get }
                var hp: Int { get set }
                var attack: Int { get }

                func takeDamage(_ amount: Int)
                func isAlive() -> Bool
            }
            ```

            ---

            ## 🎯 미션

            `Combatant` 프로토콜을 정의하고,
            `Hero`와 `Monster` 클래스가 이를 채택하게 하세요.
            """,
            type: .codeExercise,
            language: .swift,
            starterCode: """
            // Combatant 프로토콜 정의


            class Hero: Combatant {
                var name: String
                var hp: Int
                var attack: Int

                init(name: String, hp: Int, attack: Int) {
                    self.name = name
                    self.hp = hp
                    self.attack = attack
                }

                // 프로토콜 메서드 구현

            }

            class Monster: Combatant {
                var name: String
                var hp: Int
                var attack: Int

                init(name: String, hp: Int, attack: Int) {
                    self.name = name
                    self.hp = hp
                    self.attack = attack
                }

                // 프로토콜 메서드 구현

            }

            let hero = Hero(name: "아서", hp: 100, attack: 20)
            let slime = Monster(name: "슬라임", hp: 30, attack: 5)

            slime.takeDamage(25)
            print("\\(slime.name) HP: \\(slime.hp), 생존: \\(slime.isAlive())")
            """,
            solutionCode: """
            protocol Combatant {
                var name: String { get }
                var hp: Int { get set }
                var attack: Int { get }

                mutating func takeDamage(_ amount: Int)
                func isAlive() -> Bool
            }

            class Hero: Combatant {
                var name: String
                var hp: Int
                var attack: Int

                init(name: String, hp: Int, attack: Int) {
                    self.name = name
                    self.hp = hp
                    self.attack = attack
                }

                func takeDamage(_ amount: Int) {
                    hp -= amount
                    if hp < 0 { hp = 0 }
                }

                func isAlive() -> Bool {
                    return hp > 0
                }
            }

            class Monster: Combatant {
                var name: String
                var hp: Int
                var attack: Int

                init(name: String, hp: Int, attack: Int) {
                    self.name = name
                    self.hp = hp
                    self.attack = attack
                }

                func takeDamage(_ amount: Int) {
                    hp -= amount
                    if hp < 0 { hp = 0 }
                }

                func isAlive() -> Bool {
                    return hp > 0
                }
            }

            let hero = Hero(name: "아서", hp: 100, attack: 20)
            let slime = Monster(name: "슬라임", hp: 30, attack: 5)

            slime.takeDamage(25)
            print("\\(slime.name) HP: \\(slime.hp), 생존: \\(slime.isAlive())")
            """,
            expectedOutput: "슬라임 HP: 5, 생존: true",
            xpReward: 30,
            order: 1
        )
        try await lesson4_1.save(on: database)

        // Lesson 4-2: 공격 시스템
        let lesson4_2 = Lesson(
            id: UUID(uuidString: "44444444-4444-4444-4444-444444300402"),
            chapterId: chapter4.id!,
            title: "공격 시스템",
            content: """
            # 💥 공격 기능

            전투의 핵심은 공격입니다!
            Protocol Extension으로 기본 공격 기능을 구현해봅시다.

            ---

            ## 📚 Protocol Extension

            모든 Combatant에 공통 기능을 추가합니다.

            ```swift
            extension Combatant {
                func attackTarget(_ target: Combatant) {
                    target.takeDamage(self.attack)
                }
            }
            ```

            ---

            ## 🎯 미션

            `Combatant` extension에 `attack(_:)` 메서드를 추가하세요.
            공격 시 로그를 출력하고 데미지를 적용합니다.
            """,
            type: .codeExercise,
            language: .swift,
            starterCode: """
            protocol Combatant: AnyObject {
                var name: String { get }
                var hp: Int { get set }
                var attack: Int { get }
                func takeDamage(_ amount: Int)
                func isAlive() -> Bool
            }

            extension Combatant {
                func takeDamage(_ amount: Int) {
                    hp -= amount
                    if hp < 0 { hp = 0 }
                }

                func isAlive() -> Bool { hp > 0 }

                // attack 메서드 추가
                // "[자신] -> [대상] \\(attack) 데미지!" 출력
                func attack(_ target: Combatant) {

                }
            }

            class Hero: Combatant {
                var name: String
                var hp: Int
                var attack: Int
                init(name: String, hp: Int, attack: Int) {
                    self.name = name; self.hp = hp; self.attack = attack
                }
            }

            class Monster: Combatant {
                var name: String
                var hp: Int
                var attack: Int
                init(name: String, hp: Int, attack: Int) {
                    self.name = name; self.hp = hp; self.attack = attack
                }
            }

            let hero = Hero(name: "아서", hp: 100, attack: 25)
            let goblin = Monster(name: "고블린", hp: 40, attack: 10)

            hero.attack(goblin)
            print("\\(goblin.name) 남은 HP: \\(goblin.hp)")
            """,
            solutionCode: """
            protocol Combatant: AnyObject {
                var name: String { get }
                var hp: Int { get set }
                var attack: Int { get }
                func takeDamage(_ amount: Int)
                func isAlive() -> Bool
            }

            extension Combatant {
                func takeDamage(_ amount: Int) {
                    hp -= amount
                    if hp < 0 { hp = 0 }
                }

                func isAlive() -> Bool { hp > 0 }

                func attack(_ target: Combatant) {
                    print("\\(name) -> \\(target.name) \\(attack) 데미지!")
                    target.takeDamage(attack)
                }
            }

            class Hero: Combatant {
                var name: String
                var hp: Int
                var attack: Int
                init(name: String, hp: Int, attack: Int) {
                    self.name = name; self.hp = hp; self.attack = attack
                }
            }

            class Monster: Combatant {
                var name: String
                var hp: Int
                var attack: Int
                init(name: String, hp: Int, attack: Int) {
                    self.name = name; self.hp = hp; self.attack = attack
                }
            }

            let hero = Hero(name: "아서", hp: 100, attack: 25)
            let goblin = Monster(name: "고블린", hp: 40, attack: 10)

            hero.attack(goblin)
            print("\\(goblin.name) 남은 HP: \\(goblin.hp)")
            """,
            expectedOutput: """
            아서 -> 고블린 25 데미지!
            고블린 남은 HP: 15
            """,
            xpReward: 35,
            order: 2
        )
        try await lesson4_2.save(on: database)

        // Lesson 4-3: 전투 루프
        let lesson4_3 = Lesson(
            id: UUID(uuidString: "44444444-4444-4444-4444-444444300403"),
            chapterId: chapter4.id!,
            title: "전투 루프",
            content: """
            # 🔄 턴제 전투

            영웅과 몬스터가 번갈아 공격하는 전투 시스템!
            한쪽이 쓰러질 때까지 반복합니다.

            ---

            ## 📚 while 루프

            ```swift
            while hero.isAlive() && monster.isAlive() {
                hero.attack(monster)
                if monster.isAlive() {
                    monster.attack(hero)
                }
            }
            ```

            ---

            ## 🎯 미션

            `battle` 함수를 완성하세요.
            영웅 먼저 공격, 몬스터가 살아있으면 반격.
            승자를 반환합니다.
            """,
            type: .codeExercise,
            language: .swift,
            starterCode: """
            protocol Combatant: AnyObject {
                var name: String { get }
                var hp: Int { get set }
                var attack: Int { get }
            }

            extension Combatant {
                func takeDamage(_ amount: Int) {
                    hp -= amount
                    if hp < 0 { hp = 0 }
                }
                func isAlive() -> Bool { hp > 0 }
                func attack(_ target: Combatant) {
                    target.takeDamage(attack)
                }
            }

            class Hero: Combatant {
                var name: String; var hp: Int; var attack: Int
                init(name: String, hp: Int, attack: Int) {
                    self.name = name; self.hp = hp; self.attack = attack
                }
            }

            class Monster: Combatant {
                var name: String; var hp: Int; var attack: Int
                init(name: String, hp: Int, attack: Int) {
                    self.name = name; self.hp = hp; self.attack = attack
                }
            }

            func battle(hero: Hero, monster: Monster) -> String {
                var turn = 1

                // 전투 루프
                while hero.isAlive() && monster.isAlive() {
                    print("--- 턴 \\(turn) ---")

                    // 영웅 공격

                    // 몬스터 반격 (살아있으면)

                    turn += 1
                }

                // 승자 반환
                return hero.isAlive() ? hero.name : monster.name
            }

            let hero = Hero(name: "아서", hp: 50, attack: 15)
            let orc = Monster(name: "오크", hp: 40, attack: 12)

            let winner = battle(hero: hero, monster: orc)
            print("승자: \\(winner)!")
            """,
            solutionCode: """
            protocol Combatant: AnyObject {
                var name: String { get }
                var hp: Int { get set }
                var attack: Int { get }
            }

            extension Combatant {
                func takeDamage(_ amount: Int) {
                    hp -= amount
                    if hp < 0 { hp = 0 }
                }
                func isAlive() -> Bool { hp > 0 }
                func attack(_ target: Combatant) {
                    target.takeDamage(attack)
                }
            }

            class Hero: Combatant {
                var name: String; var hp: Int; var attack: Int
                init(name: String, hp: Int, attack: Int) {
                    self.name = name; self.hp = hp; self.attack = attack
                }
            }

            class Monster: Combatant {
                var name: String; var hp: Int; var attack: Int
                init(name: String, hp: Int, attack: Int) {
                    self.name = name; self.hp = hp; self.attack = attack
                }
            }

            func battle(hero: Hero, monster: Monster) -> String {
                var turn = 1

                while hero.isAlive() && monster.isAlive() {
                    print("--- 턴 \\(turn) ---")

                    hero.attack(monster)
                    print("\\(hero.name) 공격! \\(monster.name) HP: \\(monster.hp)")

                    if monster.isAlive() {
                        monster.attack(hero)
                        print("\\(monster.name) 반격! \\(hero.name) HP: \\(hero.hp)")
                    }

                    turn += 1
                }

                return hero.isAlive() ? hero.name : monster.name
            }

            let hero = Hero(name: "아서", hp: 50, attack: 15)
            let orc = Monster(name: "오크", hp: 40, attack: 12)

            let winner = battle(hero: hero, monster: orc)
            print("승자: \\(winner)!")
            """,
            expectedOutput: """
            --- 턴 1 ---
            아서 공격! 오크 HP: 25
            오크 반격! 아서 HP: 38
            --- 턴 2 ---
            아서 공격! 오크 HP: 10
            오크 반격! 아서 HP: 26
            --- 턴 3 ---
            아서 공격! 오크 HP: 0
            승자: 아서!
            """,
            xpReward: 40,
            order: 3
        )
        try await lesson4_3.save(on: database)

        // Lesson 4-4: 특수 능력
        let lesson4_4 = Lesson(
            id: UUID(uuidString: "44444444-4444-4444-4444-444444300404"),
            chapterId: chapter4.id!,
            title: "특수 능력",
            content: """
            # ✨ 특수 능력

            일부 유닛은 특수 능력이 있습니다!
            **Protocol 상속**으로 확장된 인터페이스를 만들어봅시다.

            ---

            ## 📚 Protocol Inheritance

            ```swift
            protocol SpecialAttacker: Combatant {
                func specialAttack(_ target: Combatant)
            }
            ```

            ---

            ## 🎯 미션

            `SpecialAttacker` 프로토콜을 만들고,
            `Boss` 클래스가 이를 채택하게 하세요.
            특수 공격은 2배 데미지!
            """,
            type: .codeExercise,
            language: .swift,
            starterCode: """
            protocol Combatant: AnyObject {
                var name: String { get }
                var hp: Int { get set }
                var attack: Int { get }
            }

            extension Combatant {
                func takeDamage(_ amount: Int) {
                    hp -= amount
                    if hp < 0 { hp = 0 }
                }
                func isAlive() -> Bool { hp > 0 }
            }

            // SpecialAttacker 프로토콜 정의 (Combatant 상속)


            class Boss: SpecialAttacker {
                var name: String
                var hp: Int
                var attack: Int

                init(name: String, hp: Int, attack: Int) {
                    self.name = name
                    self.hp = hp
                    self.attack = attack
                }

                // 특수 공격: 2배 데미지 + 메시지 출력

            }

            class Hero: Combatant {
                var name: String; var hp: Int; var attack: Int
                init(name: String, hp: Int, attack: Int) {
                    self.name = name; self.hp = hp; self.attack = attack
                }
            }

            let hero = Hero(name: "아서", hp: 100, attack: 20)
            let boss = Boss(name: "드래곤", hp: 200, attack: 30)

            boss.specialAttack(hero)
            print("\\(hero.name) 남은 HP: \\(hero.hp)")
            """,
            solutionCode: """
            protocol Combatant: AnyObject {
                var name: String { get }
                var hp: Int { get set }
                var attack: Int { get }
            }

            extension Combatant {
                func takeDamage(_ amount: Int) {
                    hp -= amount
                    if hp < 0 { hp = 0 }
                }
                func isAlive() -> Bool { hp > 0 }
            }

            protocol SpecialAttacker: Combatant {
                func specialAttack(_ target: Combatant)
            }

            class Boss: SpecialAttacker {
                var name: String
                var hp: Int
                var attack: Int

                init(name: String, hp: Int, attack: Int) {
                    self.name = name
                    self.hp = hp
                    self.attack = attack
                }

                func specialAttack(_ target: Combatant) {
                    let damage = attack * 2
                    print("🔥 \\(name)의 특수 공격! \\(damage) 데미지!")
                    target.takeDamage(damage)
                }
            }

            class Hero: Combatant {
                var name: String; var hp: Int; var attack: Int
                init(name: String, hp: Int, attack: Int) {
                    self.name = name; self.hp = hp; self.attack = attack
                }
            }

            let hero = Hero(name: "아서", hp: 100, attack: 20)
            let boss = Boss(name: "드래곤", hp: 200, attack: 30)

            boss.specialAttack(hero)
            print("\\(hero.name) 남은 HP: \\(hero.hp)")
            """,
            expectedOutput: """
            🔥 드래곤의 특수 공격! 60 데미지!
            아서 남은 HP: 40
            """,
            xpReward: 40,
            order: 4
        )
        try await lesson4_4.save(on: database)

        // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        // MARK: - Chapter 5: 퀘스트 시스템
        // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        let chapter5 = Chapter(
            id: UUID(uuidString: "33333333-3333-3333-3333-333333333005"),
            courseId: pixelQuestCourse.id!,
            title: "퀘스트 시스템",
            description: "Generics를 사용해 유연한 퀘스트 시스템을 구축합니다.",
            order: 5
        )
        try await chapter5.save(on: database)

        // Lesson 5-1: 보상 타입
        let lesson5_1 = Lesson(
            id: UUID(uuidString: "44444444-4444-4444-4444-444444300501"),
            chapterId: chapter5.id!,
            title: "보상 타입",
            content: """
            # 🎁 다양한 보상

            퀘스트 보상은 다양합니다: 골드, 아이템, 경험치...
            모든 보상을 처리하는 유연한 시스템이 필요합니다!

            ---

            ## 📚 Generics 기초

            **제네릭**은 "어떤 타입이든" 처리할 수 있게 해줍니다.

            ```swift
            func printValue<T>(_ value: T) {
                print(value)
            }

            printValue(42)        // Int
            printValue("Hello")   // String
            printValue(true)      // Bool
            ```

            `<T>`는 "타입 파라미터"입니다.

            ---

            ## 🎯 미션

            제네릭 함수 `giveReward`를 만드세요.
            보상과 받는 사람 이름을 출력합니다.
            """,
            type: .codeExercise,
            language: .swift,
            starterCode: """
            struct Gold { let amount: Int }
            struct Item { let name: String }
            struct Experience { let points: Int }

            // 제네릭 함수: 어떤 보상이든 지급
            func giveReward<T>(_ reward: T, to playerName: String) {

            }

            giveReward(Gold(amount: 100), to: "아서")
            giveReward(Item(name: "전설의 검"), to: "아서")
            giveReward(Experience(points: 500), to: "아서")
            """,
            solutionCode: """
            struct Gold { let amount: Int }
            struct Item { let name: String }
            struct Experience { let points: Int }

            func giveReward<T>(_ reward: T, to playerName: String) {
                print("\\(playerName)에게 \\(reward) 지급!")
            }

            giveReward(Gold(amount: 100), to: "아서")
            giveReward(Item(name: "전설의 검"), to: "아서")
            giveReward(Experience(points: 500), to: "아서")
            """,
            expectedOutput: """
            아서에게 Gold(amount: 100) 지급!
            아서에게 Item(name: "전설의 검") 지급!
            아서에게 Experience(points: 500) 지급!
            """,
            xpReward: 30,
            order: 1
        )
        try await lesson5_1.save(on: database)

        // Lesson 5-2: 제네릭 퀘스트
        let lesson5_2 = Lesson(
            id: UUID(uuidString: "44444444-4444-4444-4444-444444300502"),
            chapterId: chapter5.id!,
            title: "제네릭 퀘스트",
            content: """
            # 📜 퀘스트 구조

            퀘스트는 제목, 설명, 그리고 **보상**을 가집니다.
            보상 타입이 다양하므로 Generic을 사용합니다!

            ---

            ## 📚 Generic Type

            ```swift
            struct Quest<RewardType> {
                let title: String
                let reward: RewardType
            }

            let goldQuest = Quest(title: "골드 퀘스트", reward: 100)
            let itemQuest = Quest(title: "아이템 퀘스트", reward: "검")
            ```

            ---

            ## 🎯 미션

            `Quest<T>` 구조체를 완성하세요.
            `complete` 메서드는 완료 메시지와 보상을 출력합니다.
            """,
            type: .codeExercise,
            language: .swift,
            starterCode: """
            struct Quest<RewardType> {
                let title: String
                let description: String
                let reward: RewardType

                // 퀘스트 완료: "[title] 완료! 보상: [reward]"
                func complete() {

                }
            }

            struct Gold { let amount: Int }
            struct Item { let name: String }

            let killSlimes = Quest(
                title: "슬라임 처치",
                description: "슬라임 10마리를 처치하세요",
                reward: Gold(amount: 50)
            )

            let findSword = Quest(
                title: "검 찾기",
                description: "잃어버린 검을 찾아오세요",
                reward: Item(name: "잃어버린 검")
            )

            killSlimes.complete()
            findSword.complete()
            """,
            solutionCode: """
            struct Quest<RewardType> {
                let title: String
                let description: String
                let reward: RewardType

                func complete() {
                    print("\\(title) 완료! 보상: \\(reward)")
                }
            }

            struct Gold { let amount: Int }
            struct Item { let name: String }

            let killSlimes = Quest(
                title: "슬라임 처치",
                description: "슬라임 10마리를 처치하세요",
                reward: Gold(amount: 50)
            )

            let findSword = Quest(
                title: "검 찾기",
                description: "잃어버린 검을 찾아오세요",
                reward: Item(name: "잃어버린 검")
            )

            killSlimes.complete()
            findSword.complete()
            """,
            expectedOutput: """
            슬라임 처치 완료! 보상: Gold(amount: 50)
            검 찾기 완료! 보상: Item(name: "잃어버린 검")
            """,
            xpReward: 35,
            order: 2
        )
        try await lesson5_2.save(on: database)

        // Lesson 5-3: 타입 제약
        let lesson5_3 = Lesson(
            id: UUID(uuidString: "44444444-4444-4444-4444-444444300503"),
            chapterId: chapter5.id!,
            title: "타입 제약",
            content: """
            # 🔒 보상 인터페이스

            모든 보상은 `describe()` 메서드를 가져야 합니다.
            **타입 제약**으로 이를 강제할 수 있습니다!

            ---

            ## 📚 Generic Constraints

            ```swift
            protocol Describable {
                func describe() -> String
            }

            func printInfo<T: Describable>(_ item: T) {
                print(item.describe())
            }
            ```

            `T: Describable`은 "T는 Describable을 채택해야 함"을 의미합니다.

            ---

            ## 🎯 미션

            `Reward` 프로토콜을 만들고,
            Quest가 이를 채택한 보상만 받도록 제약하세요.
            """,
            type: .codeExercise,
            language: .swift,
            starterCode: """
            // Reward 프로토콜: describe() -> String


            struct Gold: Reward {
                let amount: Int

                func describe() -> String {
                    return "💰 \\(amount) 골드"
                }
            }

            struct Item: Reward {
                let name: String

                // describe 구현

            }

            // Quest에 Reward 제약 추가
            struct Quest<RewardType: Reward> {
                let title: String
                let reward: RewardType

                func complete() {
                    print("✅ \\(title) 완료!")
                    print("보상: \\(reward.describe())")
                }
            }

            let quest = Quest(title: "드래곤 처치", reward: Item(name: "드래곤 검"))
            quest.complete()
            """,
            solutionCode: """
            protocol Reward {
                func describe() -> String
            }

            struct Gold: Reward {
                let amount: Int

                func describe() -> String {
                    return "💰 \\(amount) 골드"
                }
            }

            struct Item: Reward {
                let name: String

                func describe() -> String {
                    return "🎁 \\(name)"
                }
            }

            struct Quest<RewardType: Reward> {
                let title: String
                let reward: RewardType

                func complete() {
                    print("✅ \\(title) 완료!")
                    print("보상: \\(reward.describe())")
                }
            }

            let quest = Quest(title: "드래곤 처치", reward: Item(name: "드래곤 검"))
            quest.complete()
            """,
            expectedOutput: """
            ✅ 드래곤 처치 완료!
            보상: 🎁 드래곤 검
            """,
            xpReward: 40,
            order: 3
        )
        try await lesson5_3.save(on: database)

        // Lesson 5-4: 퀘스트 로그
        let lesson5_4 = Lesson(
            id: UUID(uuidString: "44444444-4444-4444-4444-444444300504"),
            chapterId: chapter5.id!,
            title: "퀘스트 로그",
            content: """
            # 📋 퀘스트 관리

            여러 퀘스트를 관리하는 퀘스트 로그를 만들어봅시다.
            **Protocol with Associated Type**을 사용합니다!

            ---

            ## 📚 Associated Type

            ```swift
            protocol Container {
                associatedtype ItemType
                var items: [ItemType] { get }
                mutating func add(_ item: ItemType)
            }
            ```

            ---

            ## 🎯 미션

            `QuestLog`를 구현하세요.
            퀘스트 추가, 완료, 활성 퀘스트 목록 기능을 만드세요.
            """,
            type: .codeExercise,
            language: .swift,
            starterCode: """
            protocol Reward {
                func describe() -> String
            }

            struct Gold: Reward {
                let amount: Int
                func describe() -> String { "💰 \\(amount) 골드" }
            }

            struct QuestInfo {
                let title: String
                let isCompleted: Bool
            }

            class QuestLog {
                private var quests: [(title: String, completed: Bool)] = []

                // 퀘스트 추가
                func add(questTitle: String) {

                }

                // 퀘스트 완료 처리
                func complete(questTitle: String) {

                }

                // 활성 퀘스트 목록 (미완료)
                var activeQuests: [String] {

                }
            }

            let log = QuestLog()
            log.add(questTitle: "슬라임 처치")
            log.add(questTitle: "골드 수집")
            log.add(questTitle: "보스 도전")

            print("활성 퀘스트: \\(log.activeQuests)")

            log.complete(questTitle: "슬라임 처치")
            print("완료 후 활성 퀘스트: \\(log.activeQuests)")
            """,
            solutionCode: """
            protocol Reward {
                func describe() -> String
            }

            struct Gold: Reward {
                let amount: Int
                func describe() -> String { "💰 \\(amount) 골드" }
            }

            struct QuestInfo {
                let title: String
                let isCompleted: Bool
            }

            class QuestLog {
                private var quests: [(title: String, completed: Bool)] = []

                func add(questTitle: String) {
                    quests.append((title: questTitle, completed: false))
                }

                func complete(questTitle: String) {
                    if let index = quests.firstIndex(where: { $0.title == questTitle }) {
                        quests[index].completed = true
                        print("✅ '\\(questTitle)' 완료!")
                    }
                }

                var activeQuests: [String] {
                    return quests.filter { !$0.completed }.map { $0.title }
                }
            }

            let log = QuestLog()
            log.add(questTitle: "슬라임 처치")
            log.add(questTitle: "골드 수집")
            log.add(questTitle: "보스 도전")

            print("활성 퀘스트: \\(log.activeQuests)")

            log.complete(questTitle: "슬라임 처치")
            print("완료 후 활성 퀘스트: \\(log.activeQuests)")
            """,
            expectedOutput: """
            활성 퀘스트: ["슬라임 처치", "골드 수집", "보스 도전"]
            ✅ '슬라임 처치' 완료!
            완료 후 활성 퀘스트: ["골드 수집", "보스 도전"]
            """,
            xpReward: 45,
            order: 4
        )
        try await lesson5_4.save(on: database)

        // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        // MARK: - Chapter 6: 보스 전투 (종합 프로젝트)
        // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        let chapter6 = Chapter(
            id: UUID(uuidString: "33333333-3333-3333-3333-333333333006"),
            courseId: pixelQuestCourse.id!,
            title: "보스 전투",
            description: "모든 개념을 활용해 최종 보스전을 구현합니다.",
            order: 6
        )
        try await chapter6.save(on: database)

        // Lesson 6-1: 보스 설계
        let lesson6_1 = Lesson(
            id: UUID(uuidString: "44444444-4444-4444-4444-444444300601"),
            chapterId: chapter6.id!,
            title: "보스 설계",
            content: """
            # 🐉 최종 보스: 드래곤 킹

            PixelQuest의 최종 보스를 만들어봅시다!
            지금까지 배운 모든 개념을 활용합니다.

            ---

            ## 📚 보스 요구사항

            - 높은 HP와 공격력
            - 특수 공격 (3턴마다)
            - 페이즈 변환 (HP 50% 이하 시 분노 모드)

            ---

            ## 🎯 미션

            `DragonKing` 클래스를 구현하세요.
            - HP 300, 공격력 25
            - 분노 모드: 공격력 1.5배
            - `shouldEnrage()`: HP가 절반 이하인지 체크
            """,
            type: .codeExercise,
            language: .swift,
            starterCode: """
            protocol Combatant: AnyObject {
                var name: String { get }
                var hp: Int { get set }
                var maxHp: Int { get }
                var attack: Int { get }
            }

            extension Combatant {
                func takeDamage(_ amount: Int) {
                    hp -= amount
                    if hp < 0 { hp = 0 }
                }
                func isAlive() -> Bool { hp > 0 }
            }

            class DragonKing: Combatant {
                let name = "드래곤 킹"
                var hp: Int
                let maxHp: Int
                let baseAttack: Int
                var isEnraged: Bool = false

                init() {
                    self.maxHp = 300
                    self.hp = 300
                    self.baseAttack = 25
                }

                var attack: Int {
                    // 분노 모드면 1.5배

                }

                func shouldEnrage() -> Bool {
                    // HP가 절반 이하이고 아직 분노 안 했으면

                }

                func checkEnrage() {
                    if shouldEnrage() {
                        isEnraged = true
                        print("🔥 드래곤 킹이 분노했다! 공격력 상승!")
                    }
                }
            }

            let boss = DragonKing()
            print("HP: \\(boss.hp)/\\(boss.maxHp), 공격력: \\(boss.attack)")

            boss.takeDamage(180)
            boss.checkEnrage()
            print("HP: \\(boss.hp)/\\(boss.maxHp), 공격력: \\(boss.attack)")
            """,
            solutionCode: """
            protocol Combatant: AnyObject {
                var name: String { get }
                var hp: Int { get set }
                var maxHp: Int { get }
                var attack: Int { get }
            }

            extension Combatant {
                func takeDamage(_ amount: Int) {
                    hp -= amount
                    if hp < 0 { hp = 0 }
                }
                func isAlive() -> Bool { hp > 0 }
            }

            class DragonKing: Combatant {
                let name = "드래곤 킹"
                var hp: Int
                let maxHp: Int
                let baseAttack: Int
                var isEnraged: Bool = false

                init() {
                    self.maxHp = 300
                    self.hp = 300
                    self.baseAttack = 25
                }

                var attack: Int {
                    return isEnraged ? Int(Double(baseAttack) * 1.5) : baseAttack
                }

                func shouldEnrage() -> Bool {
                    return hp <= maxHp / 2 && !isEnraged
                }

                func checkEnrage() {
                    if shouldEnrage() {
                        isEnraged = true
                        print("🔥 드래곤 킹이 분노했다! 공격력 상승!")
                    }
                }
            }

            let boss = DragonKing()
            print("HP: \\(boss.hp)/\\(boss.maxHp), 공격력: \\(boss.attack)")

            boss.takeDamage(180)
            boss.checkEnrage()
            print("HP: \\(boss.hp)/\\(boss.maxHp), 공격력: \\(boss.attack)")
            """,
            expectedOutput: """
            HP: 300/300, 공격력: 25
            🔥 드래곤 킹이 분노했다! 공격력 상승!
            HP: 120/300, 공격력: 37
            """,
            xpReward: 40,
            order: 1
        )
        try await lesson6_1.save(on: database)

        // Lesson 6-2: 파티 시스템
        let lesson6_2 = Lesson(
            id: UUID(uuidString: "44444444-4444-4444-4444-444444300602"),
            chapterId: chapter6.id!,
            title: "파티 시스템",
            content: """
            # 👥 영웅 파티

            혼자서는 보스를 이길 수 없습니다!
            파티를 구성하고 협동 공격을 구현합시다.

            ---

            ## 🎯 미션

            `Party` 클래스를 구현하세요:
            - 영웅 목록 관리
            - `totalDamage`: 모든 영웅 공격력 합
            - `allAttack(target:)`: 모든 영웅이 공격
            - `anyAlive()`: 살아있는 영웅 있는지 체크
            """,
            type: .codeExercise,
            language: .swift,
            starterCode: """
            class Hero {
                let name: String
                var hp: Int
                let attack: Int

                init(name: String, hp: Int, attack: Int) {
                    self.name = name
                    self.hp = hp
                    self.attack = attack
                }

                func isAlive() -> Bool { hp > 0 }
                func takeDamage(_ amount: Int) { hp = max(0, hp - amount) }
            }

            class Enemy {
                let name: String
                var hp: Int

                init(name: String, hp: Int) {
                    self.name = name
                    self.hp = hp
                }

                func takeDamage(_ amount: Int) { hp = max(0, hp - amount) }
            }

            class Party {
                var members: [Hero]

                init(members: [Hero]) {
                    self.members = members
                }

                // 살아있는 멤버들의 총 공격력
                var totalDamage: Int {

                }

                // 모든 멤버가 대상 공격
                func allAttack(target: Enemy) {

                }

                // 살아있는 멤버가 있는지
                func anyAlive() -> Bool {

                }
            }

            let party = Party(members: [
                Hero(name: "아서", hp: 100, attack: 20),
                Hero(name: "멀린", hp: 60, attack: 30),
                Hero(name: "란슬롯", hp: 80, attack: 25)
            ])

            let dragon = Enemy(name: "드래곤", hp: 200)

            print("파티 총 공격력: \\(party.totalDamage)")
            party.allAttack(target: dragon)
            print("드래곤 남은 HP: \\(dragon.hp)")
            """,
            solutionCode: """
            class Hero {
                let name: String
                var hp: Int
                let attack: Int

                init(name: String, hp: Int, attack: Int) {
                    self.name = name
                    self.hp = hp
                    self.attack = attack
                }

                func isAlive() -> Bool { hp > 0 }
                func takeDamage(_ amount: Int) { hp = max(0, hp - amount) }
            }

            class Enemy {
                let name: String
                var hp: Int

                init(name: String, hp: Int) {
                    self.name = name
                    self.hp = hp
                }

                func takeDamage(_ amount: Int) { hp = max(0, hp - amount) }
            }

            class Party {
                var members: [Hero]

                init(members: [Hero]) {
                    self.members = members
                }

                var totalDamage: Int {
                    return members.filter { $0.isAlive() }.reduce(0) { $0 + $1.attack }
                }

                func allAttack(target: Enemy) {
                    for hero in members where hero.isAlive() {
                        print("\\(hero.name) 공격! (\\(hero.attack) 데미지)")
                        target.takeDamage(hero.attack)
                    }
                }

                func anyAlive() -> Bool {
                    return members.contains { $0.isAlive() }
                }
            }

            let party = Party(members: [
                Hero(name: "아서", hp: 100, attack: 20),
                Hero(name: "멀린", hp: 60, attack: 30),
                Hero(name: "란슬롯", hp: 80, attack: 25)
            ])

            let dragon = Enemy(name: "드래곤", hp: 200)

            print("파티 총 공격력: \\(party.totalDamage)")
            party.allAttack(target: dragon)
            print("드래곤 남은 HP: \\(dragon.hp)")
            """,
            expectedOutput: """
            파티 총 공격력: 75
            아서 공격! (20 데미지)
            멀린 공격! (30 데미지)
            란슬롯 공격! (25 데미지)
            드래곤 남은 HP: 125
            """,
            xpReward: 45,
            order: 2
        )
        try await lesson6_2.save(on: database)

        // Lesson 6-3: 최종 보스전
        let lesson6_3 = Lesson(
            id: UUID(uuidString: "44444444-4444-4444-4444-444444300603"),
            chapterId: chapter6.id!,
            title: "최종 보스전",
            content: """
            # 🏆 PixelQuest 최종 전투

            모든 것을 합쳐 최종 보스전을 구현합니다!

            ---

            ## 🎯 최종 미션

            `bossBattle` 함수를 완성하세요:
            1. 파티가 보스 공격
            2. 보스 분노 체크
            3. 보스가 랜덤 영웅 공격
            4. 승패 판정

            게임 개발자로서의 첫 걸음을 완성하세요! 🎮
            """,
            type: .codeExercise,
            language: .swift,
            starterCode: """
            class Hero {
                let name: String
                var hp: Int
                let attack: Int
                init(name: String, hp: Int, attack: Int) {
                    self.name = name; self.hp = hp; self.attack = attack
                }
                func isAlive() -> Bool { hp > 0 }
                func takeDamage(_ amount: Int) { hp = max(0, hp - amount) }
            }

            class DragonKing {
                let name = "드래곤 킹"
                var hp: Int = 150
                var isEnraged = false
                var attack: Int { isEnraged ? 30 : 20 }

                func takeDamage(_ amount: Int) { hp = max(0, hp - amount) }
                func isAlive() -> Bool { hp > 0 }
                func checkEnrage() {
                    if hp <= 75 && !isEnraged {
                        isEnraged = true
                        print("🔥 드래곤 킹이 분노했다!")
                    }
                }
            }

            class Party {
                var members: [Hero]
                init(members: [Hero]) { self.members = members }
                var aliveMembers: [Hero] { members.filter { $0.isAlive() } }
                var totalDamage: Int { aliveMembers.reduce(0) { $0 + $1.attack } }
                func anyAlive() -> Bool { !aliveMembers.isEmpty }
            }

            func bossBattle(party: Party, boss: DragonKing) {
                var turn = 1

                while party.anyAlive() && boss.isAlive() {
                    print("\\n=== 턴 \\(turn) ===")

                    // 1. 파티 공격
                    let partyDamage = party.totalDamage
                    print("파티 공격! (\\(partyDamage) 데미지)")
                    boss.takeDamage(partyDamage)
                    print("드래곤 킹 HP: \\(boss.hp)")

                    if !boss.isAlive() { break }

                    // 2. 분노 체크
                    boss.checkEnrage()

                    // 3. 보스가 첫 번째 살아있는 영웅 공격
                    // ...

                    turn += 1
                    if turn > 10 { break }  // 안전장치
                }

                // 4. 승패 판정
                if boss.isAlive() {
                    print("\\n💀 파티 전멸...")
                } else {
                    print("\\n🏆 승리! 드래곤 킹을 처치했습니다!")
                }
            }

            let party = Party(members: [
                Hero(name: "아서", hp: 80, attack: 25),
                Hero(name: "멀린", hp: 50, attack: 35)
            ])
            let boss = DragonKing()

            bossBattle(party: party, boss: boss)
            """,
            solutionCode: """
            class Hero {
                let name: String
                var hp: Int
                let attack: Int
                init(name: String, hp: Int, attack: Int) {
                    self.name = name; self.hp = hp; self.attack = attack
                }
                func isAlive() -> Bool { hp > 0 }
                func takeDamage(_ amount: Int) { hp = max(0, hp - amount) }
            }

            class DragonKing {
                let name = "드래곤 킹"
                var hp: Int = 150
                var isEnraged = false
                var attack: Int { isEnraged ? 30 : 20 }

                func takeDamage(_ amount: Int) { hp = max(0, hp - amount) }
                func isAlive() -> Bool { hp > 0 }
                func checkEnrage() {
                    if hp <= 75 && !isEnraged {
                        isEnraged = true
                        print("🔥 드래곤 킹이 분노했다!")
                    }
                }
            }

            class Party {
                var members: [Hero]
                init(members: [Hero]) { self.members = members }
                var aliveMembers: [Hero] { members.filter { $0.isAlive() } }
                var totalDamage: Int { aliveMembers.reduce(0) { $0 + $1.attack } }
                func anyAlive() -> Bool { !aliveMembers.isEmpty }
            }

            func bossBattle(party: Party, boss: DragonKing) {
                var turn = 1

                while party.anyAlive() && boss.isAlive() {
                    print("\\n=== 턴 \\(turn) ===")

                    let partyDamage = party.totalDamage
                    print("파티 공격! (\\(partyDamage) 데미지)")
                    boss.takeDamage(partyDamage)
                    print("드래곤 킹 HP: \\(boss.hp)")

                    if !boss.isAlive() { break }

                    boss.checkEnrage()

                    if let target = party.aliveMembers.first {
                        print("드래곤 킹 -> \\(target.name) (\\(boss.attack) 데미지)")
                        target.takeDamage(boss.attack)
                        print("\\(target.name) HP: \\(target.hp)")
                    }

                    turn += 1
                    if turn > 10 { break }
                }

                if boss.isAlive() {
                    print("\\n💀 파티 전멸...")
                } else {
                    print("\\n🏆 승리! 드래곤 킹을 처치했습니다!")
                }
            }

            let party = Party(members: [
                Hero(name: "아서", hp: 80, attack: 25),
                Hero(name: "멀린", hp: 50, attack: 35)
            ])
            let boss = DragonKing()

            bossBattle(party: party, boss: boss)
            """,
            expectedOutput: """

            === 턴 1 ===
            파티 공격! (60 데미지)
            드래곤 킹 HP: 90
            드래곤 킹 -> 아서 (20 데미지)
            아서 HP: 60

            === 턴 2 ===
            파티 공격! (60 데미지)
            드래곤 킹 HP: 30
            🔥 드래곤 킹이 분노했다!
            드래곤 킹 -> 아서 (30 데미지)
            아서 HP: 30

            === 턴 3 ===
            파티 공격! (60 데미지)
            드래곤 킹 HP: 0

            🏆 승리! 드래곤 킹을 처치했습니다!
            """,
            xpReward: 70,
            order: 3
        )
        try await lesson6_3.save(on: database)
    }

    func revert(on database: Database) async throws {
        let courseId = UUID(uuidString: "22222222-2222-2222-2222-222222222230")!

        let chapters = try await Chapter.query(on: database)
            .filter(\.$course.$id == courseId)
            .all()

        for chapter in chapters {
            try await Lesson.query(on: database)
                .filter(\.$chapter.$id == chapter.id!)
                .delete()
        }

        try await Chapter.query(on: database)
            .filter(\.$course.$id == courseId)
            .delete()

        try await Course.query(on: database)
            .filter(\.$id == courseId)
            .delete()
    }
}
