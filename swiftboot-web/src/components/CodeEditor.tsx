"use client";

import { useRef, useCallback, useEffect } from "react";
import dynamic from "next/dynamic";
import type { OnMount, OnChange } from "@monaco-editor/react";
import type { editor } from "monaco-editor";
import { swiftbootTheme, languageDefaults } from "@/lib/monaco-theme";
import { Language } from "@/lib/api";

// Monaco Editor 동적 import (코드 스플리팅)
const Editor = dynamic(() => import("@monaco-editor/react").then(mod => mod.default), {
  ssr: false,
  loading: () => (
    <div className="flex items-center justify-center h-full bg-[var(--bg-editor)]">
      <div className="flex items-center gap-2 text-[var(--text-secondary)]">
        <div className="animate-spin w-5 h-5 border-2 border-[var(--accent-primary)] border-t-transparent rounded-full" />
        <span>에디터 로딩 중...</span>
      </div>
    </div>
  ),
});

export type { Language };

interface CodeEditorProps {
  language: Language;
  value: string;
  onChange?: (value: string) => void;
  readOnly?: boolean;
  height?: string;
  className?: string;
}

export function CodeEditor({
  language,
  value,
  onChange,
  readOnly = false,
  height = "300px",
  className = "",
}: CodeEditorProps) {
  const editorRef = useRef<editor.IStandaloneCodeEditor | null>(null);
  const monacoRef = useRef<typeof import("monaco-editor") | null>(null);

  const handleEditorMount: OnMount = useCallback((editor, monaco) => {
    editorRef.current = editor;
    monacoRef.current = monaco;

    // 커스텀 테마 등록
    monaco.editor.defineTheme("swiftboot", swiftbootTheme);
    monaco.editor.setTheme("swiftboot");

    // 에디터 포커스
    editor.focus();
  }, []);

  const handleChange: OnChange = useCallback(
    (newValue) => {
      if (onChange && newValue !== undefined) {
        onChange(newValue);
      }
    },
    [onChange]
  );

  // 언어 변경 시 에디터 옵션 업데이트
  useEffect(() => {
    if (editorRef.current && monacoRef.current) {
      const model = editorRef.current.getModel();
      if (model) {
        monacoRef.current.editor.setModelLanguage(model, language);
      }
    }
  }, [language]);

  // 언어별 기본 설정
  const langDefaults = languageDefaults[language] || {};

  return (
    <div className={`rounded-lg overflow-hidden border border-[var(--border-default)] ${className}`}>
      <Editor
        height={height}
        language={language}
        value={value}
        onChange={handleChange}
        onMount={handleEditorMount}
        theme="vs-dark" // 초기 테마 (마운트 후 swiftboot로 변경)
        options={{
          // 기본 설정
          fontSize: 14,
          fontFamily: "var(--font-jetbrains-mono), 'JetBrains Mono', Menlo, Monaco, monospace",
          fontLigatures: true,
          lineHeight: 22,

          // 읽기 전용
          readOnly,

          // 미니맵
          minimap: { enabled: false },

          // 스크롤
          scrollBeyondLastLine: false,
          scrollbar: {
            vertical: "auto",
            horizontal: "auto",
            verticalScrollbarSize: 10,
            horizontalScrollbarSize: 10,
          },

          // 줄 번호
          lineNumbers: "on",
          lineNumbersMinChars: 3,
          glyphMargin: false,
          folding: true,

          // 들여쓰기
          guides: {
            indentation: true,
            bracketPairs: true,
          },
          ...langDefaults,

          // 자동완성
          quickSuggestions: !readOnly,
          suggestOnTriggerCharacters: !readOnly,
          acceptSuggestionOnEnter: "on",
          tabCompletion: "on",

          // 괄호
          autoClosingBrackets: "always",
          autoClosingQuotes: "always",
          matchBrackets: "always",

          // 커서
          cursorBlinking: "smooth",
          cursorSmoothCaretAnimation: "on",

          // 기타
          wordWrap: "off",
          contextmenu: true,
          automaticLayout: true,
          padding: { top: 12, bottom: 12 },
        }}
      />
    </div>
  );
}

// 결과 출력용 읽기 전용 에디터
interface OutputViewerProps {
  output: string;
  isError?: boolean;
  height?: string;
  className?: string;
}

export function OutputViewer({
  output,
  isError = false,
  height = "120px",
  className = "",
}: OutputViewerProps) {
  return (
    <div
      className={`rounded-lg overflow-hidden border ${
        isError ? "border-[var(--error-red)]" : "border-[var(--border-default)]"
      } ${className}`}
    >
      <div
        className={`px-3 py-2 text-xs font-medium ${
          isError
            ? "bg-[var(--error-red)]/10 text-[var(--error-red)]"
            : "bg-[var(--bg-terminal)] text-[var(--text-secondary)]"
        }`}
      >
        {isError ? "Error" : "Output"}
      </div>
      <pre
        className={`p-4 text-sm font-mono overflow-auto ${
          isError ? "text-[var(--error-red)]" : "text-[var(--text-primary)]"
        }`}
        style={{
          height,
          backgroundColor: "var(--bg-terminal)",
          margin: 0,
        }}
      >
        {output || (isError ? "에러가 발생했습니다." : "출력 없음")}
      </pre>
    </div>
  );
}
