"use client";

import { useState, useEffect } from "react";
import Link from "next/link";
import { useParams, useRouter } from "next/navigation";
import { api, CourseDetail, Chapter, LessonSummary } from "@/lib/api";

const lessonTypeIcons: Record<string, { icon: string; label: string }> = {
  reading: { icon: "📖", label: "읽기" },
  codeExercise: { icon: "💻", label: "코드 연습" },
  codeOutput: { icon: "🖥️", label: "출력 맞추기" },
  multipleChoice: { icon: "📝", label: "객관식" },
};

const difficultyLabels: Record<string, { label: string; color: string; bg: string }> = {
  beginner: {
    label: "입문",
    color: "text-[var(--accent-success)]",
    bg: "bg-[var(--accent-success)]/10"
  },
  intermediate: {
    label: "중급",
    color: "text-[var(--accent-warning)]",
    bg: "bg-[var(--accent-warning)]/10"
  },
  advanced: {
    label: "고급",
    color: "text-[var(--accent-error)]",
    bg: "bg-[var(--accent-error)]/10"
  },
};

export default function CourseDetailPage() {
  const params = useParams();
  const router = useRouter();
  const courseId = params.courseId as string;

  const [course, setCourse] = useState<CourseDetail | null>(null);
  const [isLoading, setIsLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [expandedChapters, setExpandedChapters] = useState<Set<string>>(new Set());

  useEffect(() => {
    async function loadCourse() {
      try {
        const data = await api.getCourse(courseId);
        setCourse(data);
        // 첫 번째 챕터 자동 펼침
        if (data.chapters.length > 0) {
          setExpandedChapters(new Set([data.chapters[0].id]));
        }
      } catch (err) {
        console.error("Failed to load course:", err);
        setError("코스를 불러오는데 실패했습니다.");
      } finally {
        setIsLoading(false);
      }
    }

    loadCourse();
  }, [courseId]);

  const toggleChapter = (chapterId: string) => {
    setExpandedChapters((prev) => {
      const next = new Set(prev);
      if (next.has(chapterId)) {
        next.delete(chapterId);
      } else {
        next.add(chapterId);
      }
      return next;
    });
  };

  const getTotalLessons = () => {
    if (!course) return 0;
    return course.chapters.reduce((acc, ch) => acc + ch.lessons.length, 0);
  };

  const getTotalXp = () => {
    if (!course) return 0;
    return course.chapters.reduce(
      (acc, ch) => acc + ch.lessons.reduce((a, l) => a + l.xpReward, 0),
      0
    );
  };

  if (isLoading) {
    return (
      <div className="p-8">
        <div className="max-w-4xl mx-auto">
          <div className="h-8 w-32 bg-[var(--bg-secondary)] rounded animate-pulse mb-6" />
          <div className="h-12 w-64 bg-[var(--bg-secondary)] rounded animate-pulse mb-4" />
          <div className="h-6 w-96 bg-[var(--bg-secondary)] rounded animate-pulse mb-8" />
          <div className="space-y-4">
            {[1, 2, 3].map((i) => (
              <div
                key={i}
                className="h-20 bg-[var(--bg-secondary)] rounded-xl animate-pulse"
              />
            ))}
          </div>
        </div>
      </div>
    );
  }

  if (error || !course) {
    return (
      <div className="p-8">
        <div className="max-w-4xl mx-auto text-center py-16">
          <p className="text-[var(--accent-error)] mb-4">
            {error || "코스를 찾을 수 없습니다."}
          </p>
          <button
            onClick={() => router.back()}
            className="px-4 py-2 bg-[var(--bg-secondary)] text-[var(--text-primary)] rounded-lg hover:bg-[var(--bg-hover)]"
          >
            돌아가기
          </button>
        </div>
      </div>
    );
  }

  const difficulty = difficultyLabels[course.difficulty] || difficultyLabels.beginner;

  return (
    <div className="p-8">
      <div className="max-w-4xl mx-auto">
        {/* Back Button */}
        <button
          onClick={() => router.back()}
          className="flex items-center gap-2 text-[var(--text-secondary)] hover:text-[var(--text-primary)] mb-6 transition-colors"
        >
          <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M15 19l-7-7 7-7" />
          </svg>
          <span>코스 목록</span>
        </button>

        {/* Course Header */}
        <div className="bg-[var(--bg-secondary)] border border-[var(--border-default)] rounded-2xl p-8 mb-8">
          <div className="flex items-start gap-6">
            {/* Icon */}
            <div className="w-16 h-16 bg-[var(--bg-elevated)] rounded-xl flex items-center justify-center shrink-0">
              <span className="text-3xl">
                {course.icon === "book" && "📖"}
                {course.icon === "arrow.triangle.branch" && "🔀"}
                {!course.icon && "📚"}
              </span>
            </div>

            {/* Info */}
            <div className="flex-1">
              <div className="flex items-center gap-3 mb-2">
                <span className={`text-sm font-medium px-2 py-1 rounded ${difficulty.color} ${difficulty.bg}`}>
                  {difficulty.label}
                </span>
              </div>
              <h1 className="text-2xl font-bold text-[var(--text-primary)] mb-2">
                {course.title}
              </h1>
              <p className="text-[var(--text-secondary)]">{course.description}</p>

              {/* Stats */}
              <div className="flex items-center gap-6 mt-4 text-sm">
                <div className="flex items-center gap-2">
                  <span className="text-[var(--text-muted)]">📚</span>
                  <span className="text-[var(--text-secondary)]">
                    {course.chapters.length}개 챕터
                  </span>
                </div>
                <div className="flex items-center gap-2">
                  <span className="text-[var(--text-muted)]">📝</span>
                  <span className="text-[var(--text-secondary)]">
                    {getTotalLessons()}개 레슨
                  </span>
                </div>
                <div className="flex items-center gap-2">
                  <span className="text-[var(--xp-gold)]">⭐</span>
                  <span className="text-[var(--text-secondary)]">
                    총 {getTotalXp()} XP
                  </span>
                </div>
              </div>
            </div>
          </div>

          {/* Start Button */}
          {course.chapters.length > 0 && course.chapters[0].lessons.length > 0 && (
            <Link
              href={`/learn/${course.chapters[0].lessons[0].id}`}
              className="mt-6 w-full flex items-center justify-center gap-2 py-3 bg-[var(--accent-primary)] text-white font-medium rounded-xl hover:bg-[var(--accent-primary)]/90 transition-colors"
            >
              <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M14.752 11.168l-3.197-2.132A1 1 0 0010 9.87v4.263a1 1 0 001.555.832l3.197-2.132a1 1 0 000-1.664z" />
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
              </svg>
              학습 시작하기
            </Link>
          )}
        </div>

        {/* Chapters */}
        <div className="space-y-4">
          <h2 className="text-lg font-semibold text-[var(--text-primary)] mb-4">
            커리큘럼
          </h2>

          {course.chapters.map((chapter, index) => (
            <ChapterAccordion
              key={chapter.id}
              chapter={chapter}
              index={index + 1}
              isExpanded={expandedChapters.has(chapter.id)}
              onToggle={() => toggleChapter(chapter.id)}
            />
          ))}
        </div>
      </div>
    </div>
  );
}

interface ChapterAccordionProps {
  chapter: Chapter;
  index: number;
  isExpanded: boolean;
  onToggle: () => void;
}

function ChapterAccordion({ chapter, index, isExpanded, onToggle }: ChapterAccordionProps) {
  const totalXp = chapter.lessons.reduce((acc, l) => acc + l.xpReward, 0);

  return (
    <div className="bg-[var(--bg-secondary)] border border-[var(--border-default)] rounded-xl overflow-hidden">
      {/* Chapter Header */}
      <button
        onClick={onToggle}
        className="w-full flex items-center justify-between p-4 hover:bg-[var(--bg-hover)] transition-colors"
      >
        <div className="flex items-center gap-4">
          <div className="w-8 h-8 bg-[var(--accent-primary)]/10 text-[var(--accent-primary)] rounded-lg flex items-center justify-center font-bold text-sm">
            {index}
          </div>
          <div className="text-left">
            <h3 className="font-semibold text-[var(--text-primary)]">{chapter.title}</h3>
            {chapter.description && (
              <p className="text-sm text-[var(--text-muted)] mt-0.5">{chapter.description}</p>
            )}
          </div>
        </div>
        <div className="flex items-center gap-4">
          <span className="text-sm text-[var(--text-muted)]">
            {chapter.lessons.length}개 레슨 · {totalXp} XP
          </span>
          <svg
            className={`w-5 h-5 text-[var(--text-muted)] transition-transform ${isExpanded ? "rotate-180" : ""}`}
            fill="none"
            stroke="currentColor"
            viewBox="0 0 24 24"
          >
            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M19 9l-7 7-7-7" />
          </svg>
        </div>
      </button>

      {/* Lessons */}
      {isExpanded && (
        <div className="border-t border-[var(--border-default)]">
          {chapter.lessons.map((lesson, lessonIndex) => (
            <LessonRow key={lesson.id} lesson={lesson} index={lessonIndex + 1} />
          ))}
        </div>
      )}
    </div>
  );
}

interface LessonRowProps {
  lesson: LessonSummary;
  index: number;
}

function LessonRow({ lesson, index }: LessonRowProps) {
  const type = lessonTypeIcons[lesson.type] || lessonTypeIcons.reading;

  return (
    <Link
      href={`/learn/${lesson.id}`}
      className="flex items-center justify-between px-4 py-3 hover:bg-[var(--bg-hover)] transition-colors border-b border-[var(--border-default)] last:border-b-0"
    >
      <div className="flex items-center gap-4">
        <div className="w-6 h-6 flex items-center justify-center text-[var(--text-muted)]">
          {index}
        </div>
        <span className="text-lg" title={type.label}>
          {type.icon}
        </span>
        <span className="text-[var(--text-primary)]">{lesson.title}</span>
      </div>
      <div className="flex items-center gap-3">
        <span className="text-sm text-[var(--xp-gold)]">+{lesson.xpReward} XP</span>
        <svg
          className="w-4 h-4 text-[var(--text-muted)]"
          fill="none"
          stroke="currentColor"
          viewBox="0 0 24 24"
        >
          <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 5l7 7-7 7" />
        </svg>
      </div>
    </Link>
  );
}
