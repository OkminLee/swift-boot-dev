"use client";

import Link from "next/link";
import Image from "next/image";
import { useRouter, usePathname } from "next/navigation";
import { useEffect } from "react";
import { useAuth } from "@/stores/auth-store";
import { useSoundStore } from "@/stores/sound-store";
import { useUIStore } from "@/stores/ui-store";
import { playSuccess } from "@/lib/sounds";

const MOBILE_BREAKPOINT = 768;

export default function DashboardLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  const router = useRouter();
  const pathname = usePathname();
  const { user, stats, isAuthenticated, isLoading, isInitialized, logout } = useAuth();
  const soundEnabled = useSoundStore((state) => state.soundEnabled);
  const toggleSound = useSoundStore((state) => state.toggleSound);
  const initializeSound = useSoundStore((state) => state.initialize);

  const { isSidebarOpen, isMobile, openSidebar, closeSidebar, setIsMobile } = useUIStore();

  // 사운드 설정 초기화
  useEffect(() => {
    initializeSound();
  }, [initializeSound]);

  // 모바일 감지
  useEffect(() => {
    const checkMobile = () => {
      setIsMobile(window.innerWidth < MOBILE_BREAKPOINT);
    };
    checkMobile();
    window.addEventListener("resize", checkMobile);
    return () => window.removeEventListener("resize", checkMobile);
  }, [setIsMobile]);

  // 라우트 변경 시 모바일 사이드바 닫기
  useEffect(() => {
    if (isMobile) {
      closeSidebar();
    }
  }, [pathname, isMobile, closeSidebar]);

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

  // 네비게이션 아이템
  const navItems = [
    { href: "/courses", icon: "📚", label: "코스" },
    { href: "/shop", icon: "🏪", label: "상점" },
    { href: "/inventory", icon: "🎒", label: "인벤토리" },
    { href: "/profile", icon: "👤", label: "프로필" },
  ];

  const isActive = (href: string) => pathname === href || pathname?.startsWith(`${href}/`);

  return (
    <div className="min-h-screen flex">
      {/* 모바일 헤더 */}
      {isMobile && (
        <header className="fixed top-0 left-0 right-0 h-14 bg-[var(--bg-secondary)] border-b border-[var(--border-default)] flex items-center justify-between px-4 z-[var(--z-fixed)]">
          <button
            onClick={openSidebar}
            className="p-2 -ml-2 text-[var(--text-primary)] hover:bg-[var(--bg-hover)] rounded-lg transition-colors"
            aria-label="메뉴 열기"
            aria-expanded={isSidebarOpen}
            aria-controls="mobile-sidebar"
          >
            <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" aria-hidden="true">
              <line x1="3" y1="12" x2="21" y2="12" />
              <line x1="3" y1="6" x2="21" y2="6" />
              <line x1="3" y1="18" x2="21" y2="18" />
            </svg>
          </button>
          <Link href="/courses" className="flex items-center gap-2" aria-label="SwiftBoot 홈">
            <span className="text-xl" aria-hidden="true">🚀</span>
            <span className="font-bold text-[var(--text-primary)]">SwiftBoot</span>
          </Link>
          <div className="w-10" aria-hidden="true" />
        </header>
      )}

      {/* 모바일 오버레이 */}
      {isMobile && isSidebarOpen && (
        <div
          className="fixed inset-0 bg-[var(--bg-overlay)] z-[var(--z-modal-backdrop)] animate-fadeIn"
          onClick={closeSidebar}
          aria-hidden="true"
        />
      )}

      {/* 사이드바 */}
      <aside
        id="mobile-sidebar"
        className={`
          ${isMobile
            ? `fixed top-0 left-0 h-full z-[var(--z-modal)] transform transition-transform duration-300 ${
                isSidebarOpen ? "translate-x-0" : "-translate-x-full"
              }`
            : "relative"
          }
          w-64 bg-[var(--bg-secondary)] border-r border-[var(--border-default)] flex flex-col
        `}
        aria-label="사이드바"
      >
        {/* 모바일 닫기 버튼 */}
        {isMobile && (
          <button
            onClick={closeSidebar}
            className="absolute top-4 right-4 p-1 text-[var(--text-secondary)] hover:text-[var(--text-primary)] hover:bg-[var(--bg-hover)] rounded transition-colors z-10"
            aria-label="메뉴 닫기"
          >
            <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" aria-hidden="true">
              <line x1="18" y1="6" x2="6" y2="18" />
              <line x1="6" y1="6" x2="18" y2="18" />
            </svg>
          </button>
        )}

        {/* Logo */}
        <div className="h-16 flex items-center px-4 border-b border-[var(--border-default)]">
          <Link href="/courses" className="flex items-center gap-2" aria-label="SwiftBoot 홈">
            <span className="text-2xl" aria-hidden="true">🚀</span>
            <span className="font-bold text-lg text-[var(--text-primary)]">
              SwiftBoot
            </span>
          </Link>
        </div>

        {/* Navigation */}
        <nav className="flex-1 p-4 space-y-2" aria-label="메인 내비게이션">
          {navItems.map((item) => (
            <Link
              key={item.href}
              href={item.href}
              className={`flex items-center gap-3 px-3 py-2 rounded-lg transition-colors ${
                isActive(item.href)
                  ? "text-[var(--text-primary)] bg-[var(--bg-hover)]"
                  : "text-[var(--text-secondary)] hover:text-[var(--text-primary)] hover:bg-[var(--bg-hover)]"
              }`}
              aria-current={isActive(item.href) ? "page" : undefined}
            >
              <span aria-hidden="true">{item.icon}</span>
              <span>{item.label}</span>
            </Link>
          ))}

          {/* 사운드 토글 */}
          <button
            onClick={handleToggleSound}
            className="flex items-center justify-between w-full px-3 py-2 text-[var(--text-secondary)] hover:text-[var(--text-primary)] hover:bg-[var(--bg-hover)] rounded-lg transition-colors"
            aria-label={soundEnabled ? "사운드 끄기" : "사운드 켜기"}
            aria-pressed={soundEnabled}
          >
            <div className="flex items-center gap-3">
              <span aria-hidden="true">{soundEnabled ? "🔊" : "🔇"}</span>
              <span>사운드</span>
            </div>
            <div
              className={`w-8 h-5 rounded-full transition-colors flex items-center px-0.5 ${
                soundEnabled ? "bg-[var(--accent-primary)]" : "bg-[var(--bg-tertiary)]"
              }`}
              role="switch"
              aria-checked={soundEnabled}
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
                  alt={user.username || "사용자 아바타"}
                  width={40}
                  height={40}
                  className="rounded-full"
                  priority={false}
                />
              ) : (
                <div
                  className="w-10 h-10 rounded-full bg-[var(--accent-primary)] flex items-center justify-center text-white font-bold"
                  aria-label={`${user?.username}의 아바타`}
                >
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
            <div role="progressbar" aria-valuenow={xpProgress} aria-valuemin={0} aria-valuemax={100} aria-label="경험치 진행률">
              <div className="flex justify-between text-xs text-[var(--text-muted)] mb-1">
                <span>다음 레벨까지</span>
                <span>{xpToNextLevel} XP</span>
              </div>
              <div className="h-2 bg-[var(--bg-primary)] rounded-full overflow-hidden">
                <div
                  className="h-full bg-[var(--xp-gold)] transition-all duration-500"
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
              <div className="flex items-center gap-1" aria-label={`${user?.streakDays || 0}일 연속 학습`}>
                <span aria-hidden="true">🔥</span>
                <span className="text-[var(--streak-orange)]">{user?.streakDays || 0}일</span>
              </div>
              <Link
                href="/shop"
                className="flex items-center gap-1 hover:opacity-80 transition-opacity"
                aria-label={`보유 젬: ${user?.gems || 0}개, 상점으로 이동`}
              >
                <span aria-hidden="true">💎</span>
                <span className="text-[var(--gem-purple)]">{user?.gems || 0}</span>
              </Link>
            </div>

            {/* Logout */}
            <button
              onClick={handleLogout}
              className="w-full mt-2 px-3 py-2 text-sm text-[var(--text-secondary)] hover:text-[var(--error-red)] hover:bg-[var(--bg-hover)] rounded-lg transition-colors text-left"
              aria-label="로그아웃"
            >
              로그아웃
            </button>
          </div>
        </div>
      </aside>

      {/* Main Content */}
      <main
        className={`flex-1 bg-[var(--bg-primary)] ${isMobile ? "pt-14" : ""}`}
        role="main"
      >
        {children}
      </main>
    </div>
  );
}
