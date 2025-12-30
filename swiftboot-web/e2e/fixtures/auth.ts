import { test as base, Page } from '@playwright/test';

/**
 * 인증된 사용자를 시뮬레이션하기 위한 fixture
 *
 * 실제 GitHub OAuth 없이 테스트하기 위해
 * localStorage에 mock 토큰을 설정합니다.
 */
export const mockAuthToken = {
  accessToken: 'test-access-token-for-e2e',
  refreshToken: 'test-refresh-token-for-e2e',
};

export const mockUser = {
  id: 'test-user-id',
  username: 'testuser',
  email: 'test@example.com',
  avatarUrl: 'https://avatars.githubusercontent.com/u/1?v=4',
  totalXp: 150,
  level: 2,
  gems: 10,
  streak: 3,
  createdAt: new Date().toISOString(),
};

/**
 * 페이지에 mock 인증 상태를 설정합니다.
 */
export async function setupMockAuth(page: Page) {
  await page.addInitScript((tokens) => {
    localStorage.setItem('accessToken', tokens.accessToken);
    localStorage.setItem('refreshToken', tokens.refreshToken);
  }, mockAuthToken);
}

/**
 * 인증된 상태로 테스트를 실행하는 fixture
 */
export const test = base.extend<{ authenticatedPage: Page }>({
  authenticatedPage: async ({ page }, use) => {
    await setupMockAuth(page);
    await use(page);
  },
});

export { expect } from '@playwright/test';
