import { test, expect } from '@playwright/test';

// TODO: 백엔드 서버 연동 후 활성화
test.describe.skip('Lesson Page (With Mock Data)', () => {
  test.beforeEach(async ({ page }) => {
    // Mock 인증 설정
    await page.addInitScript(() => {
      localStorage.setItem('accessToken', 'test-token');
      localStorage.setItem('refreshToken', 'test-refresh');
    });

    // 레슨 데이터 mock
    await page.route('**/lessons/lesson-1', async (route) => {
      await route.fulfill({
        status: 200,
        contentType: 'application/json',
        body: JSON.stringify({
          id: 'lesson-1',
          title: 'Hello, Swifty!',
          type: 'codeExercise',
          language: 'swift',
          content: '# Hello, Swifty!\n\nprint 함수를 사용하여 "Hello, Swifty!"를 출력해보세요.',
          starterCode: '// 여기에 코드를 작성하세요\n',
          expectedOutput: 'Hello, Swifty!',
          xpReward: 20,
          courseId: 'course-1',
          previousLessonId: null,
          nextLessonId: 'lesson-2',
        }),
      });
    });

    // 인벤토리 mock (Seer Stone)
    await page.route('**/inventory', async (route) => {
      await route.fulfill({
        status: 200,
        contentType: 'application/json',
        body: JSON.stringify([
          {
            id: 'inv-1',
            quantity: 2,
            item: {
              id: 'item-1',
              itemType: 'seerStone',
              name: 'Seer Stone',
              price: 50,
            },
          },
        ]),
      });
    });
  });

  test('displays lesson header with title and type', async ({ page }) => {
    await page.goto('/learn/lesson-1');

    await expect(page.getByRole('heading', { name: 'Hello, Swifty!' })).toBeVisible();
    await expect(page.getByText('코드 연습')).toBeVisible();
    await expect(page.getByText('20 XP')).toBeVisible();
  });

  test('displays lesson content', async ({ page }) => {
    await page.goto('/learn/lesson-1');

    await expect(page.getByText(/print 함수를 사용하여/)).toBeVisible();
  });

  test('displays code editor', async ({ page }) => {
    await page.goto('/learn/lesson-1');

    // Monaco Editor가 로드될 때까지 대기
    const editor = page.locator('.monaco-editor');
    await expect(editor).toBeVisible({ timeout: 10000 });
  });

  test('displays run button', async ({ page }) => {
    await page.goto('/learn/lesson-1');

    const runButton = page.getByRole('button', { name: /실행/ });
    await expect(runButton).toBeVisible();
  });

  test('displays reset button', async ({ page }) => {
    await page.goto('/learn/lesson-1');

    const resetButton = page.getByRole('button', { name: '초기화' });
    await expect(resetButton).toBeVisible();
  });

  test('displays back button', async ({ page }) => {
    await page.goto('/learn/lesson-1');

    // 뒤로가기 버튼 (SVG 아이콘)
    const backButton = page.locator('button').filter({ has: page.locator('svg path[d*="M15 19l-7-7 7-7"]') });
    await expect(backButton).toBeVisible();
  });

  test('displays Seer Stone button when available', async ({ page }) => {
    await page.goto('/learn/lesson-1');

    await expect(page.getByRole('button', { name: /정답 보기/ })).toBeVisible();
    await expect(page.getByText('(2)')).toBeVisible(); // 2개 보유
  });

  test('displays language label', async ({ page }) => {
    await page.goto('/learn/lesson-1');

    // 언어 레이블 확인 (소문자 swift)
    await expect(page.locator('span.font-mono').getByText('swift')).toBeVisible();
  });
});

// TODO: 백엔드 서버 연동 후 활성화
test.describe.skip('Code Submission Flow', () => {
  test.beforeEach(async ({ page }) => {
    await page.addInitScript(() => {
      localStorage.setItem('accessToken', 'test-token');
      localStorage.setItem('refreshToken', 'test-refresh');
    });

    await page.route('**/lessons/lesson-1', async (route) => {
      await route.fulfill({
        status: 200,
        contentType: 'application/json',
        body: JSON.stringify({
          id: 'lesson-1',
          title: 'Hello, Swifty!',
          type: 'codeExercise',
          language: 'swift',
          content: '# Hello, Swifty!',
          starterCode: '',
          expectedOutput: 'Hello, Swifty!',
          xpReward: 20,
          courseId: 'course-1',
          nextLessonId: 'lesson-2',
        }),
      });
    });

    await page.route('**/inventory', async (route) => {
      await route.fulfill({
        status: 200,
        contentType: 'application/json',
        body: JSON.stringify([]),
      });
    });
  });

  test('shows success message on correct answer', async ({ page }) => {
    // 정답 제출 mock
    await page.route('**/lessons/lesson-1/submit', async (route) => {
      await route.fulfill({
        status: 200,
        contentType: 'application/json',
        body: JSON.stringify({
          lessonId: 'lesson-1',
          status: 'success',
          isCorrect: true,
          output: 'Hello, Swifty!',
          xpEarned: 20,
          message: '정답입니다!',
        }),
      });
    });

    await page.route('**/users/me', async (route) => {
      await route.fulfill({
        status: 200,
        contentType: 'application/json',
        body: JSON.stringify({
          id: 'user-1',
          username: 'testuser',
          totalXp: 170,
          level: 2,
          gems: 10,
        }),
      });
    });

    await page.goto('/learn/lesson-1');

    // 실행 버튼 클릭
    await page.getByRole('button', { name: /실행/ }).click();

    // 성공 메시지 확인
    await expect(page.getByText('정답입니다!')).toBeVisible({ timeout: 10000 });
    await expect(page.getByText('+20 XP 획득')).toBeVisible();
  });

  test('shows error message on incorrect answer', async ({ page }) => {
    // 오답 제출 mock
    await page.route('**/lessons/lesson-1/submit', async (route) => {
      await route.fulfill({
        status: 200,
        contentType: 'application/json',
        body: JSON.stringify({
          lessonId: 'lesson-1',
          status: 'failure',
          isCorrect: false,
          output: 'Wrong output',
          message: '출력이 일치하지 않습니다.',
        }),
      });
    });

    await page.goto('/learn/lesson-1');

    // 실행 버튼 클릭
    await page.getByRole('button', { name: /실행/ }).click();

    // 실패 메시지 확인
    await expect(page.getByText('다시 시도해보세요')).toBeVisible({ timeout: 10000 });
  });

  test('shows next lesson button after success', async ({ page }) => {
    await page.route('**/lessons/lesson-1/submit', async (route) => {
      await route.fulfill({
        status: 200,
        contentType: 'application/json',
        body: JSON.stringify({
          lessonId: 'lesson-1',
          status: 'success',
          isCorrect: true,
          xpEarned: 20,
        }),
      });
    });

    await page.route('**/users/me', async (route) => {
      await route.fulfill({
        status: 200,
        contentType: 'application/json',
        body: JSON.stringify({
          id: 'user-1',
          username: 'testuser',
          totalXp: 170,
          level: 2,
          gems: 10,
        }),
      });
    });

    await page.goto('/learn/lesson-1');
    await page.getByRole('button', { name: /실행/ }).click();

    // 다음 레슨 버튼 확인
    await expect(page.getByRole('button', { name: '다음 레슨' })).toBeVisible({ timeout: 10000 });
  });
});

// TODO: 백엔드 서버 연동 후 활성화
test.describe.skip('Reading Lesson', () => {
  test.beforeEach(async ({ page }) => {
    await page.addInitScript(() => {
      localStorage.setItem('accessToken', 'test-token');
      localStorage.setItem('refreshToken', 'test-refresh');
    });

    await page.route('**/lessons/lesson-reading', async (route) => {
      await route.fulfill({
        status: 200,
        contentType: 'application/json',
        body: JSON.stringify({
          id: 'lesson-reading',
          title: 'Swift 소개',
          type: 'reading',
          content: '# Swift란?\n\nSwift는 Apple이 만든 프로그래밍 언어입니다.',
          xpReward: 10,
          courseId: 'course-1',
        }),
      });
    });

    await page.route('**/inventory', async (route) => {
      await route.fulfill({
        status: 200,
        contentType: 'application/json',
        body: JSON.stringify([]),
      });
    });
  });

  test('displays reading lesson without code editor', async ({ page }) => {
    await page.goto('/learn/lesson-reading');

    await expect(page.getByRole('heading', { name: 'Swift 소개' })).toBeVisible();
    await expect(page.getByText('읽기')).toBeVisible();

    // 코드 에디터가 없어야 함
    await expect(page.locator('.monaco-editor')).not.toBeVisible();
  });

  test('displays complete button for reading lesson', async ({ page }) => {
    await page.goto('/learn/lesson-reading');

    await expect(page.getByRole('button', { name: '완료하고 돌아가기' })).toBeVisible();
  });
});
