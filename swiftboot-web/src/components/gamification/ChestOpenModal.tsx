"use client";

import { useEffect, useCallback, useState } from "react";
import confetti from "canvas-confetti";
import { ChestRarity as ApiChestRarity, ChestReward as ApiChestReward } from "@/lib/api";

export type ChestRarity = ApiChestRarity;

interface ChestRewardDisplay {
  type: "gems" | "xp" | "item";
  amount?: number;
  itemName?: string;
  icon: string;
}

interface ChestOpenModalProps {
  isOpen: boolean;
  rarity: ChestRarity;
  rewards?: ChestRewardDisplay[];
  apiReward?: ApiChestReward;
  onClose: () => void;
}

// 등급별 설정
const CHEST_CONFIG: Record<
  ChestRarity,
  {
    name: string;
    icon: string;
    colors: string[];
    cssVar: string;
    glowColor: string;
  }
> = {
  common: {
    name: "일반 상자",
    icon: "📦",
    colors: ["#8B7355", "#A0896C", "#6B5B4A", "#D4C4B0"],
    cssVar: "var(--chest-common)",
    glowColor: "rgba(139, 115, 85, 0.4)",
  },
  rare: {
    name: "희귀 상자",
    icon: "🎁",
    colors: ["#3B82F6", "#60A5FA", "#2563EB", "#93C5FD"],
    cssVar: "var(--chest-rare)",
    glowColor: "rgba(59, 130, 246, 0.4)",
  },
  epic: {
    name: "에픽 상자",
    icon: "💎",
    colors: ["#8B5CF6", "#A78BFA", "#7C3AED", "#C4B5FD"],
    cssVar: "var(--chest-epic)",
    glowColor: "rgba(139, 92, 246, 0.5)",
  },
  legendary: {
    name: "전설 상자",
    icon: "👑",
    colors: ["#F59E0B", "#FBBF24", "#D97706", "#FDE68A", "#FFD700"],
    cssVar: "var(--chest-legendary)",
    glowColor: "rgba(245, 158, 11, 0.5)",
  },
};

// 기본 보상 (MVP용 하드코딩)
const DEFAULT_REWARDS: Record<ChestRarity, ChestRewardDisplay[]> = {
  common: [
    { type: "gems", amount: 3, icon: "💎" },
    { type: "xp", amount: 20, icon: "⭐" },
  ],
  rare: [
    { type: "gems", amount: 10, icon: "💎" },
    { type: "xp", amount: 45, icon: "⭐" },
  ],
  epic: [
    { type: "gems", amount: 22, icon: "💎" },
    { type: "xp", amount: 90, icon: "⭐" },
    { type: "item", itemName: "Seer Stone", icon: "🔮" },
  ],
  legendary: [
    { type: "gems", amount: 65, icon: "💎" },
    { type: "xp", amount: 210, icon: "⭐" },
    { type: "item", itemName: "Seer Stone x2", icon: "🔮" },
  ],
};

export function ChestOpenModal({
  isOpen,
  rarity,
  rewards,
  apiReward,
  onClose,
}: ChestOpenModalProps) {
  const [phase, setPhase] = useState<"closed" | "opening" | "opened">("closed");
  const [showRewards, setShowRewards] = useState(false);

  const config = CHEST_CONFIG[rarity];

  // API 보상을 표시 형식으로 변환
  const convertApiReward = (reward: ApiChestReward): ChestRewardDisplay[] => {
    const result: ChestRewardDisplay[] = [];
    if (reward.gems > 0) {
      result.push({ type: "gems", amount: reward.gems, icon: "💎" });
    }
    if (reward.xp > 0) {
      result.push({ type: "xp", amount: reward.xp, icon: "⭐" });
    }
    for (const item of reward.items) {
      result.push({
        type: "item",
        itemName: item.quantity > 1 ? `${item.itemName} x${item.quantity}` : item.itemName,
        icon: "🔮",
      });
    }
    return result;
  };

  const actualRewards = apiReward
    ? convertApiReward(apiReward)
    : rewards || DEFAULT_REWARDS[rarity];

  // Confetti 효과
  const fireChestConfetti = useCallback(() => {
    const chestConfig = CHEST_CONFIG[rarity];
    const isHighTier = rarity === "legendary" || rarity === "epic";
    const duration = rarity === "legendary" ? 4000 : rarity === "epic" ? 3500 : rarity === "rare" ? 3000 : 2000;
    const end = Date.now() + duration;

    // 중앙 폭발
    confetti({
      particleCount: rarity === "legendary" ? 150 : rarity === "epic" ? 120 : rarity === "rare" ? 100 : 60,
      spread: isHighTier ? 120 : 90,
      origin: { x: 0.5, y: 0.5 },
      colors: chestConfig.colors,
      startVelocity: isHighTier ? 45 : 30,
    });

    // 연속 폭발 (rare 이상)
    if (rarity !== "common") {
      const frame = () => {
        confetti({
          particleCount: 3,
          angle: 60,
          spread: 60,
          origin: { x: 0, y: 0.7 },
          colors: chestConfig.colors,
        });
        confetti({
          particleCount: 3,
          angle: 120,
          spread: 60,
          origin: { x: 1, y: 0.7 },
          colors: chestConfig.colors,
        });

        if (Date.now() < end) {
          requestAnimationFrame(frame);
        }
      };
      frame();
    }

    // Legendary/Epic 추가 효과
    if (isHighTier) {
      setTimeout(() => {
        confetti({
          particleCount: 50,
          spread: 360,
          origin: { x: 0.5, y: 0.5 },
          colors: rarity === "legendary" ? ["#FFD700", "#FFA500"] : ["#8B5CF6", "#A78BFA"],
          startVelocity: 35,
          gravity: 0.5,
          shapes: ["star"],
          scalar: 1.2,
        });
      }, 500);
    }
  }, [rarity]);

  // 모달 열릴 때 애니메이션 시작
  useEffect(() => {
    if (isOpen) {
      setPhase("closed");
      setShowRewards(false);

      // 상자 흔들림 후 열기
      const openTimer = setTimeout(() => {
        setPhase("opening");
      }, 500);

      // 열린 후 confetti 및 보상 표시
      const rewardTimer = setTimeout(() => {
        setPhase("opened");
        fireChestConfetti();
        setShowRewards(true);
      }, 1200);

      return () => {
        clearTimeout(openTimer);
        clearTimeout(rewardTimer);
      };
    } else {
      setPhase("closed");
      setShowRewards(false);
    }
  }, [isOpen, fireChestConfetti]);

  // ESC 키로 닫기
  useEffect(() => {
    const handleEsc = (e: KeyboardEvent) => {
      if (e.key === "Escape" && phase === "opened") onClose();
    };
    if (isOpen) {
      window.addEventListener("keydown", handleEsc);
      return () => window.removeEventListener("keydown", handleEsc);
    }
  }, [isOpen, phase, onClose]);

  if (!isOpen) return null;

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center">
      {/* 배경 오버레이 */}
      <div
        className="absolute inset-0 bg-black/80 animate-fadeIn"
        onClick={phase === "opened" ? onClose : undefined}
      />

      {/* 등급별 글로우 */}
      <div
        className="absolute inset-0 animate-pulse"
        style={{
          background: `radial-gradient(circle at center, ${config.glowColor}, transparent 70%)`,
        }}
      />

      {/* 모달 컨테이너 */}
      <div
        className="relative flex flex-col items-center max-w-md w-full mx-4"
        onClick={(e) => e.stopPropagation()}
      >
        {/* 상자 */}
        <div
          className={`
            relative text-9xl transition-all duration-500
            ${phase === "closed" ? "animate-chestShake" : ""}
            ${phase === "opening" ? "animate-chestOpen" : ""}
            ${phase === "opened" ? "scale-75 opacity-50" : ""}
          `}
          style={{
            filter: phase !== "opened" ? `drop-shadow(0 0 30px ${config.glowColor})` : "none",
          }}
        >
          {phase === "opened" ? "📭" : "📦"}

          {/* 등급 표시 아이콘 */}
          <div
            className={`
              absolute -top-2 -right-2 text-3xl
              ${phase === "opened" ? "opacity-0" : "animate-float"}
            `}
          >
            {config.icon}
          </div>
        </div>

        {/* 등급 라벨 */}
        <div
          className={`
            mt-4 px-4 py-1 rounded-full text-sm font-bold uppercase tracking-wider
            transition-opacity duration-300
            ${phase === "opened" ? "opacity-0" : "opacity-100"}
          `}
          style={{
            background: config.cssVar,
            color: rarity === "common" ? "#FFF" : "#000",
          }}
        >
          {config.name}
        </div>

        {/* 보상 카드 */}
        {showRewards && (
          <div
            className="mt-8 bg-[var(--bg-elevated)] rounded-2xl p-6 w-full border animate-slideUp"
            style={{ borderColor: config.cssVar }}
          >
            <h3
              className="text-center text-xl font-bold mb-4"
              style={{ color: config.cssVar }}
            >
              🎉 보상 획득!
            </h3>

            <div className="space-y-3">
              {actualRewards.map((reward, index) => (
                <div
                  key={index}
                  className="flex items-center justify-between bg-[var(--bg-secondary)] rounded-xl p-4 animate-slideUp"
                  style={{ animationDelay: `${index * 100}ms` }}
                >
                  <div className="flex items-center gap-3">
                    <span className="text-3xl">{reward.icon}</span>
                    <span className="text-[var(--text-primary)] font-medium">
                      {reward.type === "item"
                        ? reward.itemName
                        : reward.type === "gems"
                        ? "Gems"
                        : "XP"}
                    </span>
                  </div>
                  {reward.amount && (
                    <span
                      className="text-xl font-bold"
                      style={{
                        color:
                          reward.type === "gems"
                            ? "var(--gem-purple)"
                            : reward.type === "xp"
                            ? "var(--xp-gold)"
                            : "var(--text-primary)",
                      }}
                    >
                      +{reward.amount}
                    </span>
                  )}
                </div>
              ))}
            </div>

            {/* 닫기 버튼 */}
            <button
              onClick={onClose}
              className="w-full mt-6 py-3 font-bold rounded-xl transition-opacity hover:opacity-90"
              style={{
                background: `linear-gradient(135deg, ${config.colors[0]}, ${config.colors[2]})`,
                color: rarity === "common" ? "#FFF" : "#000",
              }}
            >
              확인
            </button>
          </div>
        )}

        {/* 열기 전 안내 */}
        {!showRewards && (
          <p className="mt-8 text-[var(--text-secondary)] animate-pulse">
            상자를 여는 중...
          </p>
        )}
      </div>
    </div>
  );
}
