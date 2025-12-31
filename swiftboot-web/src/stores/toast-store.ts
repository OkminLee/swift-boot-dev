import { create } from "zustand";

export type ToastType = "success" | "error" | "warning" | "info";

export interface Toast {
  id: string;
  type: ToastType;
  message: string;
  duration?: number;
}

interface ToastState {
  toasts: Toast[];
}

interface ToastActions {
  addToast: (toast: Omit<Toast, "id">) => void;
  removeToast: (id: string) => void;
  clearToasts: () => void;
}

type ToastStore = ToastState & ToastActions;

let toastId = 0;

export const useToastStore = create<ToastStore>((set) => ({
  toasts: [],

  addToast: (toast) => {
    const id = `toast-${++toastId}`;
    const duration = toast.duration ?? 4000;

    set((state) => ({
      toasts: [...state.toasts, { ...toast, id }],
    }));

    // 자동 제거
    if (duration > 0) {
      setTimeout(() => {
        set((state) => ({
          toasts: state.toasts.filter((t) => t.id !== id),
        }));
      }, duration);
    }
  },

  removeToast: (id) => {
    set((state) => ({
      toasts: state.toasts.filter((t) => t.id !== id),
    }));
  },

  clearToasts: () => {
    set({ toasts: [] });
  },
}));

// 편의 함수
export const toast = {
  success: (message: string, duration?: number) =>
    useToastStore.getState().addToast({ type: "success", message, duration }),
  error: (message: string, duration?: number) =>
    useToastStore.getState().addToast({ type: "error", message, duration }),
  warning: (message: string, duration?: number) =>
    useToastStore.getState().addToast({ type: "warning", message, duration }),
  info: (message: string, duration?: number) =>
    useToastStore.getState().addToast({ type: "info", message, duration }),
};
