"use client";

import { useEffect, useState } from "react";
import Link from "next/link";
import { api, InventoryItem } from "@/lib/api";

export default function InventoryPage() {
  const [inventory, setInventory] = useState<InventoryItem[]>([]);
  const [isLoading, setIsLoading] = useState(true);

  useEffect(() => {
    loadInventory();
  }, []);

  const loadInventory = async () => {
    try {
      const items = await api.getInventory();
      setInventory(items);
    } catch (error) {
      console.error("Failed to load inventory:", error);
    } finally {
      setIsLoading(false);
    }
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
          보유한 아이템을 확인하세요
        </p>
      </div>

      {/* Inventory Grid */}
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
    </div>
  );
}
