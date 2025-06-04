# Docker 部署指南

本指南介绍如何使用多阶段构建的 Dockerfile 来构建和运行 Hono.js React SSR 应用。

## 🏗️ 构建特性

### 多阶段构建优势

- **构建阶段**：包含完整的开发环境和构建工具
- **运行阶段**：仅包含运行时必需的文件和依赖
- **镜像体积减少**：通过分离构建和运行环境，显著减小最终镜像大小

### 优化策略

1. **依赖缓存**：利用 Docker 层缓存和 pnpm 缓存
2. **生产依赖**：运行阶段仅安装生产环境依赖
3. **文件过滤**：通过 `.dockerignore` 排除不必要文件
4. **非 root 用户**：使用专用用户提升安全性
5. **健康检查**：内置应用健康状态监控

## 🚀 快速开始

### 构建镜像

```bash
# 构建镜像
docker build -t hono-react-app .

# 构建时指定平台（用于 M1/M2 Mac）
docker build --platform linux/amd64 -t hono-react-app .
```

### 运行容器

```bash
# 基本运行
docker run -p 8787:8787 hono-react-app

# 后台运行
docker run -d -p 8787:8787 --name hono-app hono-react-app

# 带环境变量运行
docker run -p 8787:8787 -e NODE_ENV=production hono-react-app
```

### 容器管理

```bash
# 查看运行状态
docker ps

# 查看日志
docker logs hono-app

# 进入容器
docker exec -it hono-app sh

# 停止容器
docker stop hono-app

# 删除容器
docker rm hono-app
```

## 🔧 开发和调试

### 开发模式构建

```bash
# 构建开发版本（包含调试信息）
docker build --target builder -t hono-react-dev .

# 运行开发容器
docker run -it --rm -p 5173:5173 hono-react-dev pnpm run dev
```

### 查看镜像信息

```bash
# 查看镜像大小
docker images hono-react-app

# 分析镜像层
docker history hono-react-app

# 检查镜像内容
docker run --rm -it hono-react-app sh
```

## 📊 性能监控

### 健康检查

容器内置了健康检查机制，每30秒检查一次应用状态：

```bash
# 查看健康状态
docker inspect --format='{{.State.Health.Status}}' hono-app
```

### 资源监控

```bash
# 监控容器资源使用
docker stats hono-app

# 查看容器进程
docker top hono-app
```

## 🐳 Docker Compose 示例

创建 `docker-compose.yml` 文件：

```yaml
version: '3.8'

services:
  app:
    build: .
    ports:
      - "8787:8787"
    environment:
      - NODE_ENV=production
    restart: unless-stopped
    healthcheck:
      test: ["CMD", "node", "-e", "http.get('http://localhost:8787/', (res) => { process.exit(res.statusCode === 200 ? 0 : 1) })"]
      interval: 30s
      timeout: 3s
      retries: 3
      start_period: 5s
```

运行：

```bash
docker-compose up -d
```

## 🔒 安全最佳实践

1. **非 root 用户**：应用以 `hono` 用户身份运行
2. **最小权限**：仅包含运行时必需的文件
3. **健康检查**：监控应用状态
4. **信号处理**：使用 tini 作为 init 进程

## 🚀 生产部署

### 构建优化

```bash
# 使用 BuildKit 构建（更快）
DOCKER_BUILDKIT=1 docker build -t hono-react-app .

# 多平台构建
docker buildx build --platform linux/amd64,linux/arm64 -t hono-react-app .
```

### 部署到云平台

```bash
# 推送到容器仓库
docker tag hono-react-app your-registry/hono-react-app:latest
docker push your-registry/hono-react-app:latest
```

## 🐛 故障排除

### 常见问题

1. **端口冲突**：确保 8787 端口未被占用
2. **权限问题**：检查文件权限设置
3. **内存不足**：增加 Docker 内存限制

### 调试命令

```bash
# 查看构建过程
docker build --no-cache --progress=plain -t hono-react-app .

# 运行时调试
docker run --rm -it hono-react-app sh
```
