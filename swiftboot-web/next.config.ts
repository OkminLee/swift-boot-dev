import type { NextConfig } from "next";

const nextConfig: NextConfig = {
  // 이미지 최적화 설정
  images: {
    remotePatterns: [
      {
        protocol: "https",
        hostname: "avatars.githubusercontent.com",
        pathname: "/**",
      },
      {
        protocol: "https",
        hostname: "github.com",
        pathname: "/**",
      },
    ],
    // 이미지 포맷 최적화
    formats: ["image/avif", "image/webp"],
  },

  // 실험적 기능
  experimental: {
    // 빌드 최적화
    optimizePackageImports: ["@monaco-editor/react", "react-syntax-highlighter"],
  },

  // 번들 분석 (개발 시에만 사용)
  ...(process.env.ANALYZE === "true" && {
    webpack: (config, { isServer }) => {
      if (!isServer) {
        // 클라이언트 번들 분석
        const { BundleAnalyzerPlugin } = require("webpack-bundle-analyzer");
        config.plugins.push(
          new BundleAnalyzerPlugin({
            analyzerMode: "static",
            reportFilename: "./analyze/client.html",
            openAnalyzer: false,
          })
        );
      }
      return config;
    },
  }),

  // 압축
  compress: true,

  // 파워드 바이 헤더 제거
  poweredByHeader: false,
};

export default nextConfig;
