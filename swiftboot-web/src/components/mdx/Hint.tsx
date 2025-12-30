"use client";

import { useState, ReactNode } from "react";

interface HintProps {
  children: ReactNode;
  title?: string;
}

export function Hint({ children, title = "힌트" }: HintProps) {
  const [isOpen, setIsOpen] = useState(false);

  return (
    <div className="my-4 border border-[var(--accent-primary)]/30 rounded-lg overflow-hidden">
      <button
        onClick={() => setIsOpen(!isOpen)}
        className="w-full px-4 py-3 bg-[var(--accent-primary)]/10 flex items-center justify-between text-left hover:bg-[var(--accent-primary)]/15 transition-colors"
      >
        <div className="flex items-center gap-2">
          <span className="text-lg">💡</span>
          <span className="font-medium text-[var(--accent-primary)]">{title}</span>
        </div>
        <svg
          className={`w-5 h-5 text-[var(--accent-primary)] transition-transform ${isOpen ? "rotate-180" : ""}`}
          fill="none"
          stroke="currentColor"
          viewBox="0 0 24 24"
        >
          <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M19 9l-7 7-7-7" />
        </svg>
      </button>
      <div
        className={`overflow-hidden transition-all duration-300 ${
          isOpen ? "max-h-[1000px] opacity-100" : "max-h-0 opacity-0"
        }`}
      >
        <div className="px-4 py-3 text-[var(--text-secondary)] border-t border-[var(--accent-primary)]/20">
          {children}
        </div>
      </div>
    </div>
  );
}
