# SwiftBoot 구현 플랜

> Boot.dev를 벤치마킹한 Swift 기반 게이미피케이션 코딩 교육 플랫폼

**문서 버전:** 1.4
**최종 수정일:** 2025-12-30
**배포 형태:** 웹 애플리케이션

---

## 📊 진행 상황 요약

| Phase | 설명 | 상태 | 진행률 |
|-------|------|------|--------|
| **Phase 0** | 디자인 시스템 | 🟡 진행중 | 70% |
| **Phase 1A** | 백엔드 MVP | 🟢 거의완료 | 98% |
| **Phase 1B** | RCE 엔진 | ✅ 완료 | 100% |
| **Phase 1C** | 웹 클라이언트 MVP | 🟢 거의완료 | 90% |
| **Phase 2A** | 게이미피케이션 | ⬜ 대기 | 0% |
| **Phase 2B** | 콘텐츠 & 폴리싱 | ⬜ 대기 | 0% |
| **Phase 2C** | 배포 | ⬜ 대기 | 0% |

### 완료된 주요 작업

- ✅ 디자인 토큰 정의 (colors, typography, spacing, animation)
- ✅ Tailwind CSS 프리셋 및 CSS 변수
- ✅ Vapor 프로젝트 구조 및 의존성 설정
- ✅ Fluent 모델 (User, Track, Course, Chapter, Lesson, UserProgress, RefreshToken)
- ✅ 기본 컨트롤러 (Auth, User, Track, Course, Lesson)
- ✅ Docker Compose (PostgreSQL, Redis)
- ✅ Next.js 15 프로젝트 초기화
- ✅ 랜딩 페이지, 로그인 페이지, 대시보드 레이아웃
- ✅ **GitHub OAuth 전체 구현** (백엔드 + 프론트엔드)
- ✅ **JWT 인증 시스템** (Access Token + Refresh Token)
- ✅ **Monaco Editor 통합** (커스텀 테마 포함)
- ✅ **코스 상세 페이지** (챕터/레슨 아코디언)
- ✅ **레슨 학습 화면** (Split View: 콘텐츠 + 에디터)
- ✅ **코드 제출 UI** (실행 결과 표시)
- ✅ **Seed 콘텐츠** (샘플 코스/챕터/레슨 데이터)
- ✅ **RCE 엔진 MVP** (Docker 기반 Swift 코드 실행)
  - DockerRunner: 보안 격리 컨테이너 실행 (--network none, --memory 128m)
  - CodeExecutionService: 코드 실행, 결과 평가, XP 지급
  - 정답/오답/타임아웃/컴파일에러 처리
- ✅ **사용자 진행률 시스템** (백엔드 + 프론트엔드)
  - 코스별 진행률 API (GET /users/me/progress/courses)
  - 코스 상세 페이지: 레슨별 완료 체크마크, 챕터/코스 진행률 바
  - 코스 목록 페이지: 진행률 바, 완료 뱃지
  - 사이드바: 완료 레슨 수, XP 진행률 표시

### 다음 우선순위 작업

1. 🔜 추가 언어 지원 (Python, Go, JavaScript Docker 이미지)
2. 🔜 Rate Limiting 미들웨어
3. 🔜 게이미피케이션 UI (레벨업 효과, Confetti)
4. 🔜 Zustand 전역 상태 관리

---

## 목차

1. [프로젝트 개요](#1-프로젝트-개요)
2. [기술 스택](#2-기술-스택)
3. [디자인 방향](#3-디자인-방향)
4. [구현 로드맵](#4-구현-로드맵)
5. [Phase별 상세 작업](#5-phase별-상세-작업)
6. [인프라 및 배포](#6-인프라-및-배포)
7. [리스크 및 대응 방안](#7-리스크-및-대응-방안)

---

## 1. 프로젝트 개요

### 1.1 비전

SwiftBoot는 Boot.dev의 성공적인 게이미피케이션 학습 모델을 벤치마킹하여, 서버 사이드 Swift(Vapor)로 백엔드를 구축한 코딩 교육 플랫폼입니다.

### 1.2 핵심 목표

- **게이미피케이션 학습**: XP, 레벨, Gems, Chest 등 RPG 요소로 학습 동기 부여
- **실시간 코드 실행**: 브라우저에서 코드 작성 → 서버에서 안전하게 실행 → 즉시 결과 반환
- **Swift 생태계 쇼케이스**: Vapor로 구축된 실제 서비스로 Swift 백엔드의 가능성 증명

### 1.3 타겟 사용자

| 페르소나 | 설명 | 니즈 |
|----------|------|------|
| **Swift Convert** | iOS 개발자, 백엔드 입문 희망 | 익숙한 Swift로 서버 개발 학습 |
| **Gamified Learner** | 전통적 강의 지루해하는 학습자 | 즉각적 피드백과 성취감 |

### 1.4 핵심 기능

- 구조화된 학습 로드맵 (Track → Course → Chapter → Lesson)
- 웹 기반 코드 에디터 (Monaco Editor)
- 다중 언어 원격 코드 실행 (Swift, Python, Go, JavaScript)
- 게이미피케이션 시스템 (XP, 레벨, Gems, Chest, 업적)
- GitHub OAuth 인증
- 실시간 학습 진행 동기화

---

## 2. 기술 스택

### 2.1 아키텍처 개요

```
┌─────────────────────────────────────────────────────────────┐
│                    SwiftBoot 웹 아키텍처                     │
├─────────────────────────────────────────────────────────────┤
│  Frontend (Web)                                             │
│  ├── Next.js 14 (App Router)                               │
│  ├── TypeScript                                            │
│  ├── Monaco Editor                                         │
│  ├── Tailwind CSS                                          │
│  ├── Framer Motion                                         │
│  └── TanStack Query                                        │
├─────────────────────────────────────────────────────────────┤
│  Backend (Swift)                                            │
│  ├── Vapor 4                                               │
│  ├── Fluent ORM                                            │
│  ├── PostgreSQL                                            │
│  ├── Redis (Queue, Cache)                                  │
│  └── WebSocket                                             │
├─────────────────────────────────────────────────────────────┤
│  RCE (Remote Code Execution)                               │
│  ├── Docker 컨테이너                                        │
│  ├── Redis Job Queue                                       │
│  └── Execution Worker                                      │
└─────────────────────────────────────────────────────────────┘
```

### 2.2 Frontend 기술 스택

| 기술 | 버전 | 용도 |
|------|------|------|
| Next.js | 14.x | React 프레임워크, SSR/SSG |
| TypeScript | 5.x | 타입 안전성 |
| Monaco Editor | latest | 코드 에디터 (VS Code 엔진) |
| Tailwind CSS | 3.x | 스타일링 |
| Framer Motion | 10.x | 애니메이션 |
| TanStack Query | 5.x | 서버 상태 관리 |
| next-auth | 5.x | 인증 |
| socket.io-client | 4.x | WebSocket 클라이언트 |

### 2.3 Backend 기술 스택

| 기술 | 버전 | 용도 |
|------|------|------|
| Swift | 5.9+ | 언어 |
| Vapor | 4.x | 웹 프레임워크 |
| Fluent | 4.x | ORM |
| PostgreSQL | 15+ | 데이터베이스 |
| Redis | 7.x | 캐시, Job Queue |
| Queues | 1.x | 비동기 작업 처리 |
| JWT | - | 인증 토큰 |

### 2.4 RCE 기술 스택

| 기술 | 용도 |
|------|------|
| Docker | 코드 실행 격리 |
| swiftlang/swift | Swift 런타임 이미지 |
| python:3.11-slim | Python 런타임 이미지 |
| node:20-slim | JavaScript 런타임 이미지 |
| golang:1.21-alpine | Go 런타임 이미지 |

---

## 3. 디자인 방향

### 3.1 디자인 철학: "Magical IDE"

> Xcode/VS Code 스타일의 프로페셔널한 IDE + 게이미피케이션 오버레이

**결정 근거:**
- 타겟 사용자(iOS 개발자)가 Xcode에 익숙
- Boot.dev도 실제로는 Monaco Editor(현대적 IDE) 사용
- "게이미피케이션 ≠ 8비트 비주얼" - 보상 시스템은 어떤 UI 위에도 적용 가능
- Apple HIG 준수로 신뢰감 확보

### 3.2 디자인 토큰

```css
:root {
  /* 배경색 */
  --bg-primary: #1E1E1E;      /* 메인 배경 */
  --bg-secondary: #252526;    /* 사이드바 */
  --bg-editor: #1E1E1E;       /* 에디터 배경 */
  --bg-terminal: #0D1117;     /* 터미널/콘솔 */

  /* 텍스트 */
  --text-primary: #D4D4D4;
  --text-secondary: #808080;
  --text-accent: #007AFF;

  /* 악센트 */
  --accent-primary: #007AFF;  /* 시스템 블루 */
  --accent-success: #34C759;  /* 성공 */
  --accent-error: #FF3B30;    /* 에러 */
  --accent-warning: #FF9500;  /* 경고 */

  /* 게이미피케이션 */
  --xp-gold: #FFD700;
  --gem-purple: #AF52DE;
  --streak-orange: #FF6B35;
  --level-gradient: linear-gradient(135deg, #667eea 0%, #764ba2 100%);

  /* 폰트 */
  --font-mono: 'JetBrains Mono', 'SF Mono', 'Fira Code', monospace;
  --font-sans: 'Inter', -apple-system, BlinkMacSystemFont, sans-serif;
}
```

### 3.3 핵심 컴포넌트

| 컴포넌트 | 설명 |
|----------|------|
| **CodeEditor** | Monaco Editor 기반, 커스텀 테마, 구문 강조 |
| **LessonPanel** | 학습 콘텐츠 렌더링 (MDX), 힌트/스포일러 |
| **XPBar** | 경험치 프로그레스 바, 레벨 표시 |
| **ResultPanel** | 코드 실행 결과, 테스트 통과/실패 |
| **ChestModal** | 상자 개봉 애니메이션 |
| **AchievementToast** | 업적 달성 알림 |

### 3.4 게이미피케이션 피드백 (웹 버전)

| 이벤트 | 시각적 피드백 | 청각적 피드백 |
|--------|--------------|--------------|
| 정답 | Confetti 파티클 | 성공 효과음 |
| 오답 | 화면 흔들림, 빨간 글로우 | 실패 효과음 |
| 레벨업 | 골든 오버레이, 파티클 | 팡파레 |
| Chest 개봉 | 3D 회전 애니메이션 | 보물 효과음 |
| Streak | 불꽃 아이콘 펄스 | 콤보 효과음 |

---

## 4. 구현 로드맵

### 4.1 전체 일정 (18주)

```
Phase 0: 디자인 시스템          [Week 1-2]    ████
Phase 1A: 백엔드 MVP            [Week 3-4]    ████
Phase 1B: RCE 엔진              [Week 5-7]    ██████
Phase 1C: 웹 클라이언트 MVP     [Week 8-11]   ████████
Phase 2A: 게이미피케이션        [Week 12-14]  ██████
Phase 2B: 콘텐츠 & 폴리싱       [Week 15-16]  ████
Phase 2C: 배포                  [Week 17-18]  ████
```

### 4.2 마일스톤

| 마일스톤 | 완료 시점 | 검증 기준 |
|----------|----------|----------|
| M1: 디자인 완료 | Week 2 | Figma 프로토타입 승인 |
| M2: API 완성 | Week 4 | 인증 + CRUD API 동작 |
| M3: RCE 동작 | Week 7 | 4개 언어 코드 실행 성공 |
| M4: MVP 완성 | Week 11 | 로그인 → 레슨 → 코드 실행 플로우 |
| M5: 게임화 완성 | Week 14 | XP/레벨/Chest 시스템 동작 |
| M6: 런칭 | Week 18 | 프로덕션 배포 완료 |

---

## 5. Phase별 상세 작업

### Phase 0: 디자인 시스템 (Week 1-2)

#### Week 1: 디자인 토큰 & 컴포넌트 설계

- [ ] Figma 프로젝트 생성
- [x] 색상 팔레트 정의 *(design-system/tokens/colors.json)*
- [x] 타이포그래피 스케일 정의 *(design-system/tokens/typography.json)*
- [x] 스페이싱/그리드 시스템 (8px 기반) *(design-system/tokens/spacing.json)*
- [x] 아이콘 세트 선정 (Lucide Icons)

#### Week 2: UI 컴포넌트 디자인

- [ ] CodeEditor 컴포넌트
- [ ] LessonCard 컴포넌트
- [ ] XPBar / LevelBadge
- [ ] ChestModal (개봉 애니메이션 스펙)
- [ ] 전체 화면 플로우 프로토타입
- [x] 반응형 브레이크포인트 정의 *(design-system/tokens/spacing.json)*

**산출물:**
- [ ] Figma 컴포넌트 라이브러리
- [x] 디자인 토큰 JSON *(design-system/tokens/)*
- [ ] 인터랙션 스펙 문서

---

### Phase 1A: 백엔드 MVP (Week 3-4)

#### Week 3: 프로젝트 세팅

- [x] Vapor 프로젝트 초기화 *(SwiftBootServer/Package.swift)*
- [x] Docker Compose 설정 (PostgreSQL, Redis) *(SwiftBootServer/docker-compose.yml)*
- [x] Fluent 마이그레이션 설정 *(SwiftBootServer/Sources/App/Migrations/)*
- [x] 기본 디렉토리 구조 *(SwiftBootServer/Sources/App/)*

```
SwiftBootServer/
├── Sources/
│   └── App/
│       ├── Controllers/
│       ├── Models/
│       ├── Migrations/
│       ├── DTOs/
│       ├── Middleware/
│       └── configure.swift
├── Tests/
├── Package.swift
└── docker-compose.yml
```

- [x] 데이터베이스 스키마 설계 *(SwiftBootServer/Sources/App/Models/)*

```sql
-- 핵심 테이블 (구현 완료)
users (id, username, email, github_id, total_xp, level, gems, created_at) ✓
tracks (id, title, description, order) ✓
courses (id, track_id, title, description, order, prerequisite_id) ✓
chapters (id, course_id, title, order) ✓
lessons (id, chapter_id, title, content, difficulty, xp_reward, order) ✓
user_progress (user_id, lesson_id, status, submitted_code, completed_at) ✓
inventory (id, user_id, item_type, quantity)
achievements (id, user_id, achievement_type, unlocked_at)
```

#### Week 4: 인증 시스템

- [x] GitHub OAuth 2.0 연동 *(SwiftBootServer/Sources/App/Controllers/AuthController.swift)*
- [x] JWT Access Token (15분) *(DTOs/AuthDTOs.swift - AccessTokenPayload)*
- [x] JWT Refresh Token (7일) *(Models/RefreshToken.swift, Migrations/CreateRefreshToken.swift)*
- [x] 토큰 갱신 엔드포인트 *(POST /auth/refresh)*
- [ ] Rate Limiting 미들웨어
- [x] CORS 설정 *(SwiftBootServer/Sources/App/configure.swift)*
- [x] JWTAuthMiddleware *(SwiftBootServer/Sources/App/Middleware/JWTAuthMiddleware.swift)*
- [x] UserController *(GET /users/me, GET /users/me/stats)*
- [x] CourseController 확장 *(챕터/레슨 포함 상세 조회)*
- [x] SeedContent 마이그레이션 *(샘플 데이터 자동 생성)*

**API 엔드포인트:**
```
POST   /auth/github/callback
POST   /auth/refresh
POST   /auth/logout
GET    /users/me
PATCH  /users/me
```

**산출물:**
- Vapor 서버 (Docker로 실행 가능)
- API 문서 (Swagger/OpenAPI)

---

### Phase 1B: RCE 엔진 (Week 5-7) ✅ 완료

#### Week 5-6: 코드 실행 파이프라인

- [x] Docker 컨테이너 관리 로직 *(Services/DockerRunner.swift)*
- [x] 코드 실행 서비스 *(Services/CodeExecutionService.swift)*
- [x] 언어 설정 *(Services/LanguageConfig.swift)*

**구현된 아키텍처:**
```
LessonController.submitLesson
    ↓
CodeExecutionService.execute
    ↓
DockerRunner.execute (Process API → docker run)
    ↓
결과 평가 (expectedOutput 비교) → XP 지급
```

- [x] 언어별 Docker 이미지 준비
  - [x] Swift (swiftlang/swift:nightly-6.0-jammy)
  - [ ] Python (python:3.12-slim) - 설정 완료, pull 필요
  - [ ] Go (golang:1.22-alpine) - 설정 완료, pull 필요
  - [ ] JavaScript (node:20-alpine) - 설정 완료, pull 필요

- [x] 보안 설정
  - [x] 네트워크 격리 (--network none)
  - [x] 리소스 제한 (128MB 메모리, 5초 타임아웃)
  - [x] 읽기 전용 파일시스템 (--read-only, HOME=/tmp)
  - [x] 비특권 사용자 (--user nobody)
  - [x] 프로세스 제한 (--pids-limit 50)

- [ ] WebSocket 결과 스트리밍 (Phase 2에서 필요시 구현)

#### Week 7: 테스트 검증 시스템

- [x] stdout 매칭 검증 *(CodeExecutionService.evaluateResult)*
- [x] 에러 메시지 포맷팅 (컴파일 에러 표시)
- [x] 타임아웃 처리

**API 엔드포인트:**
```
POST   /api/v1/lessons/:lessonId/submit   (코드 실행 요청) ✅
```

**산출물:**
- RCE Worker 서비스
- 4개 언어 지원 확인

---

### Phase 1C: 웹 클라이언트 MVP (Week 8-11)

#### Week 8-9: Next.js 프로젝트 세팅

- [x] Next.js 15 프로젝트 생성 (App Router) *(swiftboot-web/)*
- [x] TypeScript 설정 *(swiftboot-web/tsconfig.json)*
- [x] Tailwind CSS + 커스텀 테마 *(swiftboot-web/src/app/globals.css)*
- [x] 디렉토리 구조 *(swiftboot-web/src/app/)*

```
swiftboot-web/
├── app/
│   ├── (auth)/
│   │   ├── login/
│   │   └── callback/
│   ├── (dashboard)/
│   │   ├── courses/
│   │   └── profile/
│   ├── learn/
│   │   └── [lessonId]/
│   ├── layout.tsx
│   └── page.tsx
├── components/
│   ├── ui/
│   ├── editor/
│   └── gamification/
├── lib/
│   ├── api/
│   ├── hooks/
│   └── utils/
├── styles/
└── public/
```

- [x] 인증 시스템 (자체 구현) *(swiftboot-web/src/lib/auth-context.tsx, github-oauth.ts)*
- [x] API 클라이언트 *(swiftboot-web/src/lib/api.ts)*
- [ ] 전역 상태 관리 (Zustand) - AuthContext로 대체 중

#### Week 10: Monaco Editor 통합

- [x] @monaco-editor/react 설치 *(package.json)*
- [x] 커스텀 테마 (swiftboot-dark) *(swiftboot-web/src/lib/monaco-theme.ts)*
- [x] 언어별 구문 강조 설정 *(languageDefaults 구현)*
- [x] 에디터 옵션 최적화 *(CodeEditor.tsx)*

```typescript
const editorOptions: monaco.editor.IStandaloneEditorConstructionOptions = {
  theme: 'swiftboot-dark',
  fontFamily: 'JetBrains Mono, SF Mono, monospace',
  fontSize: 14,
  lineNumbers: 'on',
  minimap: { enabled: false },
  scrollBeyondLastLine: false,
  automaticLayout: true,
  tabSize: 4,
  wordWrap: 'on',
};
```

- [ ] WebSocket 연결 (코드 실행) - RCE 완료 후 구현 예정
- [x] 실시간 결과 출력 패널 *(OutputViewer 컴포넌트)*

#### Week 11: 학습 플로우 UI

- [x] 대시보드 (코스 목록) *(swiftboot-web/src/app/(dashboard)/courses/page.tsx)*
- [x] 코스 상세 (챕터/레슨 목록) *(swiftboot-web/src/app/(dashboard)/courses/[courseId]/page.tsx)*
- [x] 레슨 화면 (Split View) *(swiftboot-web/src/app/learn/[lessonId]/page.tsx)*
  - [x] 좌측: 학습 콘텐츠 (ReactMarkdown + remark-gfm)
  - [x] 우측: 코드 에디터 + 결과 패널
- [x] 진행률 표시 *(UserProgress API 연동, 코스/레슨 완료 상태 UI)*
- [x] 반응형 레이아웃 (lg:grid-cols-2)

**산출물:**
- Next.js 웹 클라이언트
- 로그인 → 코스 선택 → 레슨 학습 → 코드 실행 플로우 완성

---

### Phase 2A: 게이미피케이션 (Week 12-14)

#### Week 12: XP/레벨 시스템 UI

- [x] XP 프로그레스 바 컴포넌트 *(사이드바에 구현)*
- [x] 레벨 뱃지 컴포넌트 *(사이드바에 구현)*
- [ ] 레벨업 모달 (애니메이션)
- [x] Streak 표시 (연속 학습) *(사이드바에 구현)*
- [x] 사이드바 프로필 위젯 *(대시보드 레이아웃에 구현)*

**레벨링 공식:**
```
XP_required = 100 × (Level)^1.5

Level 1→2:  100 XP
Level 5→6:  ~1,118 XP
Level 10→11: ~3,162 XP
```

#### Week 13: 보상 시스템

- [ ] Gems 표시 UI
- [ ] 상점 페이지
  - [ ] Seer Stone (정답 보기)
  - [ ] XP Potion (경험치 부스터)
  - [ ] 코스메틱 아이템
- [ ] Chest 개봉 모달
  - [ ] 등급별 애니메이션 (Common, Rare, Legendary)
  - [ ] canvas-confetti 통합
- [ ] 인벤토리 페이지

#### Week 14: 피드백 시스템

- [ ] 정답 피드백
  - [ ] Confetti 효과 (canvas-confetti)
  - [ ] 성공 사운드
  - [ ] XP 획득 애니메이션
- [ ] 오답 피드백
  - [ ] 화면 흔들림 (Framer Motion)
  - [ ] 실패 사운드
- [ ] 레벨업 피드백
  - [ ] 전체 화면 골든 오버레이
  - [ ] 팡파레 사운드
- [ ] 사운드 on/off 설정

**산출물:**
- 완전한 게이미피케이션 시스템
- 사운드 에셋

---

### Phase 2B: 콘텐츠 & 폴리싱 (Week 15-16)

#### Week 15: LMS 콘텐츠

- [ ] MDX 렌더링 설정
- [ ] 커스텀 컴포넌트
  - [ ] CodeBlock (복사 버튼)
  - [ ] Hint (접기/펼치기)
  - [ ] Warning/Info 박스
- [ ] 초기 코스 콘텐츠 작성
  - [ ] "Swift 기초" 코스 (10개 레슨)
  - [ ] 테스트 케이스 작성

#### Week 16: 최적화 & 테스트

- [ ] Lighthouse 성능 최적화
  - [ ] 이미지 최적화
  - [ ] 코드 스플리팅
  - [ ] 폰트 최적화
- [ ] E2E 테스트 (Playwright)
- [ ] 접근성 검수 (axe-core)
- [ ] 브라우저 호환성 테스트
  - [ ] Chrome, Firefox, Safari, Edge
- [ ] 에러 바운더리 설정

**산출물:**
- 초기 학습 콘텐츠
- 테스트 커버리지 80%+

---

### Phase 2C: 배포 (Week 17-18)

#### Week 17: 인프라 구축

- [ ] 도메인 설정 (swiftboot.dev)
- [ ] Frontend 배포
  - [ ] Vercel 또는 Cloudflare Pages
  - [ ] 환경 변수 설정
- [ ] Backend 배포
  - [ ] Fly.io 또는 AWS ECS
  - [ ] Docker 이미지 빌드
- [ ] Database
  - [ ] Neon (Serverless PostgreSQL) 또는 AWS RDS
- [ ] Redis
  - [ ] Upstash 또는 AWS ElastiCache
- [ ] CI/CD 파이프라인 (GitHub Actions)

```yaml
# .github/workflows/deploy.yml
name: Deploy
on:
  push:
    branches: [main]
jobs:
  deploy-frontend:
    # Vercel 자동 배포
  deploy-backend:
    # Docker 빌드 → Fly.io 배포
```

#### Week 18: 런칭

- [ ] SSL 인증서 확인
- [ ] 모니터링 설정
  - [ ] Sentry (에러 트래킹)
  - [ ] Prometheus + Grafana (메트릭)
- [ ] Analytics
  - [ ] Plausible 또는 PostHog
- [ ] 베타 테스터 모집
- [ ] 피드백 수집 채널 설정

**산출물:**
- 프로덕션 URL: https://swiftboot.dev
- 모니터링 대시보드

---

## 6. 인프라 및 배포

### 6.1 인프라 구성

```
┌─────────────────────────────────────────────────────────────┐
│                      Production Environment                  │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  [Cloudflare]                                               │
│       │                                                     │
│       ├──→ [Vercel] ──→ Next.js Frontend                   │
│       │                                                     │
│       └──→ [Fly.io] ──→ Vapor Backend                      │
│                 │                                           │
│                 ├──→ [Neon] PostgreSQL                     │
│                 ├──→ [Upstash] Redis                       │
│                 └──→ [Docker] RCE Workers                  │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### 6.2 예상 비용 (월간)

| 서비스 | 티어 | 예상 비용 |
|--------|------|----------|
| Vercel | Pro | $20 |
| Fly.io | Pay-as-you-go | $20-50 |
| Neon | Launch | $19 |
| Upstash | Pay-as-you-go | $10 |
| Cloudflare | Free | $0 |
| **합계** | | **~$70-100/월** |

### 6.3 스케일링 전략

- **Frontend**: Vercel Edge Network로 자동 스케일링
- **Backend**: Fly.io auto-scaling (CPU/메모리 기반)
- **RCE Workers**: 트래픽에 따라 워커 수 조절
- **Database**: Neon autoscaling 또는 read replica

---

## 7. 리스크 및 대응 방안

### 7.1 기술적 리스크

| 리스크 | 영향 | 대응 방안 |
|--------|------|----------|
| RCE 보안 취약점 | 높음 | Docker 격리, 네트워크 차단, 리소스 제한 철저 |
| Monaco Editor 성능 | 중간 | 대용량 파일 제한, 가상화 적용 |
| WebSocket 연결 불안정 | 중간 | 재연결 로직, 폴링 폴백 |
| Vapor 생태계 한계 | 낮음 | 커뮤니티 활용, 필요시 직접 구현 |

### 7.2 일정 리스크

| 리스크 | 대응 방안 |
|--------|----------|
| RCE 구현 지연 | Phase 1C와 병렬 진행 가능 |
| 디자인 변경 요청 | Phase 0에서 충분한 리뷰 |
| 콘텐츠 제작 지연 | MVP는 최소 1개 코스로 런칭 |

### 7.3 비즈니스 리스크

| 리스크 | 대응 방안 |
|--------|----------|
| 사용자 유입 부족 | SEO 최적화, 콘텐츠 마케팅 |
| Boot.dev와 차별화 부족 | Swift 특화, 한국어 콘텐츠 |

---

## 부록

### A. 참고 자료

- [Boot.dev](https://boot.dev) - 벤치마킹 대상
- [Vapor Documentation](https://docs.vapor.codes)
- [Monaco Editor](https://microsoft.github.io/monaco-editor/)
- [Next.js Documentation](https://nextjs.org/docs)

### B. 용어 정의

| 용어 | 정의 |
|------|------|
| RCE | Remote Code Execution, 원격 코드 실행 |
| LMS | Learning Management System, 학습 관리 시스템 |
| XP | Experience Points, 경험치 |
| Gems | 인앱 가상 화폐 |
| Chest | 랜덤 보상 상자 |

### C. 변경 이력

| 버전 | 날짜 | 변경 내용 |
|------|------|----------|
| 1.0 | 2025-12-29 | 최초 작성 (웹 배포 기준) |
| 1.2 | 2025-12-30 | 진행상황 대규모 업데이트: GitHub OAuth 완료, JWT 인증 완료, Monaco Editor 통합 완료, 코스/레슨 UI 완료 |
| 1.3 | 2025-12-30 | Phase 1B RCE 엔진 완료: Docker 기반 Swift 코드 실행, 보안 격리, 결과 평가 |
| 1.4 | 2025-12-30 | 사용자 진행률 시스템 완료: 코스별 진행률 API, 레슨 완료 UI, 사이드바 통계 |

---

*이 문서는 프로젝트 진행에 따라 지속적으로 업데이트됩니다.*
