import { create } from "zustand";
import { api, User, UserStats } from "@/lib/api";

interface AuthState {
  user: User | null;
  stats: UserStats | null;
  isLoading: boolean;
  isInitialized: boolean;
  levelUpInfo: { newLevel: number } | null;
}

interface AuthActions {
  login: (code: string) => Promise<void>;
  logout: () => Promise<void>;
  refreshUser: () => Promise<void>;
  initialize: () => Promise<void>;
  clearLevelUp: () => void;
}

type AuthStore = AuthState & AuthActions;

export const useAuthStore = create<AuthStore>((set, get) => ({
  // State
  user: null,
  stats: null,
  isLoading: false,
  isInitialized: false,
  levelUpInfo: null,

  // Actions
  initialize: async () => {
    if (get().isInitialized) return;

    set({ isLoading: true });
    try {
      if (api.isAuthenticated()) {
        await get().refreshUser();
      }
    } finally {
      set({ isLoading: false, isInitialized: true });
    }
  },

  refreshUser: async () => {
    const previousLevel = get().user?.level ?? 0;

    try {
      const [userData, userStats] = await Promise.all([
        api.getCurrentUser(),
        api.getUserStats().catch(() => null),
      ]);

      // 레벨업 감지
      const newLevel = userData.level;
      if (previousLevel > 0 && newLevel > previousLevel) {
        set({ user: userData, stats: userStats, levelUpInfo: { newLevel } });
      } else {
        set({ user: userData, stats: userStats });
      }
    } catch {
      set({ user: null, stats: null });
      api.clearTokens();
    }
  },

  login: async (code: string) => {
    set({ isLoading: true });
    try {
      await api.githubCallback(code);
      await get().refreshUser();
    } finally {
      set({ isLoading: false });
    }
  },

  logout: async () => {
    set({ isLoading: true });
    try {
      await api.logout();
      set({ user: null, stats: null, levelUpInfo: null });
    } finally {
      set({ isLoading: false });
    }
  },

  clearLevelUp: () => {
    set({ levelUpInfo: null });
  },
}));

// 기존 useAuth hook과 호환되는 selector hook
export function useAuth() {
  const user = useAuthStore((state) => state.user);
  const stats = useAuthStore((state) => state.stats);
  const isLoading = useAuthStore((state) => state.isLoading);
  const isInitialized = useAuthStore((state) => state.isInitialized);
  const levelUpInfo = useAuthStore((state) => state.levelUpInfo);
  const login = useAuthStore((state) => state.login);
  const logout = useAuthStore((state) => state.logout);
  const refreshUser = useAuthStore((state) => state.refreshUser);
  const clearLevelUp = useAuthStore((state) => state.clearLevelUp);

  return {
    user,
    stats,
    isLoading,
    isAuthenticated: !!user,
    isInitialized,
    levelUpInfo,
    login,
    logout,
    refreshUser,
    clearLevelUp,
  };
}
