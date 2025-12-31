# SwiftBoot 배포 가이드

> Option A: Cloudflare Pages + Fly.io + Supabase + Upstash 구성

**예상 비용**: $5-25/월 (초기 트래픽 기준)

---

## 아키텍처 개요

```
┌─────────────────────────────────────────────────────────────┐
│                    Production Architecture                   │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  [Cloudflare DNS]                                           │
│       │                                                     │
│       ├──→ swiftboot.dev ──→ [Cloudflare Pages]            │
│       │                       └── Next.js Frontend          │
│       │                                                     │
│       └──→ api.swiftboot.dev ──→ [Fly.io]                  │
│                                   └── Vapor Backend         │
│                                         │                   │
│                                         ├──→ [Supabase]     │
│                                         │     PostgreSQL    │
│                                         │                   │
│                                         └──→ [Upstash]      │
│                                               Redis         │
│                                                             │
│  [Fly.io Machines] ←── RCE Workers (Docker)                │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

---

## 목차

1. [사전 준비](#1-사전-준비)
2. [Supabase 설정](#2-supabase-설정)
3. [Upstash Redis 설정](#3-upstash-redis-설정)
4. [GitHub OAuth 앱 생성](#4-github-oauth-앱-생성)
5. [Fly.io 백엔드 배포](#5-flyio-백엔드-배포)
6. [Cloudflare Pages 배포](#6-cloudflare-pages-배포)
7. [도메인 설정](#7-도메인-설정)
8. [CI/CD 설정](#8-cicd-설정)
9. [모니터링 설정](#9-모니터링-설정)
10. [트러블슈팅](#10-트러블슈팅)

---

## 1. 사전 준비

### 필수 계정
- [GitHub](https://github.com) - 소스 코드 및 CI/CD
- [Supabase](https://supabase.com) - PostgreSQL 데이터베이스
- [Upstash](https://upstash.com) - Redis
- [Fly.io](https://fly.io) - Vapor 백엔드 호스팅
- [Cloudflare](https://cloudflare.com) - DNS 및 프론트엔드 호스팅

### 필수 CLI 도구
```bash
# Fly.io CLI
brew install flyctl

# Cloudflare Wrangler (optional)
npm install -g wrangler
```

### GitHub 저장소 준비
```bash
# 저장소 생성 및 푸시
cd /Users/okminlee/Work/swift-boot-dev
git remote add origin https://github.com/YOUR_USERNAME/swiftboot.git
git push -u origin main
```

---

## 2. Supabase 설정

### 2.1 프로젝트 생성

1. [Supabase Dashboard](https://supabase.com/dashboard) 접속
2. "New Project" 클릭
3. 프로젝트 정보 입력:
   - **Name**: `swiftboot`
   - **Database Password**: 강력한 비밀번호 생성 (저장해둘 것!)
   - **Region**: `Northeast Asia (Tokyo)` 또는 가까운 리전
4. "Create new project" 클릭

### 2.2 연결 정보 확인

Project Settings → Database에서 확인:

```
Host: db.xxxxxxxxxxxx.supabase.co
Port: 5432 (또는 6543 for connection pooling)
Database: postgres
User: postgres
Password: [생성 시 입력한 비밀번호]
```

### 2.3 Connection String

```
# Direct connection (마이그레이션용)
postgresql://postgres:[PASSWORD]@db.xxxx.supabase.co:5432/postgres

# Pooled connection (앱 연결용 - 권장)
postgresql://postgres.[PROJECT_REF]:[PASSWORD]@aws-0-ap-northeast-1.pooler.supabase.com:6543/postgres
```

### 2.4 주의사항

- **Free Tier 제한**: 500MB 스토리지, 2GB 대역폭/월
- **Connection Pooling**: 프로덕션에서는 포트 6543 사용 권장
- **SSL**: 기본 활성화됨 (Vapor configure.swift의 `tls: .prefer` 설정과 호환)

---

## 3. Upstash Redis 설정

### 3.1 데이터베이스 생성

1. [Upstash Console](https://console.upstash.com) 접속
2. "Create Database" 클릭
3. 설정:
   - **Name**: `swiftboot-redis`
   - **Type**: `Regional`
   - **Region**: `ap-northeast-1` (Tokyo)
   - **TLS**: Enabled (기본값)
4. "Create" 클릭

### 3.2 연결 정보 확인

```
UPSTASH_REDIS_REST_URL=https://xxxx.upstash.io
UPSTASH_REDIS_REST_TOKEN=xxxxx

# 또는 Redis URL 형식
redis://default:xxxxx@xxxx.upstash.io:6379
```

### 3.3 Vapor에서 TLS 연결

Upstash는 TLS를 사용하므로, `configure.swift` 수정 필요:

```swift
// MARK: - Redis (Upstash TLS 지원)
if let redisURL = Environment.get("REDIS_URL") {
    // Upstash URL 형식: rediss://default:xxx@xxx.upstash.io:6379
    app.redis.configuration = try RedisConfiguration(url: redisURL)
} else {
    app.redis.configuration = try RedisConfiguration(
        hostname: Environment.get("REDIS_HOST") ?? "localhost",
        port: Environment.get("REDIS_PORT").flatMap(Int.init) ?? 6379
    )
}
```

### 3.4 주의사항

- **Free Tier 제한**: 10,000 commands/day, 256MB 스토리지
- **TLS 필수**: `rediss://` 프로토콜 사용 (s 추가)

---

## 4. GitHub OAuth 앱 생성

### 4.1 OAuth App 생성

1. [GitHub Developer Settings](https://github.com/settings/developers) 접속
2. "OAuth Apps" → "New OAuth App"
3. 설정:
   - **Application name**: `SwiftBoot`
   - **Homepage URL**: `https://swiftboot.dev`
   - **Authorization callback URL**: `https://api.swiftboot.dev/api/v1/auth/github/callback`
4. "Register application" 클릭

### 4.2 Client ID & Secret 저장

```
GITHUB_CLIENT_ID=Iv1.xxxxxxxxxxxx
GITHUB_CLIENT_SECRET=xxxxxxxxxxxxxxxxxxxxxxxxxxxx
```

---

## 5. Fly.io 백엔드 배포

### 5.1 Fly.io 로그인

```bash
flyctl auth login
```

### 5.2 앱 생성

```bash
cd SwiftBootServer
flyctl launch --no-deploy
```

설정:
- **App name**: `swiftboot-api`
- **Region**: `nrt` (Tokyo)
- **Database**: No (Supabase 사용)
- **Redis**: No (Upstash 사용)

### 5.3 Dockerfile 확인

`SwiftBootServer/Dockerfile`:

```dockerfile
# Build stage
FROM swift:6.0-jammy AS builder
WORKDIR /app
COPY Package.* ./
RUN swift package resolve
COPY . .
RUN swift build -c release --static-swift-stdlib

# Run stage
FROM ubuntu:22.04
RUN apt-get update && apt-get install -y \
    libcurl4 \
    libxml2 \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY --from=builder /app/.build/release/App ./

# Docker socket for RCE (if needed)
# Note: This requires special Fly.io configuration

ENV ENVIRONMENT=production
EXPOSE 8080
ENTRYPOINT ["./App"]
CMD ["serve", "--env", "production", "--hostname", "0.0.0.0", "--port", "8080"]
```

### 5.4 fly.toml 설정

`SwiftBootServer/fly.toml`:

```toml
app = "swiftboot-api"
primary_region = "nrt"

[build]

[env]
  ENVIRONMENT = "production"

[http_service]
  internal_port = 8080
  force_https = true
  auto_stop_machines = true
  auto_start_machines = true
  min_machines_running = 1

[[vm]]
  memory = "512mb"
  cpu_kind = "shared"
  cpus = 1
```

### 5.5 Secrets 설정

```bash
cd SwiftBootServer

# Database (Supabase)
flyctl secrets set DATABASE_HOST=db.xxxx.supabase.co
flyctl secrets set DATABASE_PORT=5432
flyctl secrets set DATABASE_USERNAME=postgres
flyctl secrets set DATABASE_PASSWORD=your-supabase-password
flyctl secrets set DATABASE_NAME=postgres

# Redis (Upstash)
flyctl secrets set REDIS_URL=rediss://default:xxxx@xxxx.upstash.io:6379

# JWT
flyctl secrets set JWT_SECRET=$(openssl rand -hex 32)

# GitHub OAuth
flyctl secrets set GITHUB_CLIENT_ID=Iv1.xxxxxxxxxxxx
flyctl secrets set GITHUB_CLIENT_SECRET=xxxxxxxxxxxx

# URLs
flyctl secrets set APP_URL=https://api.swiftboot.dev
flyctl secrets set FRONTEND_URL=https://swiftboot.dev
```

### 5.6 배포

```bash
flyctl deploy
```

### 5.7 상태 확인

```bash
flyctl status
flyctl logs
```

### 5.8 마이그레이션 실행

Vapor는 시작 시 자동으로 마이그레이션을 실행합니다. 수동 실행이 필요한 경우:

```bash
flyctl ssh console -C "/app/App migrate --yes"
```

---

## 6. Cloudflare Pages 배포

### 6.1 프로젝트 연결

1. [Cloudflare Dashboard](https://dash.cloudflare.com) 접속
2. "Workers & Pages" → "Create application" → "Pages"
3. "Connect to Git" → GitHub 계정 연결
4. 저장소 선택: `swiftboot`

### 6.2 빌드 설정

```
Framework preset: Next.js
Build command: npm run build
Build output directory: .next
Root directory: swiftboot-web
```

### 6.3 환경 변수 설정

Production 환경 변수:

```
NEXT_PUBLIC_API_URL=https://api.swiftboot.dev/api/v1
NEXT_PUBLIC_GITHUB_CLIENT_ID=Iv1.xxxxxxxxxxxx
```

### 6.4 Node.js 버전 설정

```
NODE_VERSION=20
```

### 6.5 배포

"Save and Deploy" 클릭

### 6.6 커스텀 도메인 연결

1. Pages 프로젝트 → "Custom domains"
2. "Set up a custom domain"
3. `swiftboot.dev` 입력
4. DNS 레코드 자동 추가됨

---

## 7. 도메인 설정

### 7.1 Cloudflare DNS 설정

도메인을 Cloudflare로 이전하거나 네임서버 변경 후:

```
# Frontend (Cloudflare Pages가 자동으로 추가)
swiftboot.dev → CNAME → [pages-project].pages.dev

# Backend API
api.swiftboot.dev → CNAME → swiftboot-api.fly.dev
```

### 7.2 Fly.io 커스텀 도메인

```bash
flyctl certs create api.swiftboot.dev
```

### 7.3 SSL 인증서

- **Cloudflare Pages**: 자동 발급
- **Fly.io**: 자동 발급 (Let's Encrypt)

---

## 8. CI/CD 설정

### 8.1 GitHub Actions 워크플로우

`.github/workflows/deploy.yml`:

```yaml
name: Deploy

on:
  push:
    branches: [main]

jobs:
  # Backend 배포
  deploy-backend:
    runs-on: ubuntu-latest
    defaults:
      run:
        working-directory: SwiftBootServer
    steps:
      - uses: actions/checkout@v4

      - name: Setup Fly.io
        uses: superfly/flyctl-actions/setup-flyctl@master

      - name: Deploy to Fly.io
        run: flyctl deploy --remote-only
        env:
          FLY_API_TOKEN: ${{ secrets.FLY_API_TOKEN }}

  # Frontend 배포 (Cloudflare Pages는 자동 배포)
  # 수동 트리거가 필요한 경우에만 사용
  deploy-frontend:
    runs-on: ubuntu-latest
    defaults:
      run:
        working-directory: swiftboot-web
    steps:
      - uses: actions/checkout@v4

      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: '20'
          cache: 'npm'
          cache-dependency-path: swiftboot-web/package-lock.json

      - name: Install dependencies
        run: npm ci

      - name: Build
        run: npm run build
        env:
          NEXT_PUBLIC_API_URL: https://api.swiftboot.dev/api/v1

      - name: Deploy to Cloudflare Pages
        uses: cloudflare/wrangler-action@v3
        with:
          apiToken: ${{ secrets.CLOUDFLARE_API_TOKEN }}
          accountId: ${{ secrets.CLOUDFLARE_ACCOUNT_ID }}
          command: pages deploy .next --project-name=swiftboot
          workingDirectory: swiftboot-web
```

### 8.2 GitHub Secrets 설정

Repository Settings → Secrets and variables → Actions:

```
FLY_API_TOKEN=fo1_xxxxxxxxxxxx
CLOUDFLARE_API_TOKEN=xxxxxxxxxxxx
CLOUDFLARE_ACCOUNT_ID=xxxxxxxxxxxx
```

### 8.3 Fly.io API 토큰 생성

```bash
flyctl tokens create deploy -x 999999h
```

---

## 9. 모니터링 설정

### 9.1 Fly.io 메트릭

```bash
# 실시간 로그
flyctl logs -a swiftboot-api

# 메트릭 대시보드
flyctl dashboard -a swiftboot-api
```

### 9.2 Supabase 모니터링

- Dashboard → Database → Database health
- Realtime 로그 확인

### 9.3 Upstash 모니터링

- Console → Database → Metrics
- 일일 명령어 사용량 확인

### 9.4 Sentry 에러 트래킹 (선택)

```bash
# Frontend
npm install @sentry/nextjs

# 환경 변수
NEXT_PUBLIC_SENTRY_DSN=https://xxx@xxx.ingest.sentry.io/xxx
```

---

## 10. 트러블슈팅

### 10.1 데이터베이스 연결 실패

```bash
# Fly.io에서 직접 테스트
flyctl ssh console

# PostgreSQL 연결 테스트
apt-get update && apt-get install -y postgresql-client
psql "postgresql://postgres:xxx@db.xxx.supabase.co:5432/postgres"
```

### 10.2 Redis 연결 실패

```bash
# TLS 연결 확인 (rediss:// 사용)
flyctl ssh console
apt-get install -y redis-tools
redis-cli -u "rediss://default:xxx@xxx.upstash.io:6379" ping
```

### 10.3 CORS 에러

`configure.swift`에서 프론트엔드 도메인 확인:

```swift
let corsConfiguration = CORSMiddleware.Configuration(
    allowedOrigin: .custom("https://swiftboot.dev"),
    // 또는 개발 중에는
    allowedOrigin: .all,
    ...
)
```

### 10.4 빌드 실패

```bash
# 로컬에서 Docker 빌드 테스트
cd SwiftBootServer
docker build -t swiftboot-api .
docker run -p 8080:8080 swiftboot-api
```

### 10.5 마이그레이션 실패

```bash
# 마이그레이션 상태 확인
flyctl ssh console -C "/app/App migrate --dry-run"

# 강제 실행 (주의!)
flyctl ssh console -C "/app/App migrate --yes"
```

---

## 체크리스트

### 배포 전

- [ ] Supabase 프로젝트 생성 완료
- [ ] Upstash Redis 생성 완료
- [ ] GitHub OAuth App 생성 완료
- [ ] 모든 Secrets 설정 완료
- [ ] 로컬에서 프로덕션 환경 테스트

### 배포 후

- [ ] API 헬스체크: `curl https://api.swiftboot.dev/health`
- [ ] 프론트엔드 접속 확인: `https://swiftboot.dev`
- [ ] GitHub 로그인 테스트
- [ ] 코드 실행 테스트
- [ ] 모니터링 대시보드 확인

---

## 비용 요약

| 서비스 | 무료 티어 | 예상 초과 비용 |
|--------|----------|--------------|
| Cloudflare Pages | 무제한 요청 | $0 |
| Fly.io (Backend) | $5 크레딧/월 | $5-15/월 |
| Supabase | 500MB, 2GB 대역폭 | $25/월 (Pro) |
| Upstash Redis | 10K cmd/day | $0.2/10K cmd |

**총 예상 비용**: $5-25/월 (초기), $50-75/월 (성장기)

---

## 다음 단계

1. [ ] RCE Worker 분리 배포 (트래픽 증가 시)
2. [ ] CDN 설정 (이미지/에셋)
3. [ ] 백업 자동화
4. [ ] 로드 테스트
5. [ ] 알림 설정 (Slack/Discord)

---

*최종 업데이트: 2025-12-30*
