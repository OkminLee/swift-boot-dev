"use client";

import ReactMarkdown, { Components } from "react-markdown";
import remarkGfm from "remark-gfm";
import remarkDirective from "remark-directive";
import { visit } from "unist-util-visit";
import { Hint } from "./Hint";
import { Warning } from "./Warning";
import { Info } from "./Info";
import { CodeBlock, InlineCode } from "./CodeBlock";
import { ReactNode, ReactElement } from "react";

// remark 플러그인: directive를 HTML 노드로 변환
function remarkCustomDirectives() {
  return (tree: unknown) => {
    visit(tree as never, (node: { type: string; name?: string; data?: Record<string, unknown>; attributes?: { title?: string } }) => {
      if (
        node.type === "containerDirective" ||
        node.type === "leafDirective" ||
        node.type === "textDirective"
      ) {
        const data = node.data || (node.data = {});
        const tagName = node.name;

        // 지원하는 directive들
        if (tagName && ["hint", "warning", "info", "note"].includes(tagName)) {
          data.hName = tagName;
          data.hProperties = {
            title: node.attributes?.title || undefined,
          };
        }
      }
    });
  };
}

interface MdxRendererProps {
  content: string;
  className?: string;
}

// 공통 Props 타입
interface ChildrenProps {
  children?: ReactNode;
}

interface CodeProps {
  className?: string;
  children?: ReactNode;
}

interface AnchorProps extends ChildrenProps {
  href?: string;
}

interface DirectiveProps extends ChildrenProps {
  title?: string;
}

// 커스텀 컴포넌트 타입 확장
type CustomComponents = Components & {
  hint: (props: DirectiveProps) => ReactElement;
  warning: (props: DirectiveProps) => ReactElement;
  info: (props: DirectiveProps) => ReactElement;
  note: (props: DirectiveProps) => ReactElement;
};

export function MdxRenderer({ content, className }: MdxRendererProps) {
  const components: CustomComponents = {
    // 커스텀 directive 컴포넌트
    hint: ({ children, title }: DirectiveProps) => (
      <Hint title={title}>{children}</Hint>
    ),
    warning: ({ children, title }: DirectiveProps) => (
      <Warning title={title}>{children}</Warning>
    ),
    info: ({ children, title }: DirectiveProps) => (
      <Info title={title}>{children}</Info>
    ),
    note: ({ children, title }: DirectiveProps) => (
      <Info title={title || "노트"}>{children}</Info>
    ),

    // 기본 마크다운 요소 스타일링
    h1: ({ children }: ChildrenProps) => (
      <h1 className="text-2xl font-bold text-[var(--text-primary)] mb-4">{children}</h1>
    ),
    h2: ({ children }: ChildrenProps) => (
      <h2 className="text-xl font-semibold text-[var(--text-primary)] mt-6 mb-3">{children}</h2>
    ),
    h3: ({ children }: ChildrenProps) => (
      <h3 className="text-lg font-semibold text-[var(--text-primary)] mt-5 mb-2">{children}</h3>
    ),
    p: ({ children }: ChildrenProps) => (
      <p className="text-[var(--text-secondary)] mb-4 leading-relaxed">{children}</p>
    ),
    ul: ({ children }: ChildrenProps) => (
      <ul className="list-disc list-inside text-[var(--text-secondary)] mb-4 space-y-1">{children}</ul>
    ),
    ol: ({ children }: ChildrenProps) => (
      <ol className="list-decimal list-inside text-[var(--text-secondary)] mb-4 space-y-1">{children}</ol>
    ),
    li: ({ children }: ChildrenProps) => (
      <li className="text-[var(--text-secondary)]">{children}</li>
    ),
    blockquote: ({ children }: ChildrenProps) => (
      <blockquote className="border-l-4 border-[var(--accent-primary)] pl-4 italic text-[var(--text-secondary)] my-4">
        {children}
      </blockquote>
    ),
    a: ({ href, children }: AnchorProps) => (
      <a
        href={href}
        className="text-[var(--accent-primary)] hover:underline"
        target="_blank"
        rel="noopener noreferrer"
      >
        {children}
      </a>
    ),
    strong: ({ children }: ChildrenProps) => (
      <strong className="font-semibold text-[var(--text-primary)]">{children}</strong>
    ),
    em: ({ children }: ChildrenProps) => (
      <em className="italic">{children}</em>
    ),
    hr: () => <hr className="my-6 border-[var(--border-default)]" />,

    // 코드 블록 처리
    code: ({ className: codeClassName, children }: CodeProps) => {
      const match = /language-(\w+)/.exec(codeClassName || "");
      const isInline = !match && !codeClassName;

      if (isInline) {
        return <InlineCode>{children}</InlineCode>;
      }

      const language = match ? match[1] : "text";
      const code = String(children).replace(/\n$/, "");

      return (
        <CodeBlock language={language}>
          {code}
        </CodeBlock>
      );
    },
    pre: ({ children }: ChildrenProps) => <>{children}</>,

    // 테이블
    table: ({ children }: ChildrenProps) => (
      <div className="my-4 overflow-x-auto">
        <table className="min-w-full border-collapse border border-[var(--border-default)] rounded-lg overflow-hidden">
          {children}
        </table>
      </div>
    ),
    thead: ({ children }: ChildrenProps) => (
      <thead className="bg-[var(--bg-tertiary)]">{children}</thead>
    ),
    tbody: ({ children }: ChildrenProps) => (
      <tbody>{children}</tbody>
    ),
    tr: ({ children }: ChildrenProps) => (
      <tr className="border-b border-[var(--border-default)]">{children}</tr>
    ),
    th: ({ children }: ChildrenProps) => (
      <th className="px-4 py-2 text-left font-semibold text-[var(--text-primary)] border-r border-[var(--border-default)] last:border-r-0">
        {children}
      </th>
    ),
    td: ({ children }: ChildrenProps) => (
      <td className="px-4 py-2 text-[var(--text-secondary)] border-r border-[var(--border-default)] last:border-r-0">
        {children}
      </td>
    ),
  };

  return (
    <div className={`prose prose-invert max-w-none ${className || ""}`}>
      <ReactMarkdown
        remarkPlugins={[remarkGfm, remarkDirective, remarkCustomDirectives]}
        components={components as Components}
      >
        {content}
      </ReactMarkdown>
    </div>
  );
}
