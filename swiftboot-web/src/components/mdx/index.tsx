"use client";

import { Hint } from "./Hint";
import { Warning } from "./Warning";
import { Info } from "./Info";
import { CodeBlock, InlineCode } from "./CodeBlock";
import { Prism as SyntaxHighlighter } from "react-syntax-highlighter";
import { vscDarkPlus } from "react-syntax-highlighter/dist/esm/styles/prism";
import { ComponentProps, ReactNode } from "react";

// MDX에서 사용할 컴포넌트 매핑
export const mdxComponents = {
  // 커스텀 컴포넌트
  Hint,
  Warning,
  Info,
  CodeBlock,

  // 기본 마크다운 요소 스타일링
  h1: ({ children }: { children?: ReactNode }) => (
    <h1 className="text-2xl font-bold text-[var(--text-primary)] mb-4">{children}</h1>
  ),
  h2: ({ children }: { children?: ReactNode }) => (
    <h2 className="text-xl font-semibold text-[var(--text-primary)] mt-6 mb-3">{children}</h2>
  ),
  h3: ({ children }: { children?: ReactNode }) => (
    <h3 className="text-lg font-semibold text-[var(--text-primary)] mt-5 mb-2">{children}</h3>
  ),
  p: ({ children }: { children?: ReactNode }) => (
    <p className="text-[var(--text-secondary)] mb-4 leading-relaxed">{children}</p>
  ),
  ul: ({ children }: { children?: ReactNode }) => (
    <ul className="list-disc list-inside text-[var(--text-secondary)] mb-4 space-y-1">{children}</ul>
  ),
  ol: ({ children }: { children?: ReactNode }) => (
    <ol className="list-decimal list-inside text-[var(--text-secondary)] mb-4 space-y-1">{children}</ol>
  ),
  li: ({ children }: { children?: ReactNode }) => (
    <li className="text-[var(--text-secondary)]">{children}</li>
  ),
  blockquote: ({ children }: { children?: ReactNode }) => (
    <blockquote className="border-l-4 border-[var(--accent-primary)] pl-4 italic text-[var(--text-secondary)] my-4">
      {children}
    </blockquote>
  ),
  a: ({ href, children }: { href?: string; children?: ReactNode }) => (
    <a
      href={href}
      className="text-[var(--accent-primary)] hover:underline"
      target="_blank"
      rel="noopener noreferrer"
    >
      {children}
    </a>
  ),
  strong: ({ children }: { children?: ReactNode }) => (
    <strong className="font-semibold text-[var(--text-primary)]">{children}</strong>
  ),
  em: ({ children }: { children?: ReactNode }) => (
    <em className="italic">{children}</em>
  ),
  hr: () => <hr className="my-6 border-[var(--border-default)]" />,

  // 코드 블록 처리
  code: ({ className, children }: { className?: string; children?: ReactNode }) => {
    const match = /language-(\w+)/.exec(className || "");
    const isInline = !match;

    if (isInline) {
      return <InlineCode>{children}</InlineCode>;
    }

    return (
      <SyntaxHighlighter
        style={vscDarkPlus}
        language={match[1]}
        PreTag="div"
        customStyle={{
          margin: 0,
          borderRadius: "8px",
          fontSize: "14px",
        }}
      >
        {String(children).replace(/\n$/, "")}
      </SyntaxHighlighter>
    );
  },
  pre: ({ children }: { children?: ReactNode }) => (
    <div className="mb-4">{children}</div>
  ),

  // 테이블
  table: ({ children }: { children?: ReactNode }) => (
    <div className="my-4 overflow-x-auto">
      <table className="min-w-full border-collapse border border-[var(--border-default)] rounded-lg overflow-hidden">
        {children}
      </table>
    </div>
  ),
  thead: ({ children }: { children?: ReactNode }) => (
    <thead className="bg-[var(--bg-tertiary)]">{children}</thead>
  ),
  tbody: ({ children }: { children?: ReactNode }) => (
    <tbody>{children}</tbody>
  ),
  tr: ({ children }: { children?: ReactNode }) => (
    <tr className="border-b border-[var(--border-default)]">{children}</tr>
  ),
  th: ({ children }: { children?: ReactNode }) => (
    <th className="px-4 py-2 text-left font-semibold text-[var(--text-primary)] border-r border-[var(--border-default)] last:border-r-0">
      {children}
    </th>
  ),
  td: ({ children }: { children?: ReactNode }) => (
    <td className="px-4 py-2 text-[var(--text-secondary)] border-r border-[var(--border-default)] last:border-r-0">
      {children}
    </td>
  ),
};

// 개별 export
export { Hint, Warning, Info, CodeBlock, InlineCode };
