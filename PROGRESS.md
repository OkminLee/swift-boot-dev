# SwiftBoot 구현 진행 상황

## 개요
SwiftBoot은 게이미피케이션 기반 코딩 교육 플랫폼입니다.

## 구현 현황

### Phase 1: 기초 인프라 ✅
- [x] 프로젝트 초기 설정
- [x] 디자인 시스템 토큰 정의
- [x] Vapor 백엔드 초기화
- [x] Next.js 프론트엔드 초기화

### Phase 2: 인증 시스템 ✅
- [x] GitHub OAuth 백엔드 구현
  - AuthController (callback, refresh, logout)
  - RefreshToken 모델 및 마이그레이션
  - JWT 미들웨어
- [x] GitHub OAuth 프론트엔드 구현
  - API 클라이언트 (토큰 자동 갱신)
  - AuthContext Provider
  - OAuth 콜백 페이지
  - 보호된 대시보드 레이아웃

### Phase 3: 학습 콘텐츠 시스템 ✅
- [x] 데이터 모델 (Track, Course, Chapter, Lesson)
- [x] 샘플 콘텐츠 시드 데이터
  - Swift Developer 트랙
  - Swift 기초, Swift 제어문 코스
  - 11개 레슨 (175 XP)
- [x] 학습 API 엔드포인트
  - GET /tracks, /tracks/:id
  - GET /courses, /courses/:id
  - GET /lessons/:id
  - POST /lessons/:id/submit

### Phase 4: 학습 UI ✅
- [x] Monaco Editor 통합
  - 커스텀 SwiftBoot 테마
  - 언어별 설정 (Swift, Python, Go, JS)
  - CodeEditor, OutputViewer 컴포넌트
- [x] Course 목록 페이지 (/courses)
- [x] Course 상세 페이지 (/courses/:id)
- [x] Lesson 학습 페이지 (/learn/:id)
  - 읽기 레슨 (Markdown)
  - 코드 연습 레슨 (Monaco Editor)

### Phase 5: 코드 실행 엔진 🔲
- [ ] Docker 기반 코드 샌드박스
- [ ] Redis Job Queue
- [ ] 실행 결과 스트리밍 (WebSocket)
- [ ] 언어별 런타임 컨테이너

### Phase 6: 게이미피케이션 🔲
- [ ] XP 시스템 구현
- [ ] 레벨업 로직
- [ ] 스트릭 추적
- [ ] 업적 시스템
- [ ] 리더보드

### Phase 7: 고급 기능 🔲
- [ ] 사용자 프로필 페이지
- [ ] 학습 진도 추적
- [ ] 오프라인 지원
- [ ] 푸시 알림

---

## 기술 스택

| 영역 | 기술 |
|------|------|
| Backend | Vapor 4, Swift 6, Fluent ORM |
| Database | PostgreSQL, Redis |
| Frontend | Next.js 16, React 19, TypeScript |
| Code Editor | Monaco Editor |
| Auth | JWT + GitHub OAuth |
| Styling | Tailwind CSS v4 |

## 로컬 개발 환경

```bash
# 백엔드
cd SwiftBootServer
docker-compose up -d  # PostgreSQL, Redis
swift run

# 프론트엔드
cd swiftboot-web
npm install
npm run dev
```

## 최근 변경 (2024-12-30)
- GitHub OAuth 인증 시스템 완성
- Monaco Editor 커스텀 테마 적용
- Course 목록/상세 페이지 구현
- Lesson 학습 페이지 구현
