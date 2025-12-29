"use client";

import { Suspense } from "react";
import { useEffect, useState } from "react";
import { useRouter, useSearchParams } from "next/navigation";
import { useAuth } from "@/lib/auth-context";
import { validateState } from "@/lib/github-oauth";

function CallbackContent() {
  const router = useRouter();
  const searchParams = useSearchParams();
  const { login } = useAuth();
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    const handleCallback = async () => {
      const code = searchParams.get("code");
      const state = searchParams.get("state");
      const errorParam = searchParams.get("error");

      // GitHub에서 에러 반환
      if (errorParam) {
        setError("GitHub 로그인이 취소되었습니다.");
        return;
      }

      // code 또는 state 없음
      if (!code || !state) {
        setError("잘못된 요청입니다.");
        return;
      }

      // CSRF 검증
      if (!validateState(state)) {
        setError("보안 검증에 실패했습니다. 다시 시도해주세요.");
        return;
      }

      try {
        await login(code);
        router.replace("/courses");
      } catch (err) {
        console.error("Login failed:", err);
        setError("로그인에 실패했습니다. 다시 시도해주세요.");
      }
    };

    handleCallback();
  }, [searchParams, login, router]);

  if (error) {
    return (
      <div className="min-h-screen flex items-center justify-center bg-[var(--bg-primary)]">
        <div className="text-center">
          <div className="text-6xl mb-4">😢</div>
          <h1 className="text-xl font-bold text-[var(--text-primary)] mb-2">
            로그인 실패
          </h1>
          <p className="text-[var(--text-secondary)] mb-6">{error}</p>
          <button
            onClick={() => router.push("/login")}
            className="px-6 py-3 bg-[var(--accent-primary)] text-white rounded-lg hover:opacity-90 transition-opacity"
          >
            다시 시도하기
          </button>
        </div>
      </div>
    );
  }

  return (
    <div className="min-h-screen flex items-center justify-center bg-[var(--bg-primary)]">
      <div className="text-center">
        <div className="animate-spin w-12 h-12 border-4 border-[var(--accent-primary)] border-t-transparent rounded-full mx-auto mb-4" />
        <p className="text-[var(--text-secondary)]">로그인 중...</p>
      </div>
    </div>
  );
}

function LoadingFallback() {
  return (
    <div className="min-h-screen flex items-center justify-center bg-[var(--bg-primary)]">
      <div className="text-center">
        <div className="animate-spin w-12 h-12 border-4 border-[var(--accent-primary)] border-t-transparent rounded-full mx-auto mb-4" />
        <p className="text-[var(--text-secondary)]">로딩 중...</p>
      </div>
    </div>
  );
}

export default function AuthCallbackPage() {
  return (
    <Suspense fallback={<LoadingFallback />}>
      <CallbackContent />
    </Suspense>
  );
}
