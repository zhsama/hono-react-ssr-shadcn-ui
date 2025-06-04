FROM node:20-alpine AS base
ARG PNPM_HOME=/pnpm
ARG PATH=$PNPM_HOME:$PATH

# ==================== 构建阶段 ====================
FROM base AS builder

ARG PNPM_HOME
ARG PATH
RUN corepack enable

WORKDIR /app

COPY package.json pnpm-lock.yaml* ./

RUN --mount=type=cache,id=pnpm,target=/pnpm/store pnpm install --frozen-lockfile

COPY . .

RUN pnpm run build

# ==================== 运行阶段 ====================
FROM base AS runner

RUN apk add --no-cache \
    tini \
    && rm -rf /var/cache/apk/*

ARG PNPM_HOME
ARG PATH
RUN corepack enable

RUN addgroup -g 1001 -S nodejs && \
    adduser -S hono -u 1001

WORKDIR /app

COPY package.json pnpm-lock.yaml* ./

RUN --mount=type=cache,id=pnpm,target=/pnpm/store \
    pnpm install --prod --frozen-lockfile && \
    pnpm store prune

COPY --from=builder --chown=hono:nodejs /app/dist ./dist
COPY --from=builder --chown=hono:nodejs /app/src/lib/manifest.json ./src/lib/manifest.json
COPY --from=builder --chown=hono:nodejs /app/src/config ./src/config

COPY --chown=hono:nodejs public ./public
COPY --chown=hono:nodejs wrangler.toml ./

ENV NODE_ENV=production
ENV PORT=8787

USER hono

EXPOSE 8787

HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD node -e "http.get('http://localhost:8787/', (res) => { process.exit(res.statusCode === 200 ? 0 : 1) })" || exit 1

ENTRYPOINT ["/sbin/tini", "--"]

CMD ["sh", "-c", "cd dist && node index.js"]

