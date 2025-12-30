"use client";

import { useEffect, useCallback } from "react";
import confetti from "canvas-confetti";

interface LevelUpModalProps {
  isOpen: boolean;
  newLevel: number;
  onClose: () => void;
}

export function LevelUpModal({ isOpen, newLevel, onClose }: LevelUpModalProps) {
  // 레벨업 confetti 효과
  const fireLevelUpConfetti = useCallback(() => {
    const duration = 3000;
    const end = Date.now() + duration;

    // 황금색 confetti 폭발
    const frame = () => {
      confetti({
        particleCount: 5,
        angle: 60,
        spread: 80,
        origin: { x: 0, y: 0.6 },
        colors: ["#FFD700", "#FFA500", "#FF6B35", "#FFEA00"],
      });
      confetti({
        particleCount: 5,
        angle: 120,
        spread: 80,
        origin: { x: 1, y: 0.6 },
        colors: ["#FFD700", "#FFA500", "#FF6B35", "#FFEA00"],
      });

      if (Date.now() < end) {
        requestAnimationFrame(frame);
      }
    };

    // 중앙 폭발
    confetti({
      particleCount: 100,
      spread: 100,
      origin: { x: 0.5, y: 0.5 },
      colors: ["#FFD700", "#FFA500", "#FF6B35", "#FFEA00", "#34C759"],
    });

    frame();
  }, []);

  useEffect(() => {
    if (isOpen) {
      fireLevelUpConfetti();
    }
  }, [isOpen, fireLevelUpConfetti]);

  // ESC 키로 닫기
  useEffect(() => {
    const handleEsc = (e: KeyboardEvent) => {
      if (e.key === "Escape") onClose();
    };
    if (isOpen) {
      window.addEventListener("keydown", handleEsc);
      return () => window.removeEventListener("keydown", handleEsc);
    }
  }, [isOpen, onClose]);

  if (!isOpen) return null;

  return (
    <div
      className="fixed inset-0 z-50 flex items-center justify-center"
      onClick={onClose}
    >
      {/* 배경 오버레이 */}
      <div className="absolute inset-0 bg-black/70 animate-fadeIn" />

      {/* 황금빛 글로우 */}
      <div className="absolute inset-0 bg-gradient-radial from-[var(--xp-gold)]/20 via-transparent to-transparent animate-pulse" />

      {/* 모달 */}
      <div
        className="relative bg-gradient-to-b from-[var(--bg-elevated)] to-[var(--bg-secondary)] rounded-2xl p-8 max-w-sm w-full mx-4 border border-[var(--xp-gold)]/50 shadow-2xl animate-scaleIn"
        onClick={(e) => e.stopPropagation()}
      >
        {/* 레벨 뱃지 */}
        <div className="flex justify-center -mt-16 mb-4">
          <div className="relative">
            {/* 글로우 효과 */}
            <div className="absolute inset-0 bg-[var(--xp-gold)] rounded-full blur-xl opacity-50 animate-pulse" />

            {/* 레벨 서클 */}
            <div className="relative w-24 h-24 bg-gradient-to-br from-[var(--xp-gold)] to-[var(--streak-orange)] rounded-full flex items-center justify-center border-4 border-white/20 shadow-lg animate-bounce">
              <div className="text-center">
                <div className="text-3xl font-bold text-white">{newLevel}</div>
                <div className="text-xs text-white/80 uppercase tracking-wider">Level</div>
              </div>
            </div>

            {/* 별 장식 */}
            <div className="absolute -top-2 -right-2 text-2xl animate-float">⭐</div>
            <div className="absolute -bottom-1 -left-2 text-xl animate-float" style={{ animationDelay: "0.5s" }}>✨</div>
          </div>
        </div>

        {/* 텍스트 */}
        <div className="text-center space-y-2">
          <h2 className="text-2xl font-bold text-[var(--xp-gold)] animate-glow">
            LEVEL UP!
          </h2>
          <p className="text-lg text-[var(--text-primary)]">
            레벨 <span className="font-bold text-[var(--xp-gold)]">{newLevel}</span> 달성!
          </p>
          <p className="text-sm text-[var(--text-secondary)]">
            꾸준한 학습으로 성장하고 있어요
          </p>
        </div>

        {/* 닫기 버튼 */}
        <button
          onClick={onClose}
          className="w-full mt-6 py-3 bg-gradient-to-r from-[var(--xp-gold)] to-[var(--streak-orange)] text-white font-bold rounded-xl hover:opacity-90 transition-opacity"
        >
          계속하기
        </button>
      </div>
    </div>
  );
}
