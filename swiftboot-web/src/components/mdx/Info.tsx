"use client";

import { ReactNode } from "react";

interface InfoProps {
  children: ReactNode;
  title?: string;
}

export function Info({ children, title = "참고" }: InfoProps) {
  return (
    <div className="my-4 border-l-4 border-[var(--accent-primary)] bg-[var(--accent-primary)]/10 rounded-r-lg overflow-hidden">
      <div className="px-4 py-3">
        <div className="flex items-center gap-2 mb-2">
          <span className="text-lg">ℹ️</span>
          <span className="font-semibold text-[var(--accent-primary)]">{title}</span>
        </div>
        <div className="text-[var(--text-secondary)] pl-7">
          {children}
        </div>
      </div>
    </div>
  );
}
