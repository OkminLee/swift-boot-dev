"use client";

import Link from "next/link";
import { useRouter } from "next/navigation";
import { useEffect } from "react";
import { useAuth } from "@/lib/auth-context";

export default function DashboardLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  const router = useRouter();
  const { user, isAuthenticated, isLoading, logout } = useAuth();

  // 인증되지 않은 경우 로그인 페이지로 리다이렉트
  useEffect(() => {
    if (!isLoading && !isAuthenticated) {
      router.replace("/login");
    }
  }, [isAuthenticated, isLoading, router]);

  const handleLogout = async () => {
    await logout();
    router.replace("/");
  };

  // 로딩 중
  if (isLoading) {
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

  const xpProgress = user ? (user.totalXp / (100 * Math.pow(user.level, 1.5))) * 100 : 0;
  const xpRequired = user ? Math.floor(100 * Math.pow(user.level, 1.5)) : 100;

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
            href="/profile"
            className="flex items-center gap-3 px-3 py-2 text-[var(--text-secondary)] hover:text-[var(--text-primary)] hover:bg-[var(--bg-hover)] rounded-lg transition-colors"
          >
            <span>👤</span>
            <span>프로필</span>
          </Link>
        </nav>

        {/* User Stats */}
        <div className="p-4 border-t border-[var(--border-default)]">
          <div className="bg-[var(--bg-elevated)] rounded-xl p-4 space-y-3">
            {/* User Info */}
            <div className="flex items-center gap-3 pb-3 border-b border-[var(--border-default)]">
              {user?.avatarUrl ? (
                <img
                  src={user.avatarUrl}
                  alt={user.username}
                  className="w-10 h-10 rounded-full"
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
                <span>XP</span>
                <span>{user?.totalXp || 0} / {xpRequired}</span>
              </div>
              <div className="h-2 bg-[var(--bg-primary)] rounded-full overflow-hidden">
                <div
                  className="h-full bg-[var(--xp-gold)] transition-all"
                  style={{ width: `${Math.min(xpProgress, 100)}%` }}
                />
              </div>
            </div>

            {/* Streak & Gems */}
            <div className="flex justify-between text-sm">
              <div className="flex items-center gap-1">
                <span>🔥</span>
                <span className="text-[var(--streak-orange)]">{user?.streakDays || 0}일</span>
              </div>
              <div className="flex items-center gap-1">
                <span>💎</span>
                <span className="text-[var(--gem-purple)]">{user?.gems || 0}</span>
              </div>
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
