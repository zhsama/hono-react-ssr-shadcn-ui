#!/bin/bash

# Docker 管理脚本 - Hono React SSR
# 支持开发、生产、清理等多种操作

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# 项目配置
PROJECT_NAME="hono-ssr"
COMPOSE_FILE="docker/docker-compose.yml"
MONOREPO_COMPOSE_FILE="docker/docker-compose.monorepo.yml"

# 显示标题
show_header() {
    echo -e "${BLUE}=====================================${NC}"
    echo -e "${BLUE}     🚀 Hono React SSR Docker      ${NC}"
    echo -e "${BLUE}=====================================${NC}"
    echo ""
}

# 显示帮助信息
show_help() {
    show_header
    echo -e "${CYAN}用法:${NC} $0 [命令]"
    echo ""
    echo -e "${YELLOW}可用命令:${NC}"
    echo -e "  ${GREEN}dev${NC}          启动开发环境"
    echo -e "  ${GREEN}prod${NC}         启动生产环境"
    echo -e "  ${GREEN}build${NC}        构建应用"
    echo -e "  ${GREEN}down${NC}         停止所有容器"
    echo -e "  ${GREEN}clean${NC}        清理容器和镜像"
    echo -e "  ${GREEN}logs${NC}         查看日志"
    echo -e "  ${GREEN}shell${NC}        进入开发容器"
    echo -e "  ${GREEN}test${NC}         运行测试"
    echo -e "  ${GREEN}monorepo${NC}     启动 Monorepo 环境"
    echo -e "  ${GREEN}benchmark${NC}    运行性能测试"
    echo -e "  ${GREEN}status${NC}       查看容器状态"
    echo -e "  ${GREEN}help${NC}         显示此帮助信息"
    echo ""
    echo -e "${YELLOW}示例:${NC}"
    echo -e "  $0 dev           # 启动开发环境"
    echo -e "  $0 prod          # 启动生产环境"
    echo -e "  $0 clean         # 清理环境"
    echo ""
}

# 检查 Docker 和 Docker Compose
check_requirements() {
    if ! command -v docker &> /dev/null; then
        echo -e "${RED}❌ Docker 未安装或未在 PATH 中${NC}"
        exit 1
    fi

    if ! command -v docker-compose &> /dev/null && ! docker compose version &> /dev/null; then
        echo -e "${RED}❌ Docker Compose 未安装${NC}"
        exit 1
    fi
}

# 获取 Docker Compose 命令
get_compose_cmd() {
    if docker compose version &> /dev/null; then
        echo "docker compose"
    else
        echo "docker-compose"
    fi
}

# 启动开发环境
start_dev() {
    echo -e "${GREEN}🚀 启动开发环境...${NC}"
    $(get_compose_cmd) -f $COMPOSE_FILE up --build dev
}

# 启动生产环境
start_prod() {
    echo -e "${GREEN}🏭 启动生产环境...${NC}"
    $(get_compose_cmd) -f $COMPOSE_FILE up --build -d prod
    echo -e "${GREEN}✅ 生产环境已启动，访问 http://localhost:8787${NC}"
}

# 构建应用
build_app() {
    echo -e "${YELLOW}🔨 构建应用...${NC}"
    $(get_compose_cmd) -f $COMPOSE_FILE run --rm builder
    echo -e "${GREEN}✅ 构建完成${NC}"
}

# 停止所有容器
stop_containers() {
    echo -e "${YELLOW}⏹️ 停止所有容器...${NC}"
    $(get_compose_cmd) -f $COMPOSE_FILE down
    echo -e "${GREEN}✅ 容器已停止${NC}"
}

# 清理环境
clean_environment() {
    echo -e "${RED}🧹 清理 Docker 环境...${NC}"
    
    # 停止并删除容器
    $(get_compose_cmd) -f $COMPOSE_FILE down --remove-orphans
    
    # 删除项目相关镜像
    echo -e "${YELLOW}删除项目镜像...${NC}"
    docker images | grep $PROJECT_NAME | awk '{print $3}' | xargs -r docker rmi -f
    
    # 清理构建缓存
    echo -e "${YELLOW}清理构建缓存...${NC}"
    docker builder prune -f
    
    # 清理未使用的卷
    echo -e "${YELLOW}清理未使用的卷...${NC}"
    docker volume prune -f
    
    echo -e "${GREEN}✅ 清理完成${NC}"
}

# 查看日志
show_logs() {
    echo -e "${BLUE}📋 查看容器日志...${NC}"
    $(get_compose_cmd) -f $COMPOSE_FILE logs -f
}

# 进入开发容器
enter_shell() {
    echo -e "${CYAN}🐚 进入开发容器...${NC}"
    $(get_compose_cmd) -f $COMPOSE_FILE exec dev sh
}

# 运行测试
run_tests() {
    echo -e "${PURPLE}🧪 运行测试...${NC}"
    $(get_compose_cmd) -f $COMPOSE_FILE run --rm dev pnpm test
}

# 启动 Monorepo 环境
start_monorepo() {
    echo -e "${GREEN}🔄 启动 Monorepo 环境...${NC}"
    $(get_compose_cmd) -f $MONOREPO_COMPOSE_FILE up --build
}

# 运行性能测试
run_benchmark() {
    echo -e "${PURPLE}⚡ 运行性能测试...${NC}"
    if [ -f "docker/scripts/benchmark-test.sh" ]; then
        chmod +x docker/scripts/benchmark-test.sh
        ./docker/scripts/benchmark-test.sh
    else
        echo -e "${RED}❌ 性能测试脚本不存在${NC}"
    fi
}

# 查看容器状态
show_status() {
    echo -e "${BLUE}📊 容器状态:${NC}"
    $(get_compose_cmd) -f $COMPOSE_FILE ps
    echo ""
    echo -e "${BLUE}💾 镜像大小:${NC}"
    docker images | grep $PROJECT_NAME
    echo ""
    echo -e "${BLUE}📈 资源使用:${NC}"
    docker stats --no-stream | head -n 10
}

# 主函数
main() {
    check_requirements
    
    case "${1:-help}" in
        "dev")
            start_dev
            ;;
        "prod")
            start_prod
            ;;
        "build")
            build_app
            ;;
        "down")
            stop_containers
            ;;
        "clean")
            clean_environment
            ;;
        "logs")
            show_logs
            ;;
        "shell")
            enter_shell
            ;;
        "test")
            run_tests
            ;;
        "monorepo")
            start_monorepo
            ;;
        "benchmark")
            run_benchmark
            ;;
        "status")
            show_status
            ;;
        "help"|*)
            show_help
            ;;
    esac
}

# 执行主函数
main "$@" 