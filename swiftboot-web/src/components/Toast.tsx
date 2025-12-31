"use client";

import { useState } from "react";
import { useToastStore, ToastType } from "@/stores/toast-store";

const toastStyles: Record<ToastType, { bg: string; border: string; icon: string }> = {
  success: {
    bg: "bg-[var(--accent-success)]/10",
    border: "border-[var(--accent-success)]",
    icon: "✓",
  },
  error: {
    bg: "bg-[var(--accent-error)]/10",
    border: "border-[var(--accent-error)]",
    icon: "✕",
  },
  warning: {
    bg: "bg-[var(--accent-warning)]/10",
    border: "border-[var(--accent-warning)]",
    icon: "⚠",
  },
  info: {
    bg: "bg-[var(--accent-info)]/10",
    border: "border-[var(--accent-info)]",
    icon: "ℹ",
  },
};

const toastColors: Record<ToastType, string> = {
  success: "var(--accent-success)",
  error: "var(--accent-error)",
  warning: "var(--accent-warning)",
  info: "var(--accent-info)",
};

interface ToastItemProps {
  id: string;
  type: ToastType;
  message: string;
  onRemove: (id: string) => void;
}

function ToastItem({ id, type, message, onRemove }: ToastItemProps) {
  const [isExiting, setIsExiting] = useState(false);
  const styles = toastStyles[type];

  const handleRemove = () => {
    setIsExiting(true);
    setTimeout(() => onRemove(id), 200);
  };

  return (
    <div
      className={`
        flex items-center gap-3 px-4 py-3 rounded-lg border shadow-lg
        ${styles.bg} ${styles.border}
        ${isExiting ? "animate-slideOut" : "animate-slideIn"}
      `}
      role="alert"
      aria-live="polite"
    >
      <span
        className="flex items-center justify-center w-5 h-5 rounded-full text-xs font-bold"
        style={{ backgroundColor: toastColors[type], color: "white" }}
        aria-hidden="true"
      >
        {styles.icon}
      </span>
      <span className="flex-1 text-sm text-[var(--text-primary)]">{message}</span>
      <button
        onClick={handleRemove}
        className="p-1 rounded hover:bg-[var(--bg-hover)] transition-colors"
        aria-label="알림 닫기"
      >
        <svg
          width="14"
          height="14"
          viewBox="0 0 24 24"
          fill="none"
          stroke="currentColor"
          strokeWidth="2"
          className="text-[var(--text-secondary)]"
          aria-hidden="true"
        >
          <line x1="18" y1="6" x2="6" y2="18" />
          <line x1="6" y1="6" x2="18" y2="18" />
        </svg>
      </button>
    </div>
  );
}

export function ToastContainer() {
  const { toasts, removeToast } = useToastStore();

  if (toasts.length === 0) return null;

  return (
    <div
      className="fixed bottom-4 right-4 z-[var(--z-toast)] flex flex-col gap-2 max-w-sm"
      aria-label="알림 목록"
    >
      {toasts.map((toast) => (
        <ToastItem
          key={toast.id}
          id={toast.id}
          type={toast.type}
          message={toast.message}
          onRemove={removeToast}
        />
      ))}
    </div>
  );
}
