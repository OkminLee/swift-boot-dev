export default function DashboardLoading() {
  return (
    <div className="p-6 space-y-6 animate-pulse">
      {/* 헤더 스켈레톤 */}
      <div className="flex items-center justify-between">
        <div className="h-8 w-48 bg-[var(--bg-tertiary)] rounded-lg" />
        <div className="h-10 w-32 bg-[var(--bg-tertiary)] rounded-lg" />
      </div>

      {/* 그리드 스켈레톤 */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
        {[1, 2, 3, 4, 5, 6].map((i) => (
          <div
            key={i}
            className="h-48 bg-[var(--bg-secondary)] rounded-xl border border-[var(--border-default)]"
          >
            <div className="p-4 space-y-3">
              <div className="h-4 w-3/4 bg-[var(--bg-tertiary)] rounded" />
              <div className="h-3 w-1/2 bg-[var(--bg-tertiary)] rounded" />
              <div className="h-20 bg-[var(--bg-tertiary)] rounded-lg" />
            </div>
          </div>
        ))}
      </div>
    </div>
  );
}
