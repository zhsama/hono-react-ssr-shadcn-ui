# Hono React SSR with Shadcn UI

一个基于 Hono.js 的全栈 React SSR 应用，集成了 Shadcn UI 组件库和 Tailwind CSS。

## 🚀 快速开始

### 开发环境

```bash
# 安装依赖
pnpm install

# 启动开发服务器
pnpm run dev

# 或使用 Docker 开发环境
docker-compose -f docker/docker-compose.yml up dev
```

### 生产构建

```bash
# 构建应用
pnpm run build

# 预览构建结果
pnpm run preview

# 部署到 Cloudflare Pages
pnpm run deploy
```

## 📁 项目结构

```
hono-react-ssr-shadcn-ui/
├── src/                          # 源代码
│   ├── components/               # React 组件
│   │   └── ui/                   # Shadcn UI 组件
│   ├── view/                     # 页面组件
│   ├── lib/                      # 工具函数
│   ├── config/                   # 配置文件
│   ├── index.tsx                 # 服务器入口
│   ├── client.tsx                # 客户端入口
│   └── view.tsx                  # 视图映射
├── public/                       # 静态资源
├── docker/                       # Docker 相关文件
│   ├── examples/                 # 各种 Dockerfile 示例
│   ├── scripts/                  # Docker 管理脚本
│   ├── docker-compose.yml        # 开发环境配置
│   └── docker-compose.monorepo.yml # Monorepo 配置
├── docs/                         # 项目文档
│   ├── docker/                   # Docker 相关文档
│   ├── deployment/               # 部署相关文档
│   └── development/              # 开发相关文档
├── package.json                  # 项目配置
├── vite.config.ts                # Vite 配置
├── tailwind.config.js            # Tailwind CSS 配置
└── tsconfig.json                 # TypeScript 配置
```

## 🛠️ 技术栈

- **框架**: [Hono.js](https://hono.dev/) - 轻量级 Web 框架
- **前端**: [React 19](https://react.dev/) - 现代化 React 应用
- **样式**: [Tailwind CSS 4](https://tailwindcss.com/) + [Shadcn UI](https://ui.shadcn.com/)
- **构建**: [Vite](https://vitejs.dev/) - 快速构建工具
- **部署**: [Cloudflare Pages](https://pages.cloudflare.com/) - Edge Runtime 部署
- **容器**: [Docker](https://www.docker.com/) - 本地开发环境

## 📝 开发指南

### 添加新页面

1. 在 `src/view/` 创建页面组件
2. 在 `src/view.tsx` 注册页面映射
3. 在 `src/index.tsx` 添加路由

### Docker 开发

查看 [Docker 文档](./docs/docker/) 了解详细的容器化开发指南。

### 部署指南

查看 [部署文档](./docs/deployment/) 了解 Cloudflare Pages 和其他部署选项。

## 🤝 贡献

欢迎提交 Pull Request 和 Issue！

## �� 许可证

MIT License
