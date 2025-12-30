"use client";

import { useEffect, useState, useCallback } from "react";
import Link from "next/link";
import { api, InventoryItem, UserChest, ChestOpenResponse, ChestRarity } from "@/lib/api";
import { ChestOpenModal } from "@/components/gamification/ChestOpenModal";
import { useAuth } from "@/stores/auth-store";

// 등급별 아이콘 매핑
const RARITY_ICONS: Record<ChestRarity, { badge: string; color: string }> = {
  common: { badge: "", color: "var(--chest-common)" },
  rare: { badge: "💎", color: "var(--chest-rare)" },
  epic: { badge: "✨", color: "var(--chest-epic)" },
  legendary: { badge: "👑", color: "var(--chest-legendary)" },
};

const RARITY_NAMES: Record<ChestRarity, string> = {
  common: "일반",
  rare: "희귀",
  epic: "에픽",
  legendary: "전설",
};

export default function InventoryPage() {
  const { refreshUser } = useAuth();
  const [inventory, setInventory] = useState<InventoryItem[]>([]);
  const [unopenedChests, setUnopenedChests] = useState<UserChest[]>([]);
  const [isLoading, setIsLoading] = useState(true);

  // Chest 모달 상태
  const [chestModalOpen, setChestModalOpen] = useState(false);
  const [selectedChest, setSelectedChest] = useState<UserChest | null>(null);
  const [chestOpenResult, setChestOpenResult] = useState<ChestOpenResponse | null>(null);
  const [isOpening, setIsOpening] = useState(false);

  const loadData = useCallback(async () => {
    try {
      const [items, chests] = await Promise.all([
        api.getInventory(),
        api.getUnopenedChests(),
      ]);
      setInventory(items);
      setUnopenedChests(chests);
    } catch (error) {
      console.error("Failed to load inventory:", error);
    } finally {
      setIsLoading(false);
    }
  }, []);

  useEffect(() => {
    loadData();
  }, [loadData]);

  const handleOpenChest = async (chest: UserChest) => {
    if (isOpening) return;

    setSelectedChest(chest);
    setIsOpening(true);

    try {
      // API 호출 완료 후 모달 열기 (실제 보상 표시를 위해)
      const result = await api.openChest(chest.id);
      setChestOpenResult(result);
      setChestModalOpen(true);
    } catch (error) {
      console.error("Failed to open chest:", error);
      setSelectedChest(null);
      // 에러 발생 시 사용자에게 알림
      alert("상자를 여는 데 실패했습니다. 다시 시도해주세요.");
    } finally {
      setIsOpening(false);
    }
  };

  const handleCloseModal = async () => {
    setChestModalOpen(false);
    setSelectedChest(null);
    setChestOpenResult(null);

    // 사용자 정보 갱신 (XP, Gems, 레벨업 반영)
    await refreshUser();
    // 목록 새로고침 (개봉된 chest 제거)
    await loadData();
  };

  if (isLoading) {
    return (
      <div className="min-h-screen flex items-center justify-center">
        <div className="animate-spin w-8 h-8 border-4 border-[var(--accent-primary)] border-t-transparent rounded-full" />
      </div>
    );
  }

  return (
    <div className="p-8">
      {/* Header */}
      <div className="mb-8">
        <h1 className="text-2xl font-bold text-[var(--text-primary)]">
          인벤토리
        </h1>
        <p className="text-[var(--text-secondary)] mt-1">
          보유한 아이템과 상자를 확인하세요
        </p>
      </div>

      {/* Unopened Chests Section */}
      <div className="mb-8 p-6 bg-gradient-to-r from-[var(--bg-secondary)] to-[var(--bg-elevated)] rounded-xl border border-[var(--border-default)]">
        <div className="flex items-center gap-2 mb-4">
          <span className="text-2xl">📦</span>
          <h2 className="text-lg font-semibold text-[var(--text-primary)]">
            미개봉 상자
          </h2>
          {unopenedChests.length > 0 && (
            <span className="px-2 py-0.5 bg-[var(--accent-primary)] text-white text-xs font-bold rounded-full">
              {unopenedChests.length}
            </span>
          )}
        </div>

        {unopenedChests.length === 0 ? (
          <div className="text-center py-8">
            <div className="text-5xl mb-3 opacity-50">📭</div>
            <p className="text-[var(--text-secondary)]">
              미개봉 상자가 없습니다
            </p>
            <p className="text-sm text-[var(--text-muted)] mt-1">
              레슨을 완료하면 상자를 획득할 수 있어요!
            </p>
          </div>
        ) : (
          <div className="grid grid-cols-2 sm:grid-cols-3 md:grid-cols-4 lg:grid-cols-5 gap-4">
            {unopenedChests.map((chest) => {
              const rarityConfig = RARITY_ICONS[chest.chestRarity];
              return (
                <button
                  key={chest.id}
                  onClick={() => handleOpenChest(chest)}
                  disabled={isOpening}
                  className="group flex flex-col items-center p-4 bg-[var(--bg-primary)] rounded-xl border-2 transition-all hover:scale-105 disabled:opacity-50 disabled:cursor-not-allowed"
                  style={{
                    borderColor: `${rarityConfig.color}40`,
                  }}
                  onMouseEnter={(e) => {
                    e.currentTarget.style.borderColor = rarityConfig.color;
                  }}
                  onMouseLeave={(e) => {
                    e.currentTarget.style.borderColor = `${rarityConfig.color}40`;
                  }}
                >
                  <div className="relative text-5xl mb-2 group-hover:animate-chestShake">
                    📦
                    {rarityConfig.badge && (
                      <span className="absolute -top-1 -right-1 text-lg">
                        {rarityConfig.badge}
                      </span>
                    )}
                  </div>
                  <span
                    className="font-medium text-sm"
                    style={{ color: rarityConfig.color }}
                  >
                    {RARITY_NAMES[chest.chestRarity]} 상자
                  </span>
                  <span className="text-xs text-[var(--text-muted)] mt-1">
                    클릭하여 열기
                  </span>
                </button>
              );
            })}
          </div>
        )}
      </div>

      {/* Inventory Grid */}
      <h2 className="text-lg font-semibold text-[var(--text-primary)] mb-4">
        보유 아이템
      </h2>

      {inventory.length === 0 ? (
        <div className="text-center py-16 bg-[var(--bg-secondary)] rounded-xl">
          <div className="text-6xl mb-4">🎒</div>
          <p className="text-[var(--text-secondary)] mb-4">
            인벤토리가 비어있습니다
          </p>
          <Link
            href="/shop"
            className="inline-flex items-center gap-2 px-4 py-2 bg-[var(--accent-primary)] text-white rounded-lg font-medium hover:opacity-90 transition-opacity"
          >
            <span>🏪</span>
            <span>상점 가기</span>
          </Link>
        </div>
      ) : (
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
          {inventory.map((inventoryItem) => (
            <div
              key={inventoryItem.id}
              className="bg-[var(--bg-secondary)] rounded-xl p-6 border border-[var(--border-default)]"
            >
              {/* Icon with quantity badge */}
              <div className="relative inline-block mb-4">
                <div className="text-5xl">{inventoryItem.item.icon}</div>
                <div className="absolute -top-1 -right-1 bg-[var(--accent-primary)] text-white text-xs font-bold w-6 h-6 rounded-full flex items-center justify-center">
                  {inventoryItem.quantity}
                </div>
              </div>

              {/* Info */}
              <h3 className="text-lg font-semibold text-[var(--text-primary)] mb-2">
                {inventoryItem.item.name}
              </h3>
              <p className="text-sm text-[var(--text-secondary)] mb-4">
                {inventoryItem.item.description}
              </p>

              {/* Usage hint */}
              {inventoryItem.item.itemType === "seerStone" && (
                <div className="bg-[var(--bg-primary)] rounded-lg p-3 text-sm">
                  <p className="text-[var(--text-muted)]">
                    <span className="text-[var(--accent-primary)]">Tip:</span>{" "}
                    레슨 화면에서 &quot;정답 보기&quot; 버튼을 눌러 사용할 수 있습니다.
                  </p>
                </div>
              )}
            </div>
          ))}
        </div>
      )}

      {/* Chest Open Modal */}
      {selectedChest && (
        <ChestOpenModal
          isOpen={chestModalOpen}
          rarity={selectedChest.chestRarity}
          apiReward={chestOpenResult?.reward}
          onClose={handleCloseModal}
        />
      )}
    </div>
  );
}
