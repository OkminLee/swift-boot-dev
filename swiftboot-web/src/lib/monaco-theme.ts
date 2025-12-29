import type { editor } from "monaco-editor";

// SwiftBoot 커스텀 Monaco 테마
export const swiftbootTheme: editor.IStandaloneThemeData = {
  base: "vs-dark",
  inherit: true,
  rules: [
    // 키워드: let, var, func, class, struct, enum, if, else, for, while, return
    { token: "keyword", foreground: "C678DD", fontStyle: "bold" },
    { token: "keyword.control", foreground: "C678DD" },

    // 문자열
    { token: "string", foreground: "98C379" },
    { token: "string.escape", foreground: "56B6C2" },

    // 숫자
    { token: "number", foreground: "D19A66" },
    { token: "number.float", foreground: "D19A66" },

    // 주석
    { token: "comment", foreground: "5C6370", fontStyle: "italic" },
    { token: "comment.line", foreground: "5C6370", fontStyle: "italic" },
    { token: "comment.block", foreground: "5C6370", fontStyle: "italic" },

    // 함수
    { token: "function", foreground: "61AFEF" },
    { token: "function.call", foreground: "61AFEF" },

    // 타입
    { token: "type", foreground: "E5C07B" },
    { token: "type.identifier", foreground: "E5C07B" },
    { token: "class", foreground: "E5C07B" },

    // 연산자
    { token: "operator", foreground: "56B6C2" },
    { token: "delimiter", foreground: "ABB2BF" },

    // 변수
    { token: "variable", foreground: "E06C75" },
    { token: "variable.parameter", foreground: "E06C75" },
    { token: "identifier", foreground: "ABB2BF" },

    // 상수
    { token: "constant", foreground: "D19A66" },

    // 기타
    { token: "attribute.name", foreground: "D19A66" },
    { token: "attribute.value", foreground: "98C379" },
    { token: "tag", foreground: "E06C75" },
  ],
  colors: {
    // 에디터 배경
    "editor.background": "#1E1E1E",
    "editor.foreground": "#D4D4D4",

    // 선택 영역
    "editor.selectionBackground": "#264F78",
    "editor.selectionHighlightBackground": "#3A3D41",

    // 현재 줄
    "editor.lineHighlightBackground": "#2D2D2D",
    "editor.lineHighlightBorder": "#00000000",

    // 커서
    "editorCursor.foreground": "#007AFF",

    // 줄 번호
    "editorLineNumber.foreground": "#5C6370",
    "editorLineNumber.activeForeground": "#D4D4D4",

    // 들여쓰기 가이드
    "editorIndentGuide.background": "#3C3C3C",
    "editorIndentGuide.activeBackground": "#5C6370",

    // 괄호 매칭
    "editorBracketMatch.background": "#3C3C3C",
    "editorBracketMatch.border": "#007AFF",

    // 스크롤바
    "scrollbarSlider.background": "#3C3C3C80",
    "scrollbarSlider.hoverBackground": "#5C637080",
    "scrollbarSlider.activeBackground": "#80808080",

    // 위젯 (자동완성, 호버 등)
    "editorWidget.background": "#252526",
    "editorWidget.border": "#3C3C3C",
    "editorSuggestWidget.background": "#252526",
    "editorSuggestWidget.border": "#3C3C3C",
    "editorSuggestWidget.selectedBackground": "#3C3C3C",

    // 에러/경고
    "editorError.foreground": "#FF3B30",
    "editorWarning.foreground": "#FF9500",

    // 미니맵
    "minimap.background": "#1E1E1E",
  },
};

// 언어별 기본 설정
export const languageDefaults: Record<string, editor.IStandaloneEditorConstructionOptions> = {
  swift: {
    tabSize: 4,
    insertSpaces: true,
    formatOnPaste: true,
    formatOnType: true,
  },
  python: {
    tabSize: 4,
    insertSpaces: true,
  },
  javascript: {
    tabSize: 2,
    insertSpaces: true,
  },
  go: {
    tabSize: 4,
    insertSpaces: false, // Go는 탭 사용
  },
};
