import type { Metadata, Viewport } from "next";
import { Inter, JetBrains_Mono } from "next/font/google";
import { Providers } from "./providers";
import "./globals.css";

const inter = Inter({
  variable: "--font-inter",
  subsets: ["latin"],
  display: "swap",
});

const jetbrainsMono = JetBrains_Mono({
  variable: "--font-jetbrains-mono",
  subsets: ["latin"],
  display: "swap",
});

export const metadata: Metadata = {
  title: {
    default: "SwiftBoot - Learn to Code with Games",
    template: "%s | SwiftBoot",
  },
  description:
    "Boot.dev 스타일의 게이미피케이션 코딩 교육 플랫폼. Swift, Python, Go, JavaScript를 재미있게 배워보세요.",
  keywords: ["coding", "learn", "swift", "vapor", "gamification", "boot.dev", "프로그래밍", "코딩 교육"],
  authors: [{ name: "SwiftBoot Team" }],
  creator: "SwiftBoot",
  publisher: "SwiftBoot",
  formatDetection: {
    email: false,
    telephone: false,
  },
  metadataBase: new URL(process.env.NEXT_PUBLIC_APP_URL || "http://localhost:3000"),
  openGraph: {
    type: "website",
    locale: "ko_KR",
    siteName: "SwiftBoot",
    title: "SwiftBoot - Learn to Code with Games",
    description: "게이미피케이션 코딩 교육 플랫폼. Swift, Python, Go, JavaScript를 재미있게 배워보세요.",
  },
  twitter: {
    card: "summary_large_image",
    title: "SwiftBoot - Learn to Code with Games",
    description: "게이미피케이션 코딩 교육 플랫폼",
  },
  robots: {
    index: true,
    follow: true,
    googleBot: {
      index: true,
      follow: true,
      "max-video-preview": -1,
      "max-image-preview": "large",
      "max-snippet": -1,
    },
  },
};

export const viewport: Viewport = {
  width: "device-width",
  initialScale: 1,
  maximumScale: 5,
  themeColor: [
    { media: "(prefers-color-scheme: dark)", color: "#1E1E1E" },
  ],
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="ko" className="dark">
      <body
        className={`${inter.variable} ${jetbrainsMono.variable} antialiased min-h-screen`}
      >
        <Providers>{children}</Providers>
      </body>
    </html>
  );
}
