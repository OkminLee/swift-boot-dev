/**
 * SwiftBoot Tailwind CSS Preset
 *
 * Next.js 프로젝트의 tailwind.config.js에서 이 프리셋을 사용합니다:
 *
 * module.exports = {
 *   presets: [require('../design-system/tailwind.preset.js')],
 *   // ... 추가 설정
 * }
 */

/** @type {import('tailwindcss').Config} */
module.exports = {
  theme: {
    // 색상 - 완전 대체 (디자인 시스템 일관성)
    colors: {
      transparent: 'transparent',
      current: 'currentColor',

      // 배경색
      bg: {
        primary: 'var(--bg-primary)',
        secondary: 'var(--bg-secondary)',
        editor: 'var(--bg-editor)',
        terminal: 'var(--bg-terminal)',
        elevated: 'var(--bg-elevated)',
        hover: 'var(--bg-hover)',
      },

      // 텍스트 색상
      text: {
        primary: 'var(--text-primary)',
        secondary: 'var(--text-secondary)',
        muted: 'var(--text-muted)',
        accent: 'var(--text-accent)',
        inverse: 'var(--text-inverse)',
      },

      // 악센트 색상
      accent: {
        primary: 'var(--accent-primary)',
        success: 'var(--accent-success)',
        error: 'var(--accent-error)',
        warning: 'var(--accent-warning)',
        info: 'var(--accent-info)',
      },

      // 게이미피케이션 색상
      xp: {
        gold: 'var(--xp-gold)',
        glow: 'var(--xp-glow)',
      },
      gem: {
        purple: 'var(--gem-purple)',
        glow: 'var(--gem-glow)',
      },
      streak: {
        orange: 'var(--streak-orange)',
        flame: 'var(--streak-flame)',
      },
      level: {
        start: 'var(--level-gradient-start)',
        end: 'var(--level-gradient-end)',
      },
      chest: {
        common: 'var(--chest-common)',
        rare: 'var(--chest-rare)',
        legendary: 'var(--chest-legendary)',
      },

      // 구문 강조
      syntax: {
        keyword: 'var(--syntax-keyword)',
        string: 'var(--syntax-string)',
        number: 'var(--syntax-number)',
        comment: 'var(--syntax-comment)',
        function: 'var(--syntax-function)',
        type: 'var(--syntax-type)',
        operator: 'var(--syntax-operator)',
      },

      // 보더
      border: {
        DEFAULT: 'var(--border-default)',
        focus: 'var(--border-focus)',
        error: 'var(--border-error)',
      },

      // 기본 색상 (필요시)
      white: '#FFFFFF',
      black: '#000000',
    },

    // 폰트 패밀리 - 완전 대체
    fontFamily: {
      mono: 'var(--font-mono)',
      sans: 'var(--font-sans)',
    },

    // 폰트 크기 - 완전 대체
    fontSize: {
      xs: ['var(--font-size-xs)', { lineHeight: 'var(--line-height-normal)' }],
      sm: ['var(--font-size-sm)', { lineHeight: 'var(--line-height-normal)' }],
      base: ['var(--font-size-base)', { lineHeight: 'var(--line-height-relaxed)' }],
      lg: ['var(--font-size-lg)', { lineHeight: 'var(--line-height-relaxed)' }],
      xl: ['var(--font-size-xl)', { lineHeight: 'var(--line-height-tight)' }],
      '2xl': ['var(--font-size-2xl)', { lineHeight: 'var(--line-height-tight)' }],
      '3xl': ['var(--font-size-3xl)', { lineHeight: 'var(--line-height-tight)' }],
      '4xl': ['var(--font-size-4xl)', { lineHeight: 'var(--line-height-tight)' }],
      '5xl': ['var(--font-size-5xl)', { lineHeight: 'var(--line-height-tight)' }],
    },

    // 폰트 굵기
    fontWeight: {
      normal: 'var(--font-weight-normal)',
      medium: 'var(--font-weight-medium)',
      semibold: 'var(--font-weight-semibold)',
      bold: 'var(--font-weight-bold)',
    },

    // 스페이싱 - 8px 기반
    spacing: {
      0: 'var(--space-0)',
      1: 'var(--space-1)',
      2: 'var(--space-2)',
      3: 'var(--space-3)',
      4: 'var(--space-4)',
      5: 'var(--space-5)',
      6: 'var(--space-6)',
      8: 'var(--space-8)',
      10: 'var(--space-10)',
      12: 'var(--space-12)',
      16: 'var(--space-16)',
      20: 'var(--space-20)',
      24: 'var(--space-24)',
      // 추가 (px 단위)
      px: '1px',
    },

    // 보더 라디우스
    borderRadius: {
      none: 'var(--radius-none)',
      sm: 'var(--radius-sm)',
      DEFAULT: 'var(--radius-md)',
      md: 'var(--radius-md)',
      lg: 'var(--radius-lg)',
      xl: 'var(--radius-xl)',
      '2xl': 'var(--radius-2xl)',
      full: 'var(--radius-full)',
    },

    // 박스 섀도우
    boxShadow: {
      sm: 'var(--shadow-sm)',
      DEFAULT: 'var(--shadow-md)',
      md: 'var(--shadow-md)',
      lg: 'var(--shadow-lg)',
      xl: 'var(--shadow-xl)',
      'glow-primary': 'var(--shadow-glow-primary)',
      'glow-success': 'var(--shadow-glow-success)',
      'glow-xp': 'var(--shadow-glow-xp)',
      none: 'none',
    },

    // Z-index
    zIndex: {
      hide: 'var(--z-hide)',
      base: 'var(--z-base)',
      dropdown: 'var(--z-dropdown)',
      sticky: 'var(--z-sticky)',
      overlay: 'var(--z-overlay)',
      modal: 'var(--z-modal)',
      popover: 'var(--z-popover)',
      tooltip: 'var(--z-tooltip)',
      toast: 'var(--z-toast)',
    },

    // 반응형 브레이크포인트
    screens: {
      sm: '640px',
      md: '768px',
      lg: '1024px',
      xl: '1280px',
      '2xl': '1536px',
    },

    extend: {
      // 애니메이션
      animation: {
        'fade-in': 'fadeIn var(--duration-normal) var(--ease-out)',
        'fade-out': 'fadeOut var(--duration-normal) var(--ease-out)',
        'slide-up': 'slideUp var(--duration-normal) var(--ease-out)',
        'slide-down': 'slideDown var(--duration-normal) var(--ease-out)',
        'scale-in': 'scaleIn var(--duration-slow) var(--ease-spring)',
        pulse: 'pulse var(--duration-celebration) var(--ease-in-out) infinite',
        shake: 'shake var(--duration-fast) var(--ease-in-out)',
        glow: 'glow var(--duration-celebration) var(--ease-in-out) infinite',
        spin: 'spin 1s linear infinite',
        float: 'float 3s var(--ease-in-out) infinite',
        'level-up': 'levelUpBurst var(--duration-celebration) var(--ease-out)',
        'xp-gain': 'xpGain var(--duration-slow) var(--ease-out)',
      },

      // 트랜지션
      transitionDuration: {
        instant: 'var(--duration-instant)',
        fast: 'var(--duration-fast)',
        DEFAULT: 'var(--duration-normal)',
        slow: 'var(--duration-slow)',
        slower: 'var(--duration-slower)',
        celebration: 'var(--duration-celebration)',
      },

      transitionTimingFunction: {
        bounce: 'var(--ease-bounce)',
        spring: 'var(--ease-spring)',
      },

      // 그라데이션
      backgroundImage: {
        'level-gradient': 'var(--level-gradient)',
        'xp-shimmer':
          'linear-gradient(90deg, transparent, rgba(255, 215, 0, 0.3), transparent)',
      },

      // 라인 높이
      lineHeight: {
        tight: 'var(--line-height-tight)',
        normal: 'var(--line-height-normal)',
        relaxed: 'var(--line-height-relaxed)',
        code: 'var(--line-height-code)',
      },
    },
  },
  plugins: [],
};
