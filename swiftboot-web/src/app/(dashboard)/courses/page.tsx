import Link from "next/link";

// TODO: API에서 가져오기
const mockCourses = [
  {
    id: "1",
    title: "Swift 기초",
    description: "Swift 언어의 기본 문법과 개념을 배웁니다.",
    icon: "🦅",
    difficulty: "beginner",
    lessonsCount: 10,
    completedCount: 0,
  },
  {
    id: "2",
    title: "Vapor 입문",
    description: "Swift로 웹 서버를 만드는 방법을 배웁니다.",
    icon: "💧",
    difficulty: "intermediate",
    lessonsCount: 15,
    completedCount: 0,
  },
  {
    id: "3",
    title: "Python 기초",
    description: "Python 프로그래밍의 기초를 배웁니다.",
    icon: "🐍",
    difficulty: "beginner",
    lessonsCount: 12,
    completedCount: 0,
  },
];

const difficultyLabels: Record<string, { label: string; color: string }> = {
  beginner: { label: "입문", color: "text-[var(--accent-success)]" },
  intermediate: { label: "중급", color: "text-[var(--accent-warning)]" },
  advanced: { label: "고급", color: "text-[var(--accent-error)]" },
};

export default function CoursesPage() {
  return (
    <div className="p-8">
      {/* Header */}
      <div className="mb-8">
        <h1 className="text-3xl font-bold text-[var(--text-primary)]">코스</h1>
        <p className="mt-2 text-[var(--text-secondary)]">
          학습하고 싶은 코스를 선택하세요
        </p>
      </div>

      {/* Course Grid */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
        {mockCourses.map((course) => (
          <Link
            key={course.id}
            href={`/learn/${course.id}`}
            className="group bg-[var(--bg-secondary)] border border-[var(--border-default)] rounded-xl p-6 hover:border-[var(--accent-primary)] transition-colors"
          >
            {/* Icon */}
            <div className="text-4xl mb-4">{course.icon}</div>

            {/* Title & Description */}
            <h2 className="text-xl font-semibold text-[var(--text-primary)] group-hover:text-[var(--accent-primary)] transition-colors">
              {course.title}
            </h2>
            <p className="mt-2 text-sm text-[var(--text-secondary)] line-clamp-2">
              {course.description}
            </p>

            {/* Meta */}
            <div className="mt-4 flex items-center justify-between">
              <span
                className={`text-sm font-medium ${difficultyLabels[course.difficulty].color}`}
              >
                {difficultyLabels[course.difficulty].label}
              </span>
              <span className="text-sm text-[var(--text-muted)]">
                {course.completedCount}/{course.lessonsCount} 레슨
              </span>
            </div>

            {/* Progress Bar */}
            <div className="mt-3 h-1.5 bg-[var(--bg-primary)] rounded-full overflow-hidden">
              <div
                className="h-full bg-[var(--accent-primary)]"
                style={{
                  width: `${(course.completedCount / course.lessonsCount) * 100}%`,
                }}
              />
            </div>
          </Link>
        ))}
      </div>
    </div>
  );
}
