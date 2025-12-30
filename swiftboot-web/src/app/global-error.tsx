"use client";

interface GlobalErrorProps {
  error: Error & { digest?: string };
  reset: () => void;
}

export default function GlobalError({ error, reset }: GlobalErrorProps) {
  return (
    <html lang="ko" className="dark">
      <body className="min-h-screen bg-[#1E1E1E] flex items-center justify-center p-4">
        <div className="text-center max-w-md">
          <div className="w-20 h-20 mx-auto mb-6 bg-red-500/10 rounded-full flex items-center justify-center">
            <svg
              className="w-10 h-10 text-red-500"
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

          <h1 className="text-2xl font-bold text-white mb-2">
            심각한 오류가 발생했습니다
          </h1>
          <p className="text-gray-400 mb-6">
            애플리케이션에 문제가 발생했습니다.
            <br />
            페이지를 새로고침하거나 잠시 후 다시 시도해주세요.
          </p>

          <div className="flex gap-3 justify-center">
            <button
              onClick={() => window.location.href = "/"}
              className="px-4 py-2 bg-gray-700 text-white rounded-lg hover:bg-gray-600 transition-colors"
            >
              홈으로
            </button>
            <button
              onClick={reset}
              className="px-4 py-2 bg-blue-500 text-white rounded-lg hover:bg-blue-600 transition-colors"
            >
              다시 시도
            </button>
          </div>

          {process.env.NODE_ENV === "development" && error?.message && (
            <div className="mt-6 p-4 bg-gray-800 rounded-lg text-left">
              <p className="text-xs font-mono text-red-400 break-all">
                {error.message}
              </p>
            </div>
          )}
        </div>
      </body>
    </html>
  );
}
