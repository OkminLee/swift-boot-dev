"use client";

import { useState, useEffect } from "react";
import Link from "next/link";
import { api, Track, Course, CourseProgress } from "@/lib/api";

const difficultyLabels: Record<string, { label: string; color: string }> = {
  beginner: { label: "입문", color: "text-[var(--accent-success)]" },
  intermediate: { label: "중급", color: "text-[var(--accent-warning)]" },
  advanced: { label: "고급", color: "text-[var(--accent-error)]" },
};

const trackIcons: Record<string, string> = {
  swift: "🦅",
  python: "🐍",
  go: "🐹",
  javascript: "⚡",
  default: "📚",
};

interface TrackWithCourses extends Track {
  courses: Course[];
}

export default function CoursesPage() {
  const [tracks, setTracks] = useState<TrackWithCourses[]>([]);
  const [isLoading, setIsLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [courseProgressMap, setCourseProgressMap] = useState<Map<string, CourseProgress>>(new Map());

  useEffect(() => {
    async function loadTracks() {
      try {
        const [trackList, progressList] = await Promise.all([
          api.getTracks(),
          api.getCourseProgress().catch(() => [] as CourseProgress[]),
        ]);

        // 코스별 진행률 맵 생성
        const progressMap = new Map<string, CourseProgress>();
        progressList.forEach((p) => progressMap.set(p.courseId, p));
        setCourseProgressMap(progressMap);

        // 각 트랙의 코스 정보 로드
        const tracksWithCourses = await Promise.all(
          trackList.map(async (track) => {
            try {
              const trackDetail = await api.getTrack(track.id);
              return { ...track, courses: trackDetail.courses || [] };
            } catch {
              return { ...track, courses: [] };
            }
          })
        );

        setTracks(tracksWithCourses);
      } catch (err) {
        console.error("Failed to load tracks:", err);
        setError("트랙을 불러오는데 실패했습니다.");
      } finally {
        setIsLoading(false);
      }
    }

    loadTracks();
  }, []);

  if (isLoading) {
    return (
      <div className="p-8">
        <div className="mb-8">
          <div className="h-9 w-32 bg-[var(--bg-secondary)] rounded animate-pulse" />
          <div className="mt-2 h-5 w-64 bg-[var(--bg-secondary)] rounded animate-pulse" />
        </div>
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
          {[1, 2, 3].map((i) => (
            <div
              key={i}
              className="h-48 bg-[var(--bg-secondary)] rounded-xl animate-pulse"
            />
          ))}
        </div>
      </div>
    );
  }

  if (error) {
    return (
      <div className="p-8">
        <div className="text-center py-16">
          <p className="text-[var(--accent-error)] mb-4">{error}</p>
          <button
            onClick={() => window.location.reload()}
            className="px-4 py-2 bg-[var(--bg-secondary)] text-[var(--text-primary)] rounded-lg hover:bg-[var(--bg-hover)]"
          >
            다시 시도
          </button>
        </div>
      </div>
    );
  }

  return (
    <div className="p-8">
      {/* Header */}
      <div className="mb-8">
        <h1 className="text-3xl font-bold text-[var(--text-primary)]">학습 트랙</h1>
        <p className="mt-2 text-[var(--text-secondary)]">
          관심있는 분야를 선택하고 체계적으로 학습하세요
        </p>
      </div>

      {/* Tracks */}
      <div className="space-y-12">
        {tracks.map((track) => (
          <section key={track.id}>
            {/* Track Header */}
            <div className="flex items-center gap-3 mb-6">
              <span className="text-3xl">
                {trackIcons[track.icon || ""] || trackIcons.default}
              </span>
              <div>
                <h2 className="text-xl font-bold text-[var(--text-primary)]">
                  {track.title}
                </h2>
                <p className="text-sm text-[var(--text-secondary)]">
                  {track.description}
                </p>
              </div>
            </div>

            {/* Course Grid */}
            {track.courses.length > 0 ? (
              <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
                {track.courses.map((course) => {
                  const progress = courseProgressMap.get(course.id);
                  const hasProgress = progress && progress.completedLessons > 0;
                  const isCompleted = progress && progress.completedLessons === progress.totalLessons && progress.totalLessons > 0;
                  const progressPercent = progress && progress.totalLessons > 0
                    ? (progress.completedLessons / progress.totalLessons) * 100
                    : 0;

                  return (
                    <Link
                      key={course.id}
                      href={`/courses/${course.id}`}
                      className={`group bg-[var(--bg-secondary)] border rounded-xl p-6 hover:border-[var(--accent-primary)] transition-all hover:shadow-lg ${
                        isCompleted
                          ? "border-[var(--accent-success)]"
                          : "border-[var(--border-default)]"
                      }`}
                    >
                      {/* Icon */}
                      <div className="flex items-start justify-between mb-4">
                        <div className="w-12 h-12 bg-[var(--bg-elevated)] rounded-lg flex items-center justify-center">
                          <span className="text-2xl">
                            {course.icon === "book" && "📖"}
                            {course.icon === "arrow.triangle.branch" && "🔀"}
                            {!course.icon && "📚"}
                          </span>
                        </div>
                        {isCompleted && (
                          <span className="text-sm px-2 py-1 bg-[var(--accent-success)]/10 text-[var(--accent-success)] rounded-full font-medium">
                            ✓ 완료
                          </span>
                        )}
                      </div>

                      {/* Title & Description */}
                      <h3 className="text-lg font-semibold text-[var(--text-primary)] group-hover:text-[var(--accent-primary)] transition-colors">
                        {course.title}
                      </h3>
                      <p className="mt-2 text-sm text-[var(--text-secondary)] line-clamp-2">
                        {course.description}
                      </p>

                      {/* Progress Bar */}
                      {hasProgress && !isCompleted && (
                        <div className="mt-4">
                          <div className="flex items-center justify-between text-xs mb-1">
                            <span className="text-[var(--text-muted)]">진행률</span>
                            <span className="text-[var(--accent-success)]">
                              {progress.completedLessons}/{progress.totalLessons}
                            </span>
                          </div>
                          <div className="h-1.5 bg-[var(--bg-elevated)] rounded-full overflow-hidden">
                            <div
                              className="h-full bg-[var(--accent-success)] rounded-full transition-all duration-300"
                              style={{ width: `${progressPercent}%` }}
                            />
                          </div>
                        </div>
                      )}

                      {/* Meta */}
                      <div className="mt-4 flex items-center justify-between">
                        <span
                          className={`text-sm font-medium ${difficultyLabels[course.difficulty]?.color || "text-[var(--text-muted)]"}`}
                        >
                          {difficultyLabels[course.difficulty]?.label || course.difficulty}
                        </span>
                        <span className="text-xs px-2 py-1 bg-[var(--bg-elevated)] text-[var(--text-muted)] rounded">
                          {hasProgress ? "이어하기 →" : "시작하기 →"}
                        </span>
                      </div>
                    </Link>
                  );
                })}
              </div>
            ) : (
              <div className="bg-[var(--bg-secondary)] border border-[var(--border-default)] rounded-xl p-8 text-center">
                <p className="text-[var(--text-muted)]">
                  아직 등록된 코스가 없습니다. 곧 추가될 예정이에요!
                </p>
              </div>
            )}
          </section>
        ))}

        {tracks.length === 0 && (
          <div className="text-center py-16">
            <span className="text-6xl mb-4 block">📚</span>
            <p className="text-[var(--text-secondary)]">
              등록된 학습 트랙이 없습니다.
            </p>
          </div>
        )}
      </div>
    </div>
  );
}
