"use client";

import { ReactNode } from "react";

interface WarningProps {
  children: ReactNode;
  title?: string;
}

export function Warning({ children, title = "주의" }: WarningProps) {
  return (
    <div className="my-4 border-l-4 border-[var(--accent-warning)] bg-[var(--accent-warning)]/10 rounded-r-lg overflow-hidden">
      <div className="px-4 py-3">
        <div className="flex items-center gap-2 mb-2">
          <span className="text-lg">⚠️</span>
          <span className="font-semibold text-[var(--accent-warning)]">{title}</span>
        </div>
        <div className="text-[var(--text-secondary)] pl-7">
          {children}
        </div>
      </div>
    </div>
  );
}
