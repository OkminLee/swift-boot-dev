import { test, expect } from '@playwright/test';

// TODO: 백엔드 서버 연동 후 활성화
test.describe.skip('Shop Page', () => {
  test.beforeEach(async ({ page }) => {
    // Mock 인증 설정
    await page.addInitScript(() => {
      localStorage.setItem('accessToken', 'test-token');
      localStorage.setItem('refreshToken', 'test-refresh');
    });

    // 사용자 정보 mock
    await page.route('**/users/me', async (route) => {
      await route.fulfill({
        status: 200,
        contentType: 'application/json',
        body: JSON.stringify({
          id: 'user-1',
          username: 'testuser',
          totalXp: 150,
          level: 2,
          gems: 100,
          streak: 3,
        }),
      });
    });

    // 상점 아이템 mock
    await page.route('**/shop/items', async (route) => {
      await route.fulfill({
        status: 200,
        contentType: 'application/json',
        body: JSON.stringify([
          {
            id: 'item-1',
            name: 'Seer Stone',
            description: '레슨의 정답 코드를 볼 수 있습니다.',
            itemType: 'seerStone',
            price: 50,
            icon: '🔮',
          },
          {
            id: 'item-2',
            name: 'XP Potion',
            description: '다음 레슨에서 XP를 2배로 획득합니다.',
            itemType: 'xpPotion',
            price: 200,
            icon: '⚗️',
          },
        ]),
      });
    });
  });

  test('displays shop header', async ({ page }) => {
    await page.goto('/shop');

    await expect(page.getByRole('heading', { name: '상점' })).toBeVisible();
    await expect(page.getByText('Gems로 유용한 아이템을 구매하세요')).toBeVisible();
  });

  test('displays user gems balance', async ({ page }) => {
    await page.goto('/shop');

    // 💎 아이콘과 100 Gems가 표시되어야 함
    await expect(page.locator('text=💎')).toBeVisible();
    await expect(page.locator('.text-\\[var\\(--gem-purple\\)\\]').getByText('100')).toBeVisible();
  });

  test('displays shop items', async ({ page }) => {
    await page.goto('/shop');

    await expect(page.getByText('Seer Stone')).toBeVisible();
    await expect(page.getByText('XP Potion')).toBeVisible();
  });

  test('displays item prices', async ({ page }) => {
    await page.goto('/shop');

    // 가격 확인 (50, 200)
    await expect(page.getByText('50').first()).toBeVisible();
    await expect(page.getByText('200')).toBeVisible();
  });

  test('shows purchase button for affordable items', async ({ page }) => {
    await page.goto('/shop');

    // Seer Stone (50 gems) - 구매 가능
    const buyButtons = page.getByRole('button', { name: '구매' });
    await expect(buyButtons.first()).toBeVisible();
  });

  test('shows "Gems 부족" for expensive items', async ({ page }) => {
    await page.goto('/shop');

    // XP Potion (200 gems) - 구매 불가 (100 gems 보유)
    await expect(page.getByRole('button', { name: 'Gems 부족' })).toBeVisible();
  });

  test('opens purchase modal when clicking buy', async ({ page }) => {
    await page.goto('/shop');

    // 구매 버튼 클릭
    await page.getByRole('button', { name: '구매' }).first().click();

    // 모달이 열려야 함 (Seer Stone 아이템 정보가 보임)
    await expect(page.getByText('🔮').nth(1)).toBeVisible();
  });
});

// TODO: 백엔드 서버 연동 후 활성화
test.describe.skip('Inventory Page', () => {
  test.beforeEach(async ({ page }) => {
    await page.addInitScript(() => {
      localStorage.setItem('accessToken', 'test-token');
      localStorage.setItem('refreshToken', 'test-refresh');
    });

    await page.route('**/users/me', async (route) => {
      await route.fulfill({
        status: 200,
        contentType: 'application/json',
        body: JSON.stringify({
          id: 'user-1',
          username: 'testuser',
          totalXp: 150,
          level: 2,
          gems: 100,
        }),
      });
    });
  });

  test('displays inventory header', async ({ page }) => {
    await page.route('**/inventory', async (route) => {
      await route.fulfill({
        status: 200,
        contentType: 'application/json',
        body: JSON.stringify([]),
      });
    });

    await page.route('**/chests/unopened', async (route) => {
      await route.fulfill({
        status: 200,
        contentType: 'application/json',
        body: JSON.stringify([]),
      });
    });

    await page.goto('/inventory');

    await expect(page.getByRole('heading', { name: '인벤토리' })).toBeVisible();
    await expect(page.getByText('보유한 아이템과 상자를 확인하세요')).toBeVisible();
  });

  test('displays empty inventory message', async ({ page }) => {
    await page.route('**/inventory', async (route) => {
      await route.fulfill({
        status: 200,
        contentType: 'application/json',
        body: JSON.stringify([]),
      });
    });

    await page.route('**/chests/unopened', async (route) => {
      await route.fulfill({
        status: 200,
        contentType: 'application/json',
        body: JSON.stringify([]),
      });
    });

    await page.goto('/inventory');

    await expect(page.getByText('인벤토리가 비어있습니다')).toBeVisible();
    await expect(page.getByRole('link', { name: /상점 가기/ })).toBeVisible();
  });

  test('displays inventory items with quantity', async ({ page }) => {
    await page.route('**/inventory', async (route) => {
      await route.fulfill({
        status: 200,
        contentType: 'application/json',
        body: JSON.stringify([
          {
            id: 'inv-1',
            quantity: 3,
            item: {
              id: 'item-1',
              name: 'Seer Stone',
              description: '레슨의 정답 코드를 볼 수 있습니다.',
              itemType: 'seerStone',
              icon: '🔮',
              price: 50,
            },
          },
        ]),
      });
    });

    await page.route('**/chests/unopened', async (route) => {
      await route.fulfill({
        status: 200,
        contentType: 'application/json',
        body: JSON.stringify([]),
      });
    });

    await page.goto('/inventory');

    await expect(page.getByText('Seer Stone')).toBeVisible();
    // 수량 배지
    await expect(page.locator('.bg-\\[var\\(--accent-primary\\)\\]').getByText('3')).toBeVisible();
  });

  test('displays unopened chests section', async ({ page }) => {
    await page.route('**/inventory', async (route) => {
      await route.fulfill({
        status: 200,
        contentType: 'application/json',
        body: JSON.stringify([]),
      });
    });

    await page.route('**/chests/unopened', async (route) => {
      await route.fulfill({
        status: 200,
        contentType: 'application/json',
        body: JSON.stringify([
          {
            id: 'chest-1',
            chestRarity: 'common',
            earnedAt: new Date().toISOString(),
          },
          {
            id: 'chest-2',
            chestRarity: 'rare',
            earnedAt: new Date().toISOString(),
          },
        ]),
      });
    });

    await page.goto('/inventory');

    await expect(page.getByText('미개봉 상자')).toBeVisible();
    // 상자 개수 배지 (2개)
    await expect(page.locator('.bg-\\[var\\(--accent-primary\\)\\].rounded-full').getByText('2')).toBeVisible();
    await expect(page.getByText('일반 상자')).toBeVisible();
    await expect(page.getByText('희귀 상자')).toBeVisible();
  });

  test('shows empty chest message when no chests', async ({ page }) => {
    await page.route('**/inventory', async (route) => {
      await route.fulfill({
        status: 200,
        contentType: 'application/json',
        body: JSON.stringify([]),
      });
    });

    await page.route('**/chests/unopened', async (route) => {
      await route.fulfill({
        status: 200,
        contentType: 'application/json',
        body: JSON.stringify([]),
      });
    });

    await page.goto('/inventory');

    await expect(page.getByText('미개봉 상자가 없습니다')).toBeVisible();
  });

  test('opens chest modal when clicking chest', async ({ page }) => {
    await page.route('**/inventory', async (route) => {
      await route.fulfill({
        status: 200,
        contentType: 'application/json',
        body: JSON.stringify([]),
      });
    });

    await page.route('**/chests/unopened', async (route) => {
      await route.fulfill({
        status: 200,
        contentType: 'application/json',
        body: JSON.stringify([
          {
            id: 'chest-1',
            chestRarity: 'common',
            earnedAt: new Date().toISOString(),
          },
        ]),
      });
    });

    await page.route('**/chests/chest-1/open', async (route) => {
      await route.fulfill({
        status: 200,
        contentType: 'application/json',
        body: JSON.stringify({
          success: true,
          reward: {
            xp: 10,
            gems: 5,
          },
        }),
      });
    });

    await page.goto('/inventory');

    // 상자 클릭
    await page.getByRole('button', { name: /일반 상자/ }).click();

    // 모달이 열려야 함 - 보상 정보가 표시됨
    await expect(page.getByText(/\+10 XP/).or(page.getByText(/\+5/))).toBeVisible({ timeout: 10000 });
  });
});
