"use client";

import { useState, useEffect, useCallback } from "react";
import { useParams, useRouter } from "next/navigation";
import { api, Lesson, SubmissionResponse, Language } from "@/lib/api";
import { CodeEditor, OutputViewer } from "@/components/CodeEditor";
import ReactMarkdown from "react-markdown";
import remarkGfm from "remark-gfm";

export default function LessonPage() {
  const params = useParams();
  const router = useRouter();
  const lessonId = params.lessonId as string;

  const [lesson, setLesson] = useState<Lesson | null>(null);
  const [code, setCode] = useState("");
  const [isLoading, setIsLoading] = useState(true);
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [result, setResult] = useState<SubmissionResponse | null>(null);
  const [error, setError] = useState<string | null>(null);

  // 레슨 데이터 로드
  useEffect(() => {
    async function loadLesson() {
      try {
        const data = await api.getLesson(lessonId);
        setLesson(data);
        setCode(data.starterCode || "");
      } catch (err) {
        setError("레슨을 불러오는데 실패했습니다.");
        console.error(err);
      } finally {
        setIsLoading(false);
      }
    }
    loadLesson();
  }, [lessonId]);

  // 코드 제출
  const handleSubmit = useCallback(async () => {
    if (!lesson || isSubmitting) return;

    setIsSubmitting(true);
    setResult(null);

    try {
      const language = lesson.language || "swift";
      const response = await api.submitCode(lessonId, code, language as Language);
      setResult(response);
    } catch (err) {
      setResult({
        lessonId,
        status: "error",
        message: "제출 중 오류가 발생했습니다.",
      });
      console.error(err);
    } finally {
      setIsSubmitting(false);
    }
  }, [lesson, lessonId, code, isSubmitting]);

  // 코드 초기화
  const handleReset = useCallback(() => {
    if (lesson?.starterCode) {
      setCode(lesson.starterCode);
      setResult(null);
    }
  }, [lesson]);

  if (isLoading) {
    return (
      <div className="min-h-screen bg-[var(--bg-primary)] flex items-center justify-center">
        <div className="flex items-center gap-3 text-[var(--text-secondary)]">
          <div className="animate-spin w-6 h-6 border-2 border-[var(--accent-primary)] border-t-transparent rounded-full" />
          <span>레슨 로딩 중...</span>
        </div>
      </div>
    );
  }

  if (error || !lesson) {
    return (
      <div className="min-h-screen bg-[var(--bg-primary)] flex items-center justify-center">
        <div className="text-center">
          <p className="text-[var(--error-red)] mb-4">{error || "레슨을 찾을 수 없습니다."}</p>
          <button
            onClick={() => router.back()}
            className="px-4 py-2 bg-[var(--bg-tertiary)] text-[var(--text-primary)] rounded-lg hover:bg-[var(--bg-hover)]"
          >
            돌아가기
          </button>
        </div>
      </div>
    );
  }

  const isCodeLesson = lesson.type === "codeExercise" || lesson.type === "codeOutput";

  return (
    <div className="min-h-screen bg-[var(--bg-primary)]">
      {/* Header */}
      <header className="sticky top-0 z-10 bg-[var(--bg-secondary)] border-b border-[var(--border-default)]">
        <div className="max-w-7xl mx-auto px-4 py-3 flex items-center justify-between">
          <div className="flex items-center gap-4">
            <button
              onClick={() => router.back()}
              className="p-2 text-[var(--text-secondary)] hover:text-[var(--text-primary)] hover:bg-[var(--bg-hover)] rounded-lg transition-colors"
            >
              <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M15 19l-7-7 7-7" />
              </svg>
            </button>
            <div>
              <h1 className="text-lg font-semibold text-[var(--text-primary)]">{lesson.title}</h1>
              <div className="flex items-center gap-2 text-sm text-[var(--text-secondary)]">
                <span className="px-2 py-0.5 bg-[var(--accent-primary)]/10 text-[var(--accent-primary)] rounded">
                  {lesson.type === "reading" && "읽기"}
                  {lesson.type === "codeExercise" && "코드 연습"}
                  {lesson.type === "codeOutput" && "출력 맞추기"}
                  {lesson.type === "multipleChoice" && "객관식"}
                </span>
                <span className="flex items-center gap-1">
                  <span className="text-[var(--xp-gold)]">⭐</span>
                  {lesson.xpReward} XP
                </span>
              </div>
            </div>
          </div>

          {isCodeLesson && (
            <div className="flex items-center gap-2">
              <button
                onClick={handleReset}
                className="px-3 py-2 text-sm text-[var(--text-secondary)] hover:text-[var(--text-primary)] hover:bg-[var(--bg-hover)] rounded-lg transition-colors"
              >
                초기화
              </button>
              <button
                onClick={handleSubmit}
                disabled={isSubmitting}
                className="px-4 py-2 bg-[var(--accent-primary)] text-white font-medium rounded-lg hover:bg-[var(--accent-primary-hover)] disabled:opacity-50 disabled:cursor-not-allowed transition-colors flex items-center gap-2"
              >
                {isSubmitting ? (
                  <>
                    <div className="animate-spin w-4 h-4 border-2 border-white border-t-transparent rounded-full" />
                    실행 중...
                  </>
                ) : (
                  <>
                    <svg className="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M14.752 11.168l-3.197-2.132A1 1 0 0010 9.87v4.263a1 1 0 001.555.832l3.197-2.132a1 1 0 000-1.664z" />
                      <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
                    </svg>
                    실행
                  </>
                )}
              </button>
            </div>
          )}
        </div>
      </header>

      {/* Main Content */}
      <main className="max-w-7xl mx-auto p-4">
        {isCodeLesson ? (
          // 코드 레슨: 좌우 분할 레이아웃
          <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
            {/* 왼쪽: 설명 */}
            <div className="bg-[var(--bg-secondary)] rounded-xl p-6 border border-[var(--border-default)]">
              <div className="prose prose-invert max-w-none">
                <ReactMarkdown
                  remarkPlugins={[remarkGfm]}
                  components={{
                    h1: ({ children }) => (
                      <h1 className="text-2xl font-bold text-[var(--text-primary)] mb-4">{children}</h1>
                    ),
                    h2: ({ children }) => (
                      <h2 className="text-xl font-semibold text-[var(--text-primary)] mt-6 mb-3">{children}</h2>
                    ),
                    p: ({ children }) => (
                      <p className="text-[var(--text-secondary)] mb-4 leading-relaxed">{children}</p>
                    ),
                    code: ({ className, children, ...props }) => {
                      const isInline = !className;
                      if (isInline) {
                        return (
                          <code className="px-1.5 py-0.5 bg-[var(--bg-tertiary)] text-[var(--accent-primary)] rounded text-sm font-mono">
                            {children}
                          </code>
                        );
                      }
                      return (
                        <code className={className} {...props}>
                          {children}
                        </code>
                      );
                    },
                    pre: ({ children }) => (
                      <pre className="bg-[var(--bg-terminal)] p-4 rounded-lg overflow-x-auto mb-4 text-sm">
                        {children}
                      </pre>
                    ),
                    ul: ({ children }) => (
                      <ul className="list-disc list-inside text-[var(--text-secondary)] mb-4 space-y-1">{children}</ul>
                    ),
                    ol: ({ children }) => (
                      <ol className="list-decimal list-inside text-[var(--text-secondary)] mb-4 space-y-1">{children}</ol>
                    ),
                    blockquote: ({ children }) => (
                      <blockquote className="border-l-4 border-[var(--accent-primary)] pl-4 italic text-[var(--text-secondary)] my-4">
                        {children}
                      </blockquote>
                    ),
                  }}
                >
                  {lesson.content}
                </ReactMarkdown>
              </div>
            </div>

            {/* 오른쪽: 코드 에디터 */}
            <div className="space-y-4">
              <CodeEditor
                language={lesson.language || "swift"}
                value={code}
                onChange={setCode}
                height="400px"
              />

              {/* 실행 결과 */}
              {result && (
                <div className="space-y-3">
                  <OutputViewer
                    output={result.output || result.message}
                    isError={result.status === "error" || result.status === "failure"}
                    height="120px"
                  />

                  {result.status === "success" && result.isCorrect && (
                    <div className="flex items-center gap-3 p-4 bg-[var(--success-green)]/10 border border-[var(--success-green)] rounded-lg">
                      <div className="w-10 h-10 bg-[var(--success-green)] rounded-full flex items-center justify-center">
                        <svg className="w-6 h-6 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                          <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M5 13l4 4L19 7" />
                        </svg>
                      </div>
                      <div>
                        <p className="font-semibold text-[var(--success-green)]">정답입니다!</p>
                        <p className="text-sm text-[var(--text-secondary)]">
                          +{result.xpEarned || lesson.xpReward} XP 획득
                        </p>
                      </div>
                    </div>
                  )}

                  {result.status === "failure" && (
                    <div className="flex items-center gap-3 p-4 bg-[var(--error-red)]/10 border border-[var(--error-red)] rounded-lg">
                      <div className="w-10 h-10 bg-[var(--error-red)] rounded-full flex items-center justify-center">
                        <svg className="w-6 h-6 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                          <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M6 18L18 6M6 6l12 12" />
                        </svg>
                      </div>
                      <div>
                        <p className="font-semibold text-[var(--error-red)]">다시 시도해보세요</p>
                        <p className="text-sm text-[var(--text-secondary)]">{result.message}</p>
                      </div>
                    </div>
                  )}
                </div>
              )}
            </div>
          </div>
        ) : (
          // 읽기 레슨: 단일 컬럼 레이아웃
          <div className="max-w-3xl mx-auto">
            <div className="bg-[var(--bg-secondary)] rounded-xl p-8 border border-[var(--border-default)]">
              <div className="prose prose-invert max-w-none">
                <ReactMarkdown
                  remarkPlugins={[remarkGfm]}
                  components={{
                    h1: ({ children }) => (
                      <h1 className="text-2xl font-bold text-[var(--text-primary)] mb-4">{children}</h1>
                    ),
                    h2: ({ children }) => (
                      <h2 className="text-xl font-semibold text-[var(--text-primary)] mt-6 mb-3">{children}</h2>
                    ),
                    p: ({ children }) => (
                      <p className="text-[var(--text-secondary)] mb-4 leading-relaxed">{children}</p>
                    ),
                    code: ({ className, children, ...props }) => {
                      const isInline = !className;
                      if (isInline) {
                        return (
                          <code className="px-1.5 py-0.5 bg-[var(--bg-tertiary)] text-[var(--accent-primary)] rounded text-sm font-mono">
                            {children}
                          </code>
                        );
                      }
                      return (
                        <code className={className} {...props}>
                          {children}
                        </code>
                      );
                    },
                    pre: ({ children }) => (
                      <pre className="bg-[var(--bg-terminal)] p-4 rounded-lg overflow-x-auto mb-4 text-sm">
                        {children}
                      </pre>
                    ),
                    ul: ({ children }) => (
                      <ul className="list-disc list-inside text-[var(--text-secondary)] mb-4 space-y-1">{children}</ul>
                    ),
                    ol: ({ children }) => (
                      <ol className="list-decimal list-inside text-[var(--text-secondary)] mb-4 space-y-1">{children}</ol>
                    ),
                    blockquote: ({ children }) => (
                      <blockquote className="border-l-4 border-[var(--accent-primary)] pl-4 italic text-[var(--text-secondary)] my-4">
                        {children}
                      </blockquote>
                    ),
                  }}
                >
                  {lesson.content}
                </ReactMarkdown>
              </div>

              {/* 완료 버튼 */}
              <div className="mt-8 pt-6 border-t border-[var(--border-default)]">
                <button
                  onClick={() => router.back()}
                  className="w-full py-3 bg-[var(--accent-primary)] text-white font-medium rounded-lg hover:bg-[var(--accent-primary-hover)] transition-colors"
                >
                  완료하고 돌아가기
                </button>
              </div>
            </div>
          </div>
        )}
      </main>
    </div>
  );
}
