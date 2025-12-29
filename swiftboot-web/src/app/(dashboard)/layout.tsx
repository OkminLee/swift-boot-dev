import Link from "next/link";

export default function DashboardLayout({
  children,
}: {
  children: React.ReactNode;
}) {
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
            {/* Level */}
            <div className="flex items-center justify-between">
              <span className="text-sm text-[var(--text-secondary)]">레벨</span>
              <span className="font-bold text-[var(--text-primary)]">1</span>
            </div>
            {/* XP Bar */}
            <div>
              <div className="flex justify-between text-xs text-[var(--text-muted)] mb-1">
                <span>XP</span>
                <span>0 / 100</span>
              </div>
              <div className="h-2 bg-[var(--bg-primary)] rounded-full overflow-hidden">
                <div
                  className="h-full bg-[var(--xp-gold)]"
                  style={{ width: "0%" }}
                />
              </div>
            </div>
            {/* Streak & Gems */}
            <div className="flex justify-between text-sm">
              <div className="flex items-center gap-1">
                <span>🔥</span>
                <span className="text-[var(--streak-orange)]">0일</span>
              </div>
              <div className="flex items-center gap-1">
                <span>💎</span>
                <span className="text-[var(--gem-purple)]">0</span>
              </div>
            </div>
          </div>
        </div>
      </aside>

      {/* Main Content */}
      <main className="flex-1 bg-[var(--bg-primary)]">{children}</main>
    </div>
  );
}
