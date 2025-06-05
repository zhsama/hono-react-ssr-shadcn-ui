import build from "@hono/vite-cloudflare-pages";
import devServer from "@hono/vite-dev-server";
import adapter from "@hono/vite-dev-server/cloudflare";
import preserveDirectives from "rollup-preserve-directives";
import { defineConfig } from "vite";
import path from "path";

export default defineConfig(({ mode }) => {
  const isDocker = process.env.DOCKER_ENV === "true";

  if (mode === "client") {
    return {
      plugins: [preserveDirectives()],
      build: {
        manifest: true,
        assetsDir: "static",
        rollupOptions: {
          input: "./src/client.tsx",
          output: {
            entryFileNames: "static/client-[hash].js",
            manualChunks: {
              vendor: [
                "react",
                "react-dom",
                "@date-fns/utc",
                "@radix-ui/react-label",
                "@radix-ui/react-select",
                "@radix-ui/react-slot",
                "axios",
                "class-variance-authority",
                "clsx",
                "lucide-react",
                "next-themes",
                "react-share",
                "remarkable",
                "sonner",
                "tailwind-merge",
                "tailwindcss-animate",
              ],
            },
          },
        },
      },
      resolve: {
        alias: {
          "@": path.resolve(__dirname, "./src"),
        },
      },
    };
  } else {
    const plugins = [preserveDirectives()];

    // 在 Docker 环境中不使用 Cloudflare Workers
    if (!isDocker) {
      plugins.push(
        build(),
        devServer({
          adapter,
          entry: "src/index.tsx",
        }),
      );
    }

    return {
      plugins,
      ssr: {
        external: ["react", "react-dom"],
      },
      resolve: {
        alias: {
          "@": path.resolve(__dirname, "./src"),
        },
      },
      server: {
        host: "0.0.0.0",
        port: 5173,
      },
    };
  }
});
