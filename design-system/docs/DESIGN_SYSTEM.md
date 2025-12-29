# SwiftBoot Design System

> "Magical IDE" - 프로페셔널한 IDE + 게이미피케이션 오버레이

## 디렉토리 구조

```
design-system/
├── tokens/              # 디자인 토큰 (Source of Truth)
│   ├── index.json       # 토큰 메타데이터
│   ├── colors.json      # 색상 토큰
│   ├── typography.json  # 타이포그래피 토큰
│   ├── spacing.json     # 스페이싱, 그림자, z-index 등
│   └── animation.json   # 애니메이션, 트랜지션
├── css/
│   └── variables.css    # CSS Custom Properties
├── tailwind.preset.js   # Tailwind CSS 프리셋
└── docs/
    └── DESIGN_SYSTEM.md # 이 문서
```

## 사용 방법

### 1. CSS 변수 사용 (권장)

```css
.my-component {
  background: var(--bg-secondary);
  color: var(--text-primary);
  padding: var(--space-4);
  border-radius: var(--radius-md);
  transition: var(--transition-default);
}
```

### 2. Tailwind CSS 사용

```jsx
// tailwind.config.js
module.exports = {
  presets: [require('./design-system/tailwind.preset.js')],
  content: ['./app/**/*.{ts,tsx}', './components/**/*.{ts,tsx}'],
};
```

```jsx
<div className="bg-bg-secondary text-text-primary p-4 rounded-md transition-all">
  Content
</div>
```

## 색상 팔레트

### 배경색
| 토큰 | 값 | 용도 |
|------|------|------|
| `--bg-primary` | `#1E1E1E` | 메인 배경 |
| `--bg-secondary` | `#252526` | 사이드바/패널 |
| `--bg-editor` | `#1E1E1E` | 코드 에디터 |
| `--bg-terminal` | `#0D1117` | 터미널 |
| `--bg-elevated` | `#2D2D2D` | 카드/모달 |

### 악센트 색상
| 토큰 | 값 | 용도 |
|------|------|------|
| `--accent-primary` | `#007AFF` | 시스템 블루 |
| `--accent-success` | `#34C759` | 성공 |
| `--accent-error` | `#FF3B30` | 에러 |
| `--accent-warning` | `#FF9500` | 경고 |

### 게이미피케이션 색상
| 토큰 | 값 | 용도 |
|------|------|------|
| `--xp-gold` | `#FFD700` | 경험치 |
| `--gem-purple` | `#AF52DE` | Gem |
| `--streak-orange` | `#FF6B35` | 연속 학습 |
| `--level-gradient` | 퍼플 그라데이션 | 레벨 배경 |

## 타이포그래피

### 폰트 패밀리
- **코드**: JetBrains Mono, SF Mono, Fira Code
- **UI**: Inter, -apple-system

### 폰트 크기 스케일
| 토큰 | 크기 | 용도 |
|------|------|------|
| `--font-size-xs` | 12px | 캡션 |
| `--font-size-sm` | 14px | 코드, 작은 텍스트 |
| `--font-size-base` | 16px | 본문 |
| `--font-size-xl` | 20px | 소제목 |
| `--font-size-3xl` | 30px | 페이지 제목 |

## 스페이싱 (8px 기반)

| 토큰 | 값 | 용도 |
|------|------|------|
| `--space-1` | 4px | 아이콘 간격 |
| `--space-2` | 8px | 기본 작은 간격 |
| `--space-4` | 16px | 기본 중간 간격 |
| `--space-6` | 24px | 기본 큰 간격 |
| `--space-8` | 32px | 섹션 간격 |

## 애니메이션

### 지속 시간
| 토큰 | 값 | 용도 |
|------|------|------|
| `--duration-fast` | 150ms | 호버, 포커스 |
| `--duration-normal` | 250ms | 일반 전환 |
| `--duration-slow` | 350ms | 모달 열기 |
| `--duration-celebration` | 1000ms | 레벨업, 상자 개봉 |

### 키프레임 애니메이션
- `fadeIn/fadeOut`: 페이드 효과
- `slideUp/slideDown`: 슬라이드 효과
- `scaleIn`: 모달 열기
- `shake`: 에러 피드백
- `glow`: XP 획득
- `float`: 상자 부유

## 게이미피케이션 피드백

| 이벤트 | 시각적 피드백 | 효과 |
|--------|--------------|------|
| 정답 | Confetti + 글로우 | `canvas-confetti` |
| 오답 | Shake + 빨간 글로우 | `animation: shake` |
| 레벨업 | 골든 오버레이 | `animation: level-up` |
| XP 획득 | 숫자 플로팅 | `animation: xp-gain` |
| Chest | 부유 애니메이션 | `animation: float` |

## 반응형 브레이크포인트

| 이름 | 값 | 대상 |
|------|------|------|
| `sm` | 640px | 모바일 |
| `md` | 768px | 태블릿 |
| `lg` | 1024px | 노트북 |
| `xl` | 1280px | 데스크탑 |
| `2xl` | 1536px | 대형 모니터 |

## 아이콘

**Lucide Icons** 사용 (https://lucide.dev)

```jsx
import { Play, Check, X, Trophy, Flame } from 'lucide-react';

<Play className="w-5 h-5 text-accent-primary" />
```

## 참고 자료

- [Apple Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/)
- [VS Code Theme Color Reference](https://code.visualstudio.com/api/references/theme-color)
- [Boot.dev](https://boot.dev) - 벤치마킹 대상
