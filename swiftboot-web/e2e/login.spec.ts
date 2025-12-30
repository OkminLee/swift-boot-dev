import { test, expect } from '@playwright/test';

test.describe('Login Page', () => {
  test.beforeEach(async ({ page }) => {
    await page.goto('/login');
  });

  test('displays login heading', async ({ page }) => {
    await expect(page.getByRole('heading', { name: '로그인' })).toBeVisible();
  });

  test('displays SwiftBoot logo', async ({ page }) => {
    await expect(page.getByText('SwiftBoot')).toBeVisible();
  });

  test('displays tagline', async ({ page }) => {
    await expect(page.getByText('게임처럼 코딩을 배워보세요')).toBeVisible();
  });

  test('has GitHub login button', async ({ page }) => {
    const githubButton = page.getByRole('button', { name: /GitHub으로 계속하기/i });
    await expect(githubButton).toBeVisible();
  });

  test('displays terms and privacy links', async ({ page }) => {
    await expect(page.getByRole('link', { name: '이용약관' })).toBeVisible();
    await expect(page.getByRole('link', { name: '개인정보처리방침' })).toBeVisible();
  });

  test('has back to home link', async ({ page }) => {
    const homeLink = page.getByRole('link', { name: /홈으로 돌아가기/i });
    await expect(homeLink).toBeVisible();
    await expect(homeLink).toHaveAttribute('href', '/');
  });

  test('navigates back to home page', async ({ page }) => {
    await page.getByRole('link', { name: /홈으로 돌아가기/i }).click();
    await expect(page).toHaveURL('/');
  });

  test('logo links back to home', async ({ page }) => {
    await page.getByRole('link', { name: 'SwiftBoot' }).first().click();
    await expect(page).toHaveURL('/');
  });
});
