export default function LessonLoading() {
  return (
    <div className="min-h-screen bg-[var(--bg-primary)]">
      {/* 헤더 스켈레톤 */}
      <header className="sticky top-0 z-10 bg-[var(--bg-secondary)] border-b border-[var(--border-default)]">
        <div className="max-w-7xl mx-auto px-4 py-3 flex items-center justify-between">
          <div className="flex items-center gap-4 animate-pulse">
            <div className="w-10 h-10 bg-[var(--bg-tertiary)] rounded-lg" />
            <div className="space-y-2">
              <div className="h-5 w-40 bg-[var(--bg-tertiary)] rounded" />
              <div className="h-4 w-24 bg-[var(--bg-tertiary)] rounded" />
            </div>
          </div>
          <div className="flex items-center gap-2">
            <div className="h-10 w-20 bg-[var(--bg-tertiary)] rounded-lg" />
            <div className="h-10 w-24 bg-[var(--accent-primary)]/30 rounded-lg" />
          </div>
        </div>
      </header>

      {/* 콘텐츠 스켈레톤 */}
      <main className="max-w-7xl mx-auto p-4 animate-pulse">
        <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
          {/* 왼쪽: 설명 */}
          <div className="bg-[var(--bg-secondary)] rounded-xl p-6 border border-[var(--border-default)] space-y-4">
            <div className="h-6 w-2/3 bg-[var(--bg-tertiary)] rounded" />
            <div className="space-y-2">
              <div className="h-4 w-full bg-[var(--bg-tertiary)] rounded" />
              <div className="h-4 w-5/6 bg-[var(--bg-tertiary)] rounded" />
              <div className="h-4 w-4/5 bg-[var(--bg-tertiary)] rounded" />
            </div>
            <div className="h-32 bg-[var(--bg-tertiary)] rounded-lg" />
            <div className="space-y-2">
              <div className="h-4 w-full bg-[var(--bg-tertiary)] rounded" />
              <div className="h-4 w-3/4 bg-[var(--bg-tertiary)] rounded" />
            </div>
          </div>

          {/* 오른쪽: 에디터 */}
          <div className="space-y-4">
            <div className="h-[400px] bg-[var(--bg-editor)] rounded-xl border border-[var(--border-default)]" />
            <div className="h-[120px] bg-[var(--bg-terminal)] rounded-xl border border-[var(--border-default)]" />
          </div>
        </div>
      </main>
    </div>
  );
}
