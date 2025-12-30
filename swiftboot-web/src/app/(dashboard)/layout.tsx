"use client";

import Link from "next/link";
import Image from "next/image";
import { useRouter } from "next/navigation";
import { useEffect } from "react";
import { useAuth } from "@/stores/auth-store";
import { useSoundStore } from "@/stores/sound-store";
import { playSuccess } from "@/lib/sounds";

export default function DashboardLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  const router = useRouter();
  const { user, stats, isAuthenticated, isLoading, isInitialized, logout } = useAuth();
  const soundEnabled = useSoundStore((state) => state.soundEnabled);
  const toggleSound = useSoundStore((state) => state.toggleSound);
  const initializeSound = useSoundStore((state) => state.initialize);

  // 사운드 설정 초기화
  useEffect(() => {
    initializeSound();
  }, [initializeSound]);

  // 초기화 완료 후, 인증되지 않은 경우 로그인 페이지로 리다이렉트
  useEffect(() => {
    if (isInitialized && !isAuthenticated) {
      router.replace("/login");
    }
  }, [isAuthenticated, isInitialized, router]);

  // 사운드 토글 핸들러
  const handleToggleSound = () => {
    toggleSound();
    // 사운드 켜질 때 피드백 소리 재생
    if (!soundEnabled) {
      setTimeout(() => playSuccess(), 50);
    }
  };

  const handleLogout = async () => {
    await logout();
    router.replace("/");
  };

  // 초기화 중 또는 로딩 중
  if (!isInitialized || isLoading) {
    return (
      <div className="min-h-screen flex items-center justify-center bg-[var(--bg-primary)]">
        <div className="animate-spin w-8 h-8 border-4 border-[var(--accent-primary)] border-t-transparent rounded-full" />
      </div>
    );
  }

  // 인증 안됨
  if (!isAuthenticated) {
    return null;
  }

  const xpProgress = stats ? stats.levelProgress * 100 : 0;
  const xpToNextLevel = stats?.xpToNextLevel ?? 100;

  return (
    <div className="min-h-screen flex">
      {/* Sidebar */}
      <aside className="w-64 bg-[var(--bg-secondary)] border-r border-[var(--border-default)] flex flex-col">
        {/* Logo */}
        <div className="h-16 flex items-center px-4 border-b border-[var(--border-default)]">
          <Link href="/courses" className="flex items-center gap-2">
            <span className="text-2xl">🚀</span>
            <span className="font-bold text-lg text-[var(--text-primary)]">
              SwiftBoot
            </span>
          </Link>
        </div>

        {/* Navigation */}
        <nav className="flex-1 p-4 space-y-2">
          <Link
            href="/courses"
            className="flex items-center gap-3 px-3 py-2 text-[var(--text-primary)] bg-[var(--bg-hover)] rounded-lg"
          >
            <span>📚</span>
            <span>코스</span>
          </Link>
          <Link
            href="/shop"
            className="flex items-center gap-3 px-3 py-2 text-[var(--text-secondary)] hover:text-[var(--text-primary)] hover:bg-[var(--bg-hover)] rounded-lg transition-colors"
          >
            <span>🏪</span>
            <span>상점</span>
          </Link>
          <Link
            href="/inventory"
            className="flex items-center gap-3 px-3 py-2 text-[var(--text-secondary)] hover:text-[var(--text-primary)] hover:bg-[var(--bg-hover)] rounded-lg transition-colors"
          >
            <span>🎒</span>
            <span>인벤토리</span>
          </Link>
          <Link
            href="/profile"
            className="flex items-center gap-3 px-3 py-2 text-[var(--text-secondary)] hover:text-[var(--text-primary)] hover:bg-[var(--bg-hover)] rounded-lg transition-colors"
          >
            <span>👤</span>
            <span>프로필</span>
          </Link>

          {/* 사운드 토글 */}
          <button
            onClick={handleToggleSound}
            className="flex items-center justify-between w-full px-3 py-2 text-[var(--text-secondary)] hover:text-[var(--text-primary)] hover:bg-[var(--bg-hover)] rounded-lg transition-colors"
            title={soundEnabled ? "사운드 끄기" : "사운드 켜기"}
          >
            <div className="flex items-center gap-3">
              <span>{soundEnabled ? "🔊" : "🔇"}</span>
              <span>사운드</span>
            </div>
            <div
              className={`w-8 h-5 rounded-full transition-colors flex items-center px-0.5 ${
                soundEnabled ? "bg-[var(--accent-primary)]" : "bg-[var(--bg-tertiary)]"
              }`}
            >
              <div
                className={`w-4 h-4 rounded-full bg-white shadow transition-transform ${
                  soundEnabled ? "translate-x-3" : "translate-x-0"
                }`}
              />
            </div>
          </button>
        </nav>

        {/* User Stats */}
        <div className="p-4 border-t border-[var(--border-default)]">
          <div className="bg-[var(--bg-elevated)] rounded-xl p-4 space-y-3">
            {/* User Info */}
            <div className="flex items-center gap-3 pb-3 border-b border-[var(--border-default)]">
              {user?.avatarUrl ? (
                <Image
                  src={user.avatarUrl}
                  alt={user.username || "User avatar"}
                  width={40}
                  height={40}
                  className="rounded-full"
                  priority={false}
                />
              ) : (
                <div className="w-10 h-10 rounded-full bg-[var(--accent-primary)] flex items-center justify-center text-white font-bold">
                  {user?.username?.charAt(0).toUpperCase()}
                </div>
              )}
              <div className="flex-1 min-w-0">
                <p className="font-medium text-[var(--text-primary)] truncate">
                  {user?.username}
                </p>
                <p className="text-xs text-[var(--text-muted)]">Lv. {user?.level}</p>
              </div>
            </div>

            {/* XP Bar */}
            <div>
              <div className="flex justify-between text-xs text-[var(--text-muted)] mb-1">
                <span>다음 레벨까지</span>
                <span>{xpToNextLevel} XP</span>
              </div>
              <div className="h-2 bg-[var(--bg-primary)] rounded-full overflow-hidden">
                <div
                  className="h-full bg-[var(--xp-gold)] transition-all"
                  style={{ width: `${Math.min(xpProgress, 100)}%` }}
                />
              </div>
            </div>

            {/* Completed Lessons */}
            {stats && (
              <div className="flex items-center justify-between text-xs">
                <span className="text-[var(--text-muted)]">완료한 레슨</span>
                <span className="text-[var(--accent-success)]">
                  {stats.completedLessons}/{stats.totalLessons}
                </span>
              </div>
            )}

            {/* Streak & Gems */}
            <div className="flex justify-between text-sm">
              <div className="flex items-center gap-1">
                <span>🔥</span>
                <span className="text-[var(--streak-orange)]">{user?.streakDays || 0}일</span>
              </div>
              <Link
                href="/shop"
                className="flex items-center gap-1 hover:opacity-80 transition-opacity"
              >
                <span>💎</span>
                <span className="text-[var(--gem-purple)]">{user?.gems || 0}</span>
              </Link>
            </div>

            {/* Logout */}
            <button
              onClick={handleLogout}
              className="w-full mt-2 px-3 py-2 text-sm text-[var(--text-secondary)] hover:text-[var(--error-red)] hover:bg-[var(--bg-hover)] rounded-lg transition-colors text-left"
            >
              로그아웃
            </button>
          </div>
        </div>
      </aside>

      {/* Main Content */}
      <main className="flex-1 bg-[var(--bg-primary)]">{children}</main>
    </div>
  );
}
