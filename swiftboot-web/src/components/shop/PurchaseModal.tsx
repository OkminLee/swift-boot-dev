"use client";

import { useEffect } from "react";
import { ShopItem, PurchaseResponse } from "@/lib/api";

interface PurchaseModalProps {
  isOpen: boolean;
  item: ShopItem | null;
  userGems: number;
  isPurchasing: boolean;
  purchaseResult: PurchaseResponse | null;
  onPurchase: (item: ShopItem) => void;
  onClose: () => void;
}

export function PurchaseModal({
  isOpen,
  item,
  userGems,
  isPurchasing,
  purchaseResult,
  onPurchase,
  onClose,
}: PurchaseModalProps) {
  // ESC 키로 모달 닫기
  useEffect(() => {
    const handleEsc = (e: KeyboardEvent) => {
      if (e.key === "Escape" && !isPurchasing) {
        onClose();
      }
    };
    window.addEventListener("keydown", handleEsc);
    return () => window.removeEventListener("keydown", handleEsc);
  }, [onClose, isPurchasing]);

  if (!isOpen || !item) return null;

  const canAfford = userGems >= item.price;

  // 구매 결과 표시
  if (purchaseResult) {
    return (
      <div className="fixed inset-0 z-50 flex items-center justify-center">
        {/* Backdrop */}
        <div
          className="absolute inset-0 bg-black/60 animate-fadeIn"
          onClick={onClose}
        />

        {/* Modal */}
        <div className="relative bg-[var(--bg-secondary)] rounded-2xl p-8 max-w-md w-full mx-4 animate-scaleIn text-center">
          {purchaseResult.success ? (
            <>
              <div className="text-6xl mb-4">{item.icon}</div>
              <h2 className="text-2xl font-bold text-[var(--accent-success)] mb-2">
                구매 완료!
              </h2>
              <p className="text-[var(--text-secondary)] mb-4">
                {purchaseResult.message}
              </p>
              <p className="text-sm text-[var(--text-muted)]">
                남은 Gems: 💎 {purchaseResult.remainingGems}
              </p>
            </>
          ) : (
            <>
              <div className="text-6xl mb-4">❌</div>
              <h2 className="text-2xl font-bold text-[var(--accent-error)] mb-2">
                구매 실패
              </h2>
              <p className="text-[var(--text-secondary)] mb-4">
                {purchaseResult.message}
              </p>
            </>
          )}

          <button
            onClick={onClose}
            className="mt-6 px-6 py-2 bg-[var(--accent-primary)] text-white rounded-lg font-medium hover:opacity-90 transition-opacity"
          >
            확인
          </button>
        </div>
      </div>
    );
  }

  // 구매 확인
  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center">
      {/* Backdrop */}
      <div
        className="absolute inset-0 bg-black/60 animate-fadeIn"
        onClick={onClose}
      />

      {/* Modal */}
      <div className="relative bg-[var(--bg-secondary)] rounded-2xl p-8 max-w-md w-full mx-4 animate-scaleIn">
        {/* Item Preview */}
        <div className="text-center mb-6">
          <div className="text-6xl mb-4">{item.icon}</div>
          <h2 className="text-xl font-bold text-[var(--text-primary)]">
            {item.name}
          </h2>
          <p className="text-sm text-[var(--text-secondary)] mt-2">
            {item.description}
          </p>
        </div>

        {/* Price Info */}
        <div className="bg-[var(--bg-primary)] rounded-lg p-4 mb-6">
          <div className="flex items-center justify-between">
            <span className="text-[var(--text-secondary)]">가격</span>
            <div className="flex items-center gap-1">
              <span>💎</span>
              <span className="font-bold text-[var(--gem-purple)]">
                {item.price}
              </span>
            </div>
          </div>
          <div className="flex items-center justify-between mt-2">
            <span className="text-[var(--text-secondary)]">보유 Gems</span>
            <div className="flex items-center gap-1">
              <span>💎</span>
              <span
                className={`font-bold ${
                  canAfford
                    ? "text-[var(--text-primary)]"
                    : "text-[var(--accent-error)]"
                }`}
              >
                {userGems}
              </span>
            </div>
          </div>
          <div className="border-t border-[var(--border-default)] mt-3 pt-3">
            <div className="flex items-center justify-between">
              <span className="text-[var(--text-secondary)]">구매 후 잔액</span>
              <div className="flex items-center gap-1">
                <span>💎</span>
                <span
                  className={`font-bold ${
                    canAfford
                      ? "text-[var(--accent-success)]"
                      : "text-[var(--accent-error)]"
                  }`}
                >
                  {userGems - item.price}
                </span>
              </div>
            </div>
          </div>
        </div>

        {/* Buttons */}
        <div className="flex gap-3">
          <button
            onClick={onClose}
            disabled={isPurchasing}
            className="flex-1 px-4 py-3 bg-[var(--bg-hover)] text-[var(--text-primary)] rounded-lg font-medium hover:opacity-90 transition-opacity disabled:opacity-50"
          >
            취소
          </button>
          <button
            onClick={() => onPurchase(item)}
            disabled={!canAfford || isPurchasing}
            className={`flex-1 px-4 py-3 rounded-lg font-medium transition-opacity ${
              canAfford
                ? "bg-[var(--accent-primary)] text-white hover:opacity-90"
                : "bg-[var(--bg-hover)] text-[var(--text-muted)] cursor-not-allowed"
            } disabled:opacity-50`}
          >
            {isPurchasing ? (
              <span className="flex items-center justify-center gap-2">
                <span className="animate-spin w-4 h-4 border-2 border-white border-t-transparent rounded-full" />
                구매 중...
              </span>
            ) : (
              "구매하기"
            )}
          </button>
        </div>
      </div>
    </div>
  );
}
