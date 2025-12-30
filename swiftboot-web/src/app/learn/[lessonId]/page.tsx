"use client";

import { useState, useEffect, useCallback, useRef } from "react";
import { useParams, useRouter } from "next/navigation";
import { api, Lesson, SubmissionResponse, Language, InventoryItem, SeerStoneResponse } from "@/lib/api";
import { CodeEditor, OutputViewer } from "@/components/CodeEditor";
import { LevelUpModal } from "@/components/gamification/LevelUpModal";
import { useAuthStore } from "@/stores/auth-store";
import { playSuccess, playError } from "@/lib/sounds";
import ReactMarkdown from "react-markdown";
import remarkGfm from "remark-gfm";
import { Prism as SyntaxHighlighter } from "react-syntax-highlighter";
import { vscDarkPlus } from "react-syntax-highlighter/dist/esm/styles/prism";
import confetti from "canvas-confetti";

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
  const [isShaking, setIsShaking] = useState(false);
  const [saveStatus, setSaveStatus] = useState<"saved" | "saving" | "idle">("idle");
  const resultRef = useRef<SubmissionResponse | null>(null);
  const saveTimeoutRef = useRef<NodeJS.Timeout | null>(null);

  // Seer Stone 관련 상태
  const [seerStoneCount, setSeerStoneCount] = useState(0);
  const [showSolution, setShowSolution] = useState(false);
  const [solutionCode, setSolutionCode] = useState<string | null>(null);
  const [isUsingSeerStone, setIsUsingSeerStone] = useState(false);

  // localStorage 키
  const storageKey = `swiftboot-code-${lessonId}`;

  // 정답 시 Confetti 효과
  const fireConfetti = useCallback(() => {
    const duration = 2000;
    const end = Date.now() + duration;

    const frame = () => {
      confetti({
        particleCount: 3,
        angle: 60,
        spread: 55,
        origin: { x: 0, y: 0.7 },
        colors: ["#FFD700", "#34C759", "#007AFF"],
      });
      confetti({
        particleCount: 3,
        angle: 120,
        spread: 55,
        origin: { x: 1, y: 0.7 },
        colors: ["#FFD700", "#34C759", "#007AFF"],
      });

      if (Date.now() < end) {
        requestAnimationFrame(frame);
      }
    };
    frame();
  }, []);

  // 사용자 정보 및 레벨업 관련
  const refreshUser = useAuthStore((state) => state.refreshUser);
  const levelUpInfo = useAuthStore((state) => state.levelUpInfo);
  const clearLevelUp = useAuthStore((state) => state.clearLevelUp);

  // 결과에 따른 효과 발동
  useEffect(() => {
    if (!result || result === resultRef.current) return;
    resultRef.current = result;

    if (result.status === "success" && result.isCorrect) {
      fireConfetti();
      playSuccess();
      // XP 획득 시 사용자 정보 새로고침
      refreshUser();
    } else if (result.status === "failure") {
      setIsShaking(true);
      playError();
      setTimeout(() => setIsShaking(false), 500);
    }
  }, [result, fireConfetti, refreshUser]);

  // 레슨 데이터 로드 + 저장된 코드 복원
  useEffect(() => {
    async function loadLesson() {
      try {
        const data = await api.getLesson(lessonId);
        setLesson(data);

        // localStorage에서 저장된 코드 확인
        const savedCode = localStorage.getItem(storageKey);
        if (savedCode !== null) {
          setCode(savedCode);
          setSaveStatus("saved");
        } else {
          setCode(data.starterCode || "");
        }
      } catch (err) {
        setError("레슨을 불러오는데 실패했습니다.");
        console.error(err);
      } finally {
        setIsLoading(false);
      }
    }
    loadLesson();
    loadSeerStoneCount();
  }, [lessonId, storageKey]);

  // Seer Stone 보유 수량 로드
  const loadSeerStoneCount = async () => {
    try {
      const inventory = await api.getInventory();
      const seerStone = inventory.find((item) => item.item.itemType === "seerStone");
      setSeerStoneCount(seerStone?.quantity || 0);
    } catch (error) {
      console.error("Failed to load inventory:", error);
    }
  };

  // Seer Stone 사용
  const handleUseSeerStone = async () => {
    if (seerStoneCount <= 0 || isUsingSeerStone) return;

    setIsUsingSeerStone(true);
    try {
      const response = await api.useSeerStone(lessonId);
      if (response.success && response.solutionCode) {
        setSolutionCode(response.solutionCode);
        setShowSolution(true);
        setSeerStoneCount(response.remainingQuantity);
      } else {
        alert(response.message);
      }
    } catch (error) {
      console.error("Failed to use Seer Stone:", error);
      alert("Seer Stone 사용 중 오류가 발생했습니다.");
    } finally {
      setIsUsingSeerStone(false);
    }
  };

  // 코드 변경 시 자동 저장 (debounce 1초)
  const handleCodeChange = useCallback((newCode: string) => {
    setCode(newCode);
    setSaveStatus("saving");

    // 이전 타이머 취소
    if (saveTimeoutRef.current) {
      clearTimeout(saveTimeoutRef.current);
    }

    // 1초 후 저장
    saveTimeoutRef.current = setTimeout(() => {
      localStorage.setItem(storageKey, newCode);
      setSaveStatus("saved");
    }, 1000);
  }, [storageKey]);

  // 컴포넌트 언마운트 시 타이머 정리 및 즉시 저장
  useEffect(() => {
    return () => {
      if (saveTimeoutRef.current) {
        clearTimeout(saveTimeoutRef.current);
      }
    };
  }, []);

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

  // 코드 초기화 (저장된 코드도 삭제)
  const handleReset = useCallback(() => {
    if (lesson) {
      setCode(lesson.starterCode || "");
      setResult(null);
      localStorage.removeItem(storageKey);
      setSaveStatus("idle");
    }
  }, [lesson, storageKey]);

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
              {/* Seer Stone 버튼 */}
              {seerStoneCount > 0 && !showSolution && (
                <button
                  onClick={handleUseSeerStone}
                  disabled={isUsingSeerStone}
                  className="px-3 py-2 text-sm bg-[var(--gem-purple)]/10 text-[var(--gem-purple)] hover:bg-[var(--gem-purple)]/20 rounded-lg transition-colors flex items-center gap-2 disabled:opacity-50"
                  title={`Seer Stone ${seerStoneCount}개 보유`}
                >
                  {isUsingSeerStone ? (
                    <div className="animate-spin w-4 h-4 border-2 border-[var(--gem-purple)] border-t-transparent rounded-full" />
                  ) : (
                    <span>🔮</span>
                  )}
                  <span>정답 보기</span>
                  <span className="text-xs opacity-70">({seerStoneCount})</span>
                </button>
              )}
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
                    code: ({ className, children }) => {
                      const match = /language-(\w+)/.exec(className || "");
                      const isInline = !match;
                      if (isInline) {
                        return (
                          <code className="px-1.5 py-0.5 bg-[var(--bg-tertiary)] text-[var(--accent-primary)] rounded text-sm font-mono">
                            {children}
                          </code>
                        );
                      }
                      return (
                        <SyntaxHighlighter
                          style={vscDarkPlus}
                          language={match[1]}
                          PreTag="div"
                          customStyle={{
                            margin: 0,
                            borderRadius: "8px",
                            fontSize: "14px",
                          }}
                        >
                          {String(children).replace(/\n$/, "")}
                        </SyntaxHighlighter>
                      );
                    },
                    pre: ({ children }) => (
                      <div className="mb-4">{children}</div>
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
            <div className={`space-y-4 transition-transform ${isShaking ? "animate-shake" : ""}`}>
              {/* Seer Stone 정답 표시 */}
              {showSolution && solutionCode && (
                <div className="bg-[var(--gem-purple)]/10 border border-[var(--gem-purple)] rounded-lg p-4 animate-slideUp">
                  <div className="flex items-center justify-between mb-3">
                    <div className="flex items-center gap-2">
                      <span className="text-xl">🔮</span>
                      <span className="font-medium text-[var(--gem-purple)]">정답 코드</span>
                    </div>
                    <button
                      onClick={() => setShowSolution(false)}
                      className="text-[var(--text-muted)] hover:text-[var(--text-primary)]"
                    >
                      <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M6 18L18 6M6 6l12 12" />
                      </svg>
                    </button>
                  </div>
                  <div className="bg-[var(--bg-primary)] rounded-lg overflow-hidden">
                    <SyntaxHighlighter
                      style={vscDarkPlus}
                      language={lesson.language || "swift"}
                      customStyle={{
                        margin: 0,
                        padding: "1rem",
                        fontSize: "14px",
                        background: "transparent",
                      }}
                    >
                      {solutionCode}
                    </SyntaxHighlighter>
                  </div>
                  <p className="text-xs text-[var(--text-muted)] mt-2">
                    * 정답을 참고하여 직접 입력해보세요!
                  </p>
                </div>
              )}

              {/* 에디터 헤더: 저장 상태 표시 */}
              <div className="flex items-center justify-between px-1">
                <span className="text-xs text-[var(--text-muted)] font-mono">
                  {lesson.language || "swift"}
                </span>
                <span className="text-xs text-[var(--text-muted)] flex items-center gap-1">
                  {saveStatus === "saving" && (
                    <>
                      <div className="w-2 h-2 bg-[var(--accent-warning)] rounded-full animate-pulse" />
                      저장 중...
                    </>
                  )}
                  {saveStatus === "saved" && (
                    <>
                      <div className="w-2 h-2 bg-[var(--success-green)] rounded-full" />
                      저장됨
                    </>
                  )}
                </span>
              </div>
              <CodeEditor
                language={lesson.language || "swift"}
                value={code}
                onChange={handleCodeChange}
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
                    <div className="space-y-3 animate-slideUp">
                      <div className="flex items-center gap-3 p-4 bg-[var(--success-green)]/10 border border-[var(--success-green)] rounded-lg">
                        <div className="w-12 h-12 bg-[var(--success-green)] rounded-full flex items-center justify-center animate-bounce">
                          <svg className="w-7 h-7 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2.5} d="M5 13l4 4L19 7" />
                          </svg>
                        </div>
                        <div className="flex-1">
                          <p className="font-bold text-lg text-[var(--success-green)]">정답입니다!</p>
                          <p className="text-sm text-[var(--text-secondary)]">
                            +{result.xpEarned || lesson.xpReward} XP 획득
                          </p>
                        </div>
                        <div className="text-3xl animate-float">🎉</div>
                      </div>

                      {/* 다음 레슨 버튼 */}
                      <div className="flex gap-2">
                        {lesson.previousLessonId && (
                          <button
                            onClick={() => router.push(`/learn/${lesson.previousLessonId}`)}
                            className="flex-1 py-3 px-4 bg-[var(--bg-tertiary)] text-[var(--text-secondary)] rounded-lg hover:bg-[var(--bg-hover)] transition-colors flex items-center justify-center gap-2"
                          >
                            <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M15 19l-7-7 7-7" />
                            </svg>
                            이전 레슨
                          </button>
                        )}
                        {lesson.nextLessonId ? (
                          <button
                            onClick={() => router.push(`/learn/${lesson.nextLessonId}`)}
                            className="flex-1 py-3 px-4 bg-[var(--accent-primary)] text-white font-medium rounded-lg hover:bg-[var(--accent-primary-hover)] transition-colors flex items-center justify-center gap-2"
                          >
                            다음 레슨
                            <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 5l7 7-7 7" />
                            </svg>
                          </button>
                        ) : (
                          <button
                            onClick={() => router.push(`/courses/${lesson.courseId}`)}
                            className="flex-1 py-3 px-4 bg-[var(--xp-gold)] text-[var(--text-inverse)] font-medium rounded-lg hover:opacity-90 transition-opacity flex items-center justify-center gap-2"
                          >
                            🎊 코스 완료!
                          </button>
                        )}
                      </div>
                    </div>
                  )}

                  {result.status === "failure" && (
                    <div className="flex items-center gap-3 p-4 bg-[var(--error-red)]/10 border border-[var(--error-red)] rounded-lg animate-slideUp">
                      <div className="w-10 h-10 bg-[var(--error-red)] rounded-full flex items-center justify-center">
                        <svg className="w-6 h-6 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                          <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M6 18L18 6M6 6l12 12" />
                        </svg>
                      </div>
                      <div className="flex-1">
                        <p className="font-semibold text-[var(--error-red)]">다시 시도해보세요</p>
                        <p className="text-sm text-[var(--text-secondary)]">{result.message}</p>
                      </div>
                      <div className="text-2xl">💪</div>
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
                    code: ({ className, children }) => {
                      const match = /language-(\w+)/.exec(className || "");
                      const isInline = !match;
                      if (isInline) {
                        return (
                          <code className="px-1.5 py-0.5 bg-[var(--bg-tertiary)] text-[var(--accent-primary)] rounded text-sm font-mono">
                            {children}
                          </code>
                        );
                      }
                      return (
                        <SyntaxHighlighter
                          style={vscDarkPlus}
                          language={match[1]}
                          PreTag="div"
                          customStyle={{
                            margin: 0,
                            borderRadius: "8px",
                            fontSize: "14px",
                          }}
                        >
                          {String(children).replace(/\n$/, "")}
                        </SyntaxHighlighter>
                      );
                    },
                    pre: ({ children }) => (
                      <div className="mb-4">{children}</div>
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

      {/* 레벨업 모달 */}
      <LevelUpModal
        isOpen={!!levelUpInfo}
        newLevel={levelUpInfo?.newLevel ?? 0}
        onClose={clearLevelUp}
      />
    </div>
  );
}
