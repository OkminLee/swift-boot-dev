import Link from "next/link";

export default function HomePage() {
  return (
    <div className="min-h-screen flex flex-col">
      {/* Header */}
      <header className="border-b border-[var(--border-default)] bg-[var(--bg-secondary)]">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="flex justify-between items-center h-16">
            <div className="flex items-center gap-2">
              <span className="text-2xl">🚀</span>
              <span className="font-bold text-xl text-[var(--text-primary)]">
                SwiftBoot
              </span>
            </div>
            <nav className="flex items-center gap-4">
              <Link
                href="/login"
                className="text-[var(--text-secondary)] hover:text-[var(--text-primary)] transition-colors"
              >
                로그인
              </Link>
              <Link
                href="/login"
                className="px-4 py-2 bg-[var(--accent-primary)] text-white rounded-lg hover:opacity-90 transition-opacity"
              >
                시작하기
              </Link>
            </nav>
          </div>
        </div>
      </header>

      {/* Hero Section */}
      <main className="flex-1 flex items-center justify-center">
        <div className="max-w-4xl mx-auto px-4 text-center">
          <h1 className="text-5xl font-bold mb-6 text-[var(--text-primary)]">
            코딩을{" "}
            <span className="text-transparent bg-clip-text bg-gradient-to-r from-[var(--level-gradient-start)] to-[var(--level-gradient-end)]">
              게임처럼
            </span>{" "}
            배우세요
          </h1>
          <p className="text-xl text-[var(--text-secondary)] mb-8 max-w-2xl mx-auto">
            XP를 쌓고, 레벨업하고, 상자를 열어보세요. SwiftBoot와 함께라면 코딩
            학습이 즐거워집니다.
          </p>

          {/* Features */}
          <div className="grid grid-cols-1 md:grid-cols-3 gap-6 mt-12">
            <div className="p-6 bg-[var(--bg-secondary)] rounded-xl border border-[var(--border-default)]">
              <div className="text-3xl mb-4">⚡</div>
              <h3 className="font-semibold text-[var(--text-primary)] mb-2">
                실시간 코드 실행
              </h3>
              <p className="text-sm text-[var(--text-secondary)]">
                브라우저에서 바로 코드를 작성하고 실행 결과를 확인하세요
              </p>
            </div>
            <div className="p-6 bg-[var(--bg-secondary)] rounded-xl border border-[var(--border-default)]">
              <div className="text-3xl mb-4">🏆</div>
              <h3 className="font-semibold text-[var(--text-primary)] mb-2">
                게이미피케이션
              </h3>
              <p className="text-sm text-[var(--text-secondary)]">
                XP, 레벨, Gems, 업적으로 학습 동기를 유지하세요
              </p>
            </div>
            <div className="p-6 bg-[var(--bg-secondary)] rounded-xl border border-[var(--border-default)]">
              <div className="text-3xl mb-4">🦅</div>
              <h3 className="font-semibold text-[var(--text-primary)] mb-2">
                Swift 특화
              </h3>
              <p className="text-sm text-[var(--text-secondary)]">
                Vapor로 구축된 실제 서비스로 Swift 백엔드를 체험하세요
              </p>
            </div>
          </div>

          {/* CTA */}
          <div className="mt-12">
            <Link
              href="/login"
              className="inline-flex items-center gap-2 px-8 py-4 bg-[var(--accent-primary)] text-white font-semibold rounded-xl hover:opacity-90 transition-opacity text-lg"
            >
              무료로 시작하기
              <svg
                className="w-5 h-5"
                fill="none"
                stroke="currentColor"
                viewBox="0 0 24 24"
              >
                <path
                  strokeLinecap="round"
                  strokeLinejoin="round"
                  strokeWidth={2}
                  d="M13 7l5 5m0 0l-5 5m5-5H6"
                />
              </svg>
            </Link>
          </div>
        </div>
      </main>

      {/* Footer */}
      <footer className="border-t border-[var(--border-default)] bg-[var(--bg-secondary)] py-8">
        <div className="max-w-7xl mx-auto px-4 text-center text-[var(--text-muted)]">
          <p>© 2024 SwiftBoot. Built with Vapor + Next.js</p>
        </div>
      </footer>
    </div>
  );
}
