"use client";

import { useEffect } from "react";

interface ErrorPageProps {
  error: Error & { digest?: string };
  reset: () => void;
}

export default function ErrorPage({ error, reset }: ErrorPageProps) {
  useEffect(() => {
    // 에러 로깅 (추후 Sentry 등 연동 가능)
    console.error("Page error:", error);
  }, [error]);

  return (
    <div className="min-h-screen bg-[var(--bg-primary)] flex items-center justify-center p-4">
      <div className="text-center max-w-md">
        <div className="w-20 h-20 mx-auto mb-6 bg-[var(--error-red)]/10 rounded-full flex items-center justify-center">
          <svg
            className="w-10 h-10 text-[var(--error-red)]"
            fill="none"
            stroke="currentColor"
            viewBox="0 0 24 24"
          >
            <path
              strokeLinecap="round"
              strokeLinejoin="round"
              strokeWidth={2}
              d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z"
            />
          </svg>
        </div>

        <h1 className="text-2xl font-bold text-[var(--text-primary)] mb-2">
          오류가 발생했습니다
        </h1>
        <p className="text-[var(--text-secondary)] mb-6">
          페이지를 불러오는 중 문제가 발생했습니다.
          <br />
          잠시 후 다시 시도해주세요.
        </p>

        {process.env.NODE_ENV === "development" && error.message && (
          <div className="mb-6 p-4 bg-[var(--bg-secondary)] rounded-lg text-left">
            <p className="text-xs font-mono text-[var(--error-red)] break-all">
              {error.message}
            </p>
            {error.digest && (
              <p className="text-xs font-mono text-[var(--text-muted)] mt-2">
                Digest: {error.digest}
              </p>
            )}
          </div>
        )}

        <div className="flex gap-3 justify-center">
          <button
            onClick={() => window.location.href = "/"}
            className="px-4 py-2 bg-[var(--bg-tertiary)] text-[var(--text-primary)] rounded-lg hover:bg-[var(--bg-hover)] transition-colors"
          >
            홈으로
          </button>
          <button
            onClick={reset}
            className="px-4 py-2 bg-[var(--accent-primary)] text-white rounded-lg hover:bg-[var(--accent-primary-hover)] transition-colors"
          >
            다시 시도
          </button>
        </div>
      </div>
    </div>
  );
}
