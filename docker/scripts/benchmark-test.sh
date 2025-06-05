#!/bin/bash

# Docker 构建方案性能对比测试

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_header() {
    echo -e "${BLUE}======================================${NC}"
    echo -e "${BLUE}  $1${NC}"
    echo -e "${BLUE}======================================${NC}"
}

print_result() {
    echo -e "${GREEN}[结果]${NC} $1: ${YELLOW}$2${NC}"
}

# 清理函数
cleanup() {
    echo -e "${YELLOW}清理测试环境...${NC}"
    docker rmi -f test-cache:latest test-deploy:latest 2>/dev/null || true
    docker builder prune -f 2>/dev/null || true
}

# 测试缓存挂载方案
test_cache_mount() {
    print_header "测试方案1: 缓存挂载 + 重新安装"
    
    echo "构建镜像..."
    start_time=$(date +%s)
    docker build --target runner -t test-cache:latest . > /dev/null 2>&1
    end_time=$(date +%s)
    build_time=$((end_time - start_time))
    
    echo "分析镜像大小..."
    image_size=$(docker images test-cache:latest --format "{{.Size}}")
    
    echo "测试运行..."
    container_id=$(docker run -d -p 8788:8787 test-cache:latest)
    sleep 3
    response=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8788/ || echo "failed")
    docker stop $container_id > /dev/null 2>&1
    docker rm $container_id > /dev/null 2>&1
    
    print_result "构建时间" "${build_time}秒"
    print_result "镜像大小" "$image_size"
    print_result "运行测试" "$response"
    
    # 测试重复构建
    echo "测试重复构建..."
    start_time=$(date +%s)
    docker build --target runner -t test-cache:latest . > /dev/null 2>&1
    end_time=$(date +%s)
    rebuild_time=$((end_time - start_time))
    print_result "重复构建时间" "${rebuild_time}秒"
    
    return $build_time
}

# 测试 pnpm deploy 方案
test_pnpm_deploy() {
    print_header "测试方案2: pnpm deploy"
    
    echo "构建镜像..."
    start_time=$(date +%s)
    docker build -f Dockerfile.deploy-example -t test-deploy:latest . > /dev/null 2>&1
    end_time=$(date +%s)
    build_time=$((end_time - start_time))
    
    echo "分析镜像大小..."
    image_size=$(docker images test-deploy:latest --format "{{.Size}}")
    
    echo "测试运行..."
    container_id=$(docker run -d -p 8789:8787 test-deploy:latest)
    sleep 3
    response=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8789/ || echo "failed")
    docker stop $container_id > /dev/null 2>&1
    docker rm $container_id > /dev/null 2>&1
    
    print_result "构建时间" "${build_time}秒"
    print_result "镜像大小" "$image_size"
    print_result "运行测试" "$response"
    
    # 测试重复构建
    echo "测试重复构建..."
    start_time=$(date +%s)
    docker build -f Dockerfile.deploy-example -t test-deploy:latest . > /dev/null 2>&1
    end_time=$(date +%s)
    rebuild_time=$((end_time - start_time))
    print_result "重复构建时间" "${rebuild_time}秒"
    
    return $build_time
}

# 详细分析
detailed_analysis() {
    print_header "详细分析"
    
    echo "=== 镜像层分析 ==="
    echo "缓存挂载方案层数:"
    docker history test-cache:latest --format "{{.Size}}" | wc -l
    
    echo "pnpm deploy 方案层数:"
    docker history test-deploy:latest --format "{{.Size}}" | wc -l
    
    echo "=== 文件结构对比 ==="
    echo "缓存挂载方案 node_modules 结构:"
    docker run --rm test-cache:latest find node_modules -maxdepth 2 -type d | head -10
    
    echo "pnpm deploy 方案 node_modules 结构:"
    docker run --rm test-deploy:latest find node_modules -maxdepth 2 -type d | head -10
}

# 主测试流程
main() {
    print_header "Docker 构建方案性能对比测试"
    
    # 检查依赖
    if ! command -v docker &> /dev/null; then
        echo -e "${RED}错误: Docker 未安装${NC}"
        exit 1
    fi
    
    if ! command -v curl &> /dev/null; then
        echo -e "${RED}错误: curl 未安装${NC}"
        exit 1
    fi
    
    # 清理环境
    cleanup
    
    # 执行测试
    test_cache_mount
    cache_time=$?
    
    echo ""
    
    test_pnpm_deploy  
    deploy_time=$?
    
    echo ""
    
    # 详细分析
    detailed_analysis
    
    # 总结
    print_header "测试总结"
    if [ $cache_time -lt $deploy_time ]; then
        print_result "构建速度胜者" "缓存挂载方案 (快 $((deploy_time - cache_time))秒)"
    else
        print_result "构建速度胜者" "pnpm deploy 方案 (快 $((cache_time - deploy_time))秒)"
    fi
    
    echo -e "${YELLOW}建议:${NC}"
    echo "- 如果优先考虑构建速度: 使用缓存挂载方案"
    echo "- 如果优先考虑镜像大小和可靠性: 使用 pnpm deploy 方案"
    echo "- 如果是 monorepo 项目: 强烈推荐 pnpm deploy 方案"
    
    # 清理
    cleanup
}

# 运行测试
main "$@" 