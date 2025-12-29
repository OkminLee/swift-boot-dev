import Link from "next/link";

export default function LoginPage() {
  return (
    <div className="min-h-screen flex items-center justify-center bg-[var(--bg-primary)]">
      <div className="max-w-md w-full mx-4">
        {/* Logo */}
        <div className="text-center mb-8">
          <Link href="/" className="inline-flex items-center gap-2">
            <span className="text-4xl">🚀</span>
            <span className="font-bold text-2xl text-[var(--text-primary)]">
              SwiftBoot
            </span>
          </Link>
          <p className="mt-4 text-[var(--text-secondary)]">
            게임처럼 코딩을 배워보세요
          </p>
        </div>

        {/* Login Card */}
        <div className="bg-[var(--bg-secondary)] rounded-2xl border border-[var(--border-default)] p-8">
          <h1 className="text-2xl font-bold text-[var(--text-primary)] text-center mb-6">
            로그인
          </h1>

          {/* GitHub OAuth Button */}
          <button
            className="w-full flex items-center justify-center gap-3 px-6 py-4 bg-[#24292e] text-white rounded-xl hover:bg-[#2f363d] transition-colors font-medium"
            onClick={() => {
              // TODO: GitHub OAuth 연동
              console.log("GitHub OAuth");
            }}
          >
            <svg className="w-6 h-6" fill="currentColor" viewBox="0 0 24 24">
              <path
                fillRule="evenodd"
                d="M12 2C6.477 2 2 6.484 2 12.017c0 4.425 2.865 8.18 6.839 9.504.5.092.682-.217.682-.483 0-.237-.008-.868-.013-1.703-2.782.605-3.369-1.343-3.369-1.343-.454-1.158-1.11-1.466-1.11-1.466-.908-.62.069-.608.069-.608 1.003.07 1.531 1.032 1.531 1.032.892 1.53 2.341 1.088 2.91.832.092-.647.35-1.088.636-1.338-2.22-.253-4.555-1.113-4.555-4.951 0-1.093.39-1.988 1.029-2.688-.103-.253-.446-1.272.098-2.65 0 0 .84-.27 2.75 1.026A9.564 9.564 0 0112 6.844c.85.004 1.705.115 2.504.337 1.909-1.296 2.747-1.027 2.747-1.027.546 1.379.202 2.398.1 2.651.64.7 1.028 1.595 1.028 2.688 0 3.848-2.339 4.695-4.566 4.943.359.309.678.92.678 1.855 0 1.338-.012 2.419-.012 2.747 0 .268.18.58.688.482A10.019 10.019 0 0022 12.017C22 6.484 17.522 2 12 2z"
                clipRule="evenodd"
              />
            </svg>
            GitHub으로 계속하기
          </button>

          <div className="mt-6 text-center text-sm text-[var(--text-muted)]">
            <p>
              계속 진행하면{" "}
              <Link href="/terms" className="text-[var(--accent-primary)] hover:underline">
                이용약관
              </Link>{" "}
              및{" "}
              <Link href="/privacy" className="text-[var(--accent-primary)] hover:underline">
                개인정보처리방침
              </Link>
              에 동의하는 것으로 간주됩니다.
            </p>
          </div>
        </div>

        {/* Back to Home */}
        <div className="mt-6 text-center">
          <Link
            href="/"
            className="text-[var(--text-secondary)] hover:text-[var(--text-primary)] transition-colors"
          >
            ← 홈으로 돌아가기
          </Link>
        </div>
      </div>
    </div>
  );
}
