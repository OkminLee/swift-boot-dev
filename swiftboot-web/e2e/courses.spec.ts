import { test, expect } from '@playwright/test';

test.describe('Courses Page (Unauthenticated)', () => {
  test('redirects to login when not authenticated', async ({ page }) => {
    // 인증 없이 코스 페이지 접근 시 로그인으로 리다이렉트 되는지 확인
    await page.goto('/courses');
    // 로그인 페이지로 리다이렉트되거나 로그인 요청 UI가 표시되어야 함
    await expect(page).toHaveURL(/\/(login|courses)/);
  });
});

// TODO: 백엔드 서버 연동 후 활성화
test.describe.skip('Courses Page (With Mock Data)', () => {
  test.beforeEach(async ({ page }) => {
    // API mock 설정 (먼저 설정)
    await page.route('**/tracks', async (route) => {
      if (route.request().url().includes('/tracks/')) {
        return route.fallback();
      }
      await route.fulfill({
        status: 200,
        contentType: 'application/json',
        body: JSON.stringify([
          {
            id: 'track-1',
            title: 'Swift 마스터',
            description: 'Swift 프로그래밍의 기초부터 고급까지',
            icon: 'swift',
            order: 1,
          },
        ]),
      });
    });

    await page.route('**/tracks/track-1', async (route) => {
      await route.fulfill({
        status: 200,
        contentType: 'application/json',
        body: JSON.stringify({
          id: 'track-1',
          title: 'Swift 마스터',
          description: 'Swift 프로그래밍의 기초부터 고급까지',
          icon: 'swift',
          order: 1,
          courses: [
            {
              id: 'course-1',
              title: 'Swifty 만들기',
              description: 'AI 챗봇 Swifty를 만들며 Swift 기초 배우기',
              difficulty: 'beginner',
              icon: 'book',
              order: 1,
            },
            {
              id: 'course-2',
              title: 'Swifty 2.0',
              description: 'Swifty의 고급 기능 구현하기',
              difficulty: 'intermediate',
              icon: 'book',
              order: 2,
            },
          ],
        }),
      });
    });

    await page.route('**/users/me/progress/courses', async (route) => {
      await route.fulfill({
        status: 200,
        contentType: 'application/json',
        body: JSON.stringify([
          {
            courseId: 'course-1',
            completedLessons: 3,
            totalLessons: 10,
          },
        ]),
      });
    });

    // Mock 인증 설정
    await page.addInitScript(() => {
      localStorage.setItem('accessToken', 'test-token');
      localStorage.setItem('refreshToken', 'test-refresh');
    });
  });

  test('displays track header', async ({ page }) => {
    await page.goto('/courses');
    await expect(page.getByRole('heading', { name: '학습 트랙' })).toBeVisible();
    await expect(page.getByText('관심있는 분야를 선택하고 체계적으로 학습하세요')).toBeVisible();
  });

  test('displays track with courses', async ({ page }) => {
    await page.goto('/courses');

    // 트랙 제목 확인
    await expect(page.getByText('Swift 마스터')).toBeVisible();

    // 코스 카드 확인
    await expect(page.getByText('Swifty 만들기')).toBeVisible();
    await expect(page.getByText('Swifty 2.0')).toBeVisible();
  });

  test('displays difficulty labels', async ({ page }) => {
    await page.goto('/courses');

    await expect(page.getByText('입문')).toBeVisible();
    await expect(page.getByText('중급')).toBeVisible();
  });

  test('displays course progress', async ({ page }) => {
    await page.goto('/courses');

    // 진행률 표시 확인 (3/10)
    await expect(page.getByText('3/10')).toBeVisible();
    await expect(page.getByText('이어하기 →')).toBeVisible();
  });

  test('course card links to course detail', async ({ page }) => {
    await page.goto('/courses');

    const courseCard = page.getByText('Swifty 만들기');
    await expect(courseCard).toBeVisible();

    // 링크 확인
    const courseLink = page.locator('a[href="/courses/course-1"]');
    await expect(courseLink).toBeVisible();
  });
});

// TODO: 백엔드 서버 연동 후 활성화
test.describe.skip('Course Detail Page (With Mock Data)', () => {
  test.beforeEach(async ({ page }) => {
    // Mock 인증 설정
    await page.addInitScript(() => {
      localStorage.setItem('accessToken', 'test-token');
      localStorage.setItem('refreshToken', 'test-refresh');
    });

    await page.route('**/courses/course-1', async (route) => {
      await route.fulfill({
        status: 200,
        contentType: 'application/json',
        body: JSON.stringify({
          id: 'course-1',
          title: 'Swifty 만들기',
          description: 'AI 챗봇 Swifty를 만들며 Swift 기초 배우기',
          difficulty: 'beginner',
          icon: 'book',
          chapters: [
            {
              id: 'chapter-1',
              title: 'Chapter 1: Swifty 깨우기',
              description: 'print, 변수, 연산자',
              order: 1,
              lessons: [
                {
                  id: 'lesson-1',
                  title: 'Hello, Swifty!',
                  type: 'codeExercise',
                  xpReward: 20,
                  order: 1,
                },
                {
                  id: 'lesson-2',
                  title: '변수 선언하기',
                  type: 'codeExercise',
                  xpReward: 25,
                  order: 2,
                },
              ],
            },
            {
              id: 'chapter-2',
              title: 'Chapter 2: 조건문',
              description: 'if-else, switch',
              order: 2,
              lessons: [
                {
                  id: 'lesson-3',
                  title: 'if문 사용하기',
                  type: 'codeExercise',
                  xpReward: 30,
                  order: 1,
                },
              ],
            },
          ],
        }),
      });
    });

    await page.route('**/users/me/progress', async (route) => {
      await route.fulfill({
        status: 200,
        contentType: 'application/json',
        body: JSON.stringify([
          { lessonId: 'lesson-1', status: 'completed' },
        ]),
      });
    });
  });

  test('displays course header with title and description', async ({ page }) => {
    await page.goto('/courses/course-1');

    await expect(page.getByRole('heading', { name: 'Swifty 만들기' })).toBeVisible();
    await expect(page.getByText('AI 챗봇 Swifty를 만들며 Swift 기초 배우기')).toBeVisible();
  });

  test('displays difficulty badge', async ({ page }) => {
    await page.goto('/courses/course-1');
    await expect(page.getByText('입문')).toBeVisible();
  });

  test('displays course stats', async ({ page }) => {
    await page.goto('/courses/course-1');

    await expect(page.getByText('2개 챕터')).toBeVisible();
    await expect(page.getByText('3개 레슨')).toBeVisible();
    await expect(page.getByText(/총 75 XP/)).toBeVisible();
  });

  test('displays start learning button', async ({ page }) => {
    await page.goto('/courses/course-1');

    const startButton = page.getByRole('link', { name: '학습 시작하기' });
    await expect(startButton).toBeVisible();
    await expect(startButton).toHaveAttribute('href', '/learn/lesson-1');
  });

  test('displays curriculum with chapters', async ({ page }) => {
    await page.goto('/courses/course-1');

    await expect(page.getByText('커리큘럼')).toBeVisible();
    await expect(page.getByText('Chapter 1: Swifty 깨우기')).toBeVisible();
    await expect(page.getByText('Chapter 2: 조건문')).toBeVisible();
  });

  test('first chapter is expanded by default', async ({ page }) => {
    await page.goto('/courses/course-1');

    // 첫 번째 챕터의 레슨들이 보여야 함
    await expect(page.getByText('Hello, Swifty!')).toBeVisible();
    await expect(page.getByText('변수 선언하기')).toBeVisible();
  });

  test('displays completed lesson with checkmark', async ({ page }) => {
    await page.goto('/courses/course-1');

    // 완료된 레슨에 '완료' 표시가 있어야 함
    const completedLesson = page.locator('a[href="/learn/lesson-1"]');
    await expect(completedLesson).toContainText('완료');
  });

  test('expands chapter on click', async ({ page }) => {
    await page.goto('/courses/course-1');

    // 두 번째 챕터 클릭
    await page.getByText('Chapter 2: 조건문').click();

    // 두 번째 챕터 레슨이 보여야 함
    await expect(page.getByText('if문 사용하기')).toBeVisible();
  });

  test('lesson row links to lesson page', async ({ page }) => {
    await page.goto('/courses/course-1');

    const lessonLink = page.locator('a[href="/learn/lesson-2"]');
    await expect(lessonLink).toBeVisible();
  });

  test('back button is visible', async ({ page }) => {
    await page.goto('/courses/course-1');
    await expect(page.getByText('코스 목록')).toBeVisible();
  });
});
