import { create } from "zustand";

const SOUND_ENABLED_KEY = "swiftboot-sound-enabled";

interface SoundState {
  soundEnabled: boolean;
  isInitialized: boolean;
}

interface SoundActions {
  initialize: () => void;
  toggleSound: () => void;
  setSoundEnabled: (enabled: boolean) => void;
}

type SoundStore = SoundState & SoundActions;

export const useSoundStore = create<SoundStore>((set) => ({
  soundEnabled: true,
  isInitialized: false,

  initialize: () => {
    if (typeof window === "undefined") return;
    const stored = localStorage.getItem(SOUND_ENABLED_KEY);
    const enabled = stored === null ? true : stored === "true";
    set({ soundEnabled: enabled, isInitialized: true });
  },

  toggleSound: () => {
    set((state) => {
      const newValue = !state.soundEnabled;
      if (typeof window !== "undefined") {
        localStorage.setItem(SOUND_ENABLED_KEY, String(newValue));
      }
      return { soundEnabled: newValue };
    });
  },

  setSoundEnabled: (enabled: boolean) => {
    if (typeof window !== "undefined") {
      localStorage.setItem(SOUND_ENABLED_KEY, String(enabled));
    }
    set({ soundEnabled: enabled });
  },
}));

// 편의 hook
export function useSound() {
  const soundEnabled = useSoundStore((state) => state.soundEnabled);
  const toggleSound = useSoundStore((state) => state.toggleSound);
  const initialize = useSoundStore((state) => state.initialize);
  const isInitialized = useSoundStore((state) => state.isInitialized);

  return { soundEnabled, toggleSound, initialize, isInitialized };
}
