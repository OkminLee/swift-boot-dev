const API_URL = process.env.NEXT_PUBLIC_API_URL || "http://localhost:8080/api/v1";

export interface TokenResponse {
  accessToken: string;
  refreshToken: string;
  expiresIn: number;
  tokenType: string;
}

export interface User {
  id: string;
  username: string;
  email: string;
  avatarUrl: string | null;
  level: number;
  totalXp: number;
  gems: number;
  streakDays: number;
}

export interface ApiError {
  error: boolean;
  reason: string;
}

// Learning types
export type LessonType = "reading" | "multipleChoice" | "codeExercise" | "codeOutput";
export type Language = "swift" | "python" | "go" | "javascript";

export interface Track {
  id: string;
  title: string;
  description: string;
  icon: string | null;
}

export interface Course {
  id: string;
  title: string;
  description: string;
  icon: string | null;
  difficulty: "beginner" | "intermediate" | "advanced";
}

export interface CourseDetail extends Course {
  chapters: Chapter[];
}

export interface Chapter {
  id: string;
  title: string;
  description: string | null;
  lessons: LessonSummary[];
}

export interface LessonSummary {
  id: string;
  title: string;
  type: LessonType;
  xpReward: number;
}

export interface Lesson {
  id: string;
  title: string;
  content: string;
  type: LessonType;
  language: Language | null;
  starterCode: string | null;
  xpReward: number;
  courseId: string;
  chapterId: string;
  previousLessonId: string | null;
  nextLessonId: string | null;
}

export interface SubmissionResponse {
  lessonId: string;
  status: "pending" | "running" | "success" | "failure" | "error";
  message: string;
  output?: string;
  isCorrect?: boolean;
  xpEarned?: number;
}

// Progress types
export type ProgressStatus = "notStarted" | "inProgress" | "completed";

export interface ProgressResponse {
  lessonId: string;
  status: ProgressStatus;
  completedAt: string | null;
  xpEarned: number;
}

export interface UserStats {
  level: number;
  totalXp: number;
  xpToNextLevel: number;
  levelProgress: number;
  gems: number;
  streakDays: number;
  completedLessons: number;
  totalLessons: number;
}

export interface CourseProgress {
  courseId: string;
  completedLessons: number;
  totalLessons: number;
}

class ApiClient {
  private baseUrl: string;

  constructor(baseUrl: string) {
    this.baseUrl = baseUrl;
  }

  private getAccessToken(): string | null {
    if (typeof window === "undefined") return null;
    return localStorage.getItem("accessToken");
  }

  private getRefreshToken(): string | null {
    if (typeof window === "undefined") return null;
    return localStorage.getItem("refreshToken");
  }

  private setTokens(accessToken: string, refreshToken: string) {
    localStorage.setItem("accessToken", accessToken);
    localStorage.setItem("refreshToken", refreshToken);
  }

  clearTokens() {
    localStorage.removeItem("accessToken");
    localStorage.removeItem("refreshToken");
  }

  private async request<T>(
    endpoint: string,
    options: RequestInit = {}
  ): Promise<T> {
    const accessToken = this.getAccessToken();

    const headers: HeadersInit = {
      "Content-Type": "application/json",
      ...options.headers,
    };

    if (accessToken) {
      (headers as Record<string, string>)["Authorization"] = `Bearer ${accessToken}`;
    }

    const response = await fetch(`${this.baseUrl}${endpoint}`, {
      ...options,
      headers,
    });

    // 401 에러 시 토큰 갱신 시도
    if (response.status === 401 && this.getRefreshToken()) {
      const refreshed = await this.refreshAccessToken();
      if (refreshed) {
        // 새 토큰으로 재시도
        const newAccessToken = this.getAccessToken();
        (headers as Record<string, string>)["Authorization"] = `Bearer ${newAccessToken}`;

        const retryResponse = await fetch(`${this.baseUrl}${endpoint}`, {
          ...options,
          headers,
        });

        if (!retryResponse.ok) {
          throw await retryResponse.json();
        }
        return retryResponse.json();
      } else {
        // 갱신 실패 시 로그아웃
        this.clearTokens();
        throw { error: true, reason: "Session expired" };
      }
    }

    if (!response.ok) {
      throw await response.json();
    }

    return response.json();
  }

  private async refreshAccessToken(): Promise<boolean> {
    const refreshToken = this.getRefreshToken();
    if (!refreshToken) return false;

    try {
      const response = await fetch(`${this.baseUrl}/auth/refresh`, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ refreshToken }),
      });

      if (!response.ok) return false;

      const data: TokenResponse = await response.json();
      this.setTokens(data.accessToken, data.refreshToken);
      return true;
    } catch {
      return false;
    }
  }

  // Auth
  async githubCallback(code: string): Promise<TokenResponse> {
    const data = await this.request<TokenResponse>("/auth/github/callback", {
      method: "POST",
      body: JSON.stringify({ code }),
    });
    this.setTokens(data.accessToken, data.refreshToken);
    return data;
  }

  async logout(): Promise<void> {
    const refreshToken = this.getRefreshToken();
    if (refreshToken) {
      try {
        await this.request("/auth/logout", {
          method: "POST",
          body: JSON.stringify({ refreshToken }),
        });
      } catch {
        // 로그아웃 API 실패해도 로컬 토큰은 삭제
      }
    }
    this.clearTokens();
  }

  // User
  async getCurrentUser(): Promise<User> {
    return this.request<User>("/users/me");
  }

  async getUserStats(): Promise<UserStats> {
    return this.request<UserStats>("/users/me/stats");
  }

  async getUserProgress(): Promise<ProgressResponse[]> {
    return this.request<ProgressResponse[]>("/users/me/progress");
  }

  async getCourseProgress(): Promise<CourseProgress[]> {
    return this.request<CourseProgress[]>("/users/me/progress/courses");
  }

  // 인증 상태 확인
  isAuthenticated(): boolean {
    return !!this.getAccessToken();
  }

  // Learning - Tracks
  async getTracks(): Promise<Track[]> {
    return this.request<Track[]>("/tracks");
  }

  async getTrack(trackId: string): Promise<Track & { courses: Course[] }> {
    return this.request<Track & { courses: Course[] }>(`/tracks/${trackId}`);
  }

  // Learning - Courses
  async getCourses(): Promise<Course[]> {
    return this.request<Course[]>("/courses");
  }

  async getCourse(courseId: string): Promise<CourseDetail> {
    return this.request<CourseDetail>(`/courses/${courseId}`);
  }

  // Learning - Lessons
  async getLesson(lessonId: string): Promise<Lesson> {
    return this.request<Lesson>(`/lessons/${lessonId}`);
  }

  async submitCode(lessonId: string, code: string, language: Language): Promise<SubmissionResponse> {
    return this.request<SubmissionResponse>(`/lessons/${lessonId}/submit`, {
      method: "POST",
      body: JSON.stringify({ code, language }),
    });
  }
}

export const api = new ApiClient(API_URL);
