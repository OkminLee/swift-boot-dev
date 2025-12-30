import { test, expect } from '@playwright/test';

test.describe('Landing Page', () => {
  test.beforeEach(async ({ page }) => {
    await page.goto('/');
  });

  test('displays hero section with correct heading', async ({ page }) => {
    await expect(page.locator('h1')).toContainText('코딩을');
    await expect(page.locator('h1')).toContainText('게임처럼');
    await expect(page.locator('h1')).toContainText('배우세요');
  });

  test('displays SwiftBoot logo in header', async ({ page }) => {
    await expect(page.locator('header')).toContainText('SwiftBoot');
  });

  test('displays three feature cards', async ({ page }) => {
    await expect(page.getByText('실시간 코드 실행')).toBeVisible();
    await expect(page.getByText('게이미피케이션')).toBeVisible();
    await expect(page.getByText('Swift 특화')).toBeVisible();
  });

  test('has login link in header', async ({ page }) => {
    const loginLink = page.locator('header').getByRole('link', { name: '로그인' });
    await expect(loginLink).toBeVisible();
    await expect(loginLink).toHaveAttribute('href', '/login');
  });

  test('has start button in header', async ({ page }) => {
    const startButton = page.locator('header').getByRole('link', { name: '시작하기' });
    await expect(startButton).toBeVisible();
    await expect(startButton).toHaveAttribute('href', '/login');
  });

  test('has CTA button that links to login', async ({ page }) => {
    const ctaButton = page.getByRole('link', { name: '무료로 시작하기' });
    await expect(ctaButton).toBeVisible();
    await expect(ctaButton).toHaveAttribute('href', '/login');
  });

  test('displays footer with copyright', async ({ page }) => {
    await expect(page.locator('footer')).toContainText('SwiftBoot');
    await expect(page.locator('footer')).toContainText('Vapor');
  });

  test('navigates to login page when clicking start button', async ({ page }) => {
    await page.getByRole('link', { name: '시작하기' }).first().click();
    await expect(page).toHaveURL('/login');
  });
});
