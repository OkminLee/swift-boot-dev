# ================================
# Build stage
# ================================
FROM swift:6.0-jammy AS builder

WORKDIR /build

# 의존성 캐싱을 위해 먼저 Package 파일만 복사
COPY Package.swift Package.resolved ./

# 의존성 다운로드
RUN swift package resolve

# 소스 코드 복사
COPY Sources ./Sources
COPY Tests ./Tests

# Release 빌드 (정적 링크)
RUN swift build -c release \
    --static-swift-stdlib \
    -Xlinker -u -Xlinker _swift_stdlib_reportFatalErrorInFile

# ================================
# Run stage
# ================================
FROM ubuntu:22.04

# 런타임 의존성 설치
RUN apt-get update && apt-get install -y \
    libcurl4 \
    libxml2 \
    ca-certificates \
    tzdata \
    && rm -rf /var/lib/apt/lists/*

# 타임존 설정
ENV TZ=Asia/Seoul
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# 비루트 사용자 생성
RUN useradd --user-group --create-home --system --skel /dev/null --home-dir /app vapor

WORKDIR /app

# 빌드된 바이너리 복사
COPY --from=builder --chown=vapor:vapor /build/.build/release/App ./

# 비루트 사용자로 전환
USER vapor:vapor

# 환경 변수
ENV ENVIRONMENT=production

# 포트 노출
EXPOSE 8080

# 앱 실행
ENTRYPOINT ["./App"]
CMD ["serve", "--env", "production", "--hostname", "0.0.0.0", "--port", "8080"]
