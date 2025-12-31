"use client";

import { ReactNode, useEffect } from "react";
import { useAuthStore } from "@/stores/auth-store";
import { ToastContainer } from "@/components/Toast";

function AuthInitializer({ children }: { children: ReactNode }) {
  const initialize = useAuthStore((state) => state.initialize);

  useEffect(() => {
    initialize();
  }, [initialize]);

  return <>{children}</>;
}

export function Providers({ children }: { children: ReactNode }) {
  return (
    <AuthInitializer>
      {children}
      <ToastContainer />
    </AuthInitializer>
  );
}
