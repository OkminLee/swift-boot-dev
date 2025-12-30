import Link from "next/link";

export default function NotFoundPage() {
  return (
    <div className="min-h-screen bg-[var(--bg-primary)] flex items-center justify-center p-4">
      <div className="text-center max-w-md">
        <div className="text-8xl mb-6">🔍</div>

        <h1 className="text-3xl font-bold text-[var(--text-primary)] mb-2">
          404
        </h1>
        <h2 className="text-xl text-[var(--text-secondary)] mb-4">
          페이지를 찾을 수 없습니다
        </h2>
        <p className="text-[var(--text-muted)] mb-8">
          요청하신 페이지가 존재하지 않거나
          <br />
          이동되었을 수 있습니다.
        </p>

        <div className="flex gap-3 justify-center">
          <Link
            href="/"
            className="px-4 py-2 bg-[var(--bg-tertiary)] text-[var(--text-primary)] rounded-lg hover:bg-[var(--bg-hover)] transition-colors"
          >
            홈으로
          </Link>
          <Link
            href="/courses"
            className="px-4 py-2 bg-[var(--accent-primary)] text-white rounded-lg hover:bg-[var(--accent-primary-hover)] transition-colors"
          >
            코스 둘러보기
          </Link>
        </div>
      </div>
    </div>
  );
}
