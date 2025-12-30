"use client";

import { useEffect, useState } from "react";
import { api, ShopItem, PurchaseResponse } from "@/lib/api";
import { useAuth } from "@/stores/auth-store";
import { PurchaseModal } from "@/components/shop/PurchaseModal";
import confetti from "canvas-confetti";

export default function ShopPage() {
  const { user, refreshUser } = useAuth();
  const [items, setItems] = useState<ShopItem[]>([]);
  const [isLoading, setIsLoading] = useState(true);
  const [selectedItem, setSelectedItem] = useState<ShopItem | null>(null);
  const [isPurchasing, setIsPurchasing] = useState(false);
  const [purchaseResult, setPurchaseResult] = useState<PurchaseResponse | null>(null);

  useEffect(() => {
    loadShopItems();
  }, []);

  const loadShopItems = async () => {
    try {
      const shopItems = await api.getShopItems();
      setItems(shopItems);
    } catch (error) {
      console.error("Failed to load shop items:", error);
    } finally {
      setIsLoading(false);
    }
  };

  const handlePurchase = async (item: ShopItem) => {
    setIsPurchasing(true);
    try {
      const result = await api.purchaseItem(item.id);
      setPurchaseResult(result);

      if (result.success) {
        // 구매 성공 시 confetti 효과
        confetti({
          particleCount: 100,
          spread: 70,
          origin: { y: 0.6 },
          colors: ["#AF52DE", "#FFD700", "#007AFF"],
        });

        // 사용자 정보 새로고침 (Gems 업데이트)
        await refreshUser();
      }
    } catch (error) {
      console.error("Failed to purchase item:", error);
      setPurchaseResult({
        success: false,
        message: "구매 중 오류가 발생했습니다.",
        remainingGems: user?.gems || 0,
        inventoryItem: null,
      });
    } finally {
      setIsPurchasing(false);
    }
  };

  const handleCloseModal = () => {
    setSelectedItem(null);
    setPurchaseResult(null);
  };

  const userGems = user?.gems || 0;

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
      <div className="flex items-center justify-between mb-8">
        <div>
          <h1 className="text-2xl font-bold text-[var(--text-primary)]">상점</h1>
          <p className="text-[var(--text-secondary)] mt-1">
            Gems로 유용한 아이템을 구매하세요
          </p>
        </div>
        <div className="flex items-center gap-2 bg-[var(--bg-secondary)] px-4 py-2 rounded-lg">
          <span className="text-2xl">💎</span>
          <span className="text-xl font-bold text-[var(--gem-purple)]">
            {userGems}
          </span>
        </div>
      </div>

      {/* Shop Items Grid */}
      {items.length === 0 ? (
        <div className="text-center py-16">
          <p className="text-[var(--text-secondary)]">
            현재 판매 중인 아이템이 없습니다.
          </p>
        </div>
      ) : (
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
          {items.map((item) => {
            const canAfford = userGems >= item.price;
            return (
              <div
                key={item.id}
                className="bg-[var(--bg-secondary)] rounded-xl p-6 border border-[var(--border-default)] hover:border-[var(--accent-primary)] transition-colors"
              >
                {/* Icon */}
                <div className="text-5xl mb-4 text-center">{item.icon}</div>

                {/* Info */}
                <h3 className="text-lg font-semibold text-[var(--text-primary)] text-center mb-2">
                  {item.name}
                </h3>
                <p className="text-sm text-[var(--text-secondary)] text-center mb-4">
                  {item.description}
                </p>

                {/* Price & Button */}
                <div className="flex items-center justify-between mt-4">
                  <div className="flex items-center gap-1">
                    <span>💎</span>
                    <span
                      className={`font-bold ${
                        canAfford
                          ? "text-[var(--gem-purple)]"
                          : "text-[var(--accent-error)]"
                      }`}
                    >
                      {item.price}
                    </span>
                  </div>
                  <button
                    onClick={() => setSelectedItem(item)}
                    disabled={!canAfford}
                    className={`px-4 py-2 rounded-lg font-medium transition-colors ${
                      canAfford
                        ? "bg-[var(--accent-primary)] text-white hover:opacity-90"
                        : "bg-[var(--bg-hover)] text-[var(--text-muted)] cursor-not-allowed"
                    }`}
                  >
                    {canAfford ? "구매" : "Gems 부족"}
                  </button>
                </div>
              </div>
            );
          })}
        </div>
      )}

      {/* Purchase Modal */}
      <PurchaseModal
        isOpen={selectedItem !== null}
        item={selectedItem}
        userGems={userGems}
        isPurchasing={isPurchasing}
        purchaseResult={purchaseResult}
        onPurchase={handlePurchase}
        onClose={handleCloseModal}
      />
    </div>
  );
}
