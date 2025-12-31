import { create } from "zustand";

interface UIState {
  isSidebarOpen: boolean;
  isMobile: boolean;
}

interface UIActions {
  openSidebar: () => void;
  closeSidebar: () => void;
  toggleSidebar: () => void;
  setIsMobile: (isMobile: boolean) => void;
}

type UIStore = UIState & UIActions;

export const useUIStore = create<UIStore>((set) => ({
  isSidebarOpen: false,
  isMobile: false,

  openSidebar: () => set({ isSidebarOpen: true }),
  closeSidebar: () => set({ isSidebarOpen: false }),
  toggleSidebar: () => set((state) => ({ isSidebarOpen: !state.isSidebarOpen })),
  setIsMobile: (isMobile: boolean) => set({ isMobile, isSidebarOpen: false }),
}));
