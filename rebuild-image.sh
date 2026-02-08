#!/bin/bash

# ============================================
# xiand Docker 镜像构建脚本
# ============================================
# 此脚本将：
# 1. 重新构建 Docker 镜像（无需指定 GAME_AREA）
# 2. 推送镜像到 Docker Hub（支持公开和私有仓库）
#
# 环境变量配置（可选）：
#   DOCKER_USER         - Docker Hub 用户名（默认：lijingmt）
#   DOCKER_TOKEN        - Docker Hub Personal Access Token
#   DOCKER_REGISTRY     - Docker 注册表地址（默认：docker.io）
#   IS_PRIVATE_REPO     - 是否为私有仓库（true/false，默认：false）
#   DOCKER_HUB_TAG      - 自定义镜像标签
#   SKIP_PUSH           - 跳过推送，仅构建本地镜像
#
# 使用示例：
#   ./rebuild-image.sh                                    # 使用默认配置
#   IS_PRIVATE_REPO=true ./rebuild-image.sh              # 推送到私有仓库
#   DOCKER_TOKEN=xxx IS_PRIVATE_REPO=true ./rebuild-image.sh
#   SKIP_PUSH=1 ./rebuild-image.sh                       # 仅构建，不推送
#
# 注意：GAME_AREA 环境变量在运行时指定，
#       构建镜像时无需关心游戏区号
# ============================================

set -e

# 配置参数
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# ============================================
# 构建 Vue 前端
# ============================================
echo "========================================"
echo "正在构建 Vue 前端..."
echo "========================================"
cd "$SCRIPT_DIR/vue_source" && node build.js
if [ $? -eq 0 ]; then
    echo "✓ Vue 前端构建成功！"
else
    echo "✗ Vue 前端构建失败！"
    exit 1
fi
cd "$SCRIPT_DIR"
echo ""

# 自动定位项目根目录
PROJECT_ROOT="$SCRIPT_DIR"
if [ ! -f "$PROJECT_ROOT/docker/docker-compose.yml" ]; then
    if [ -f "$SCRIPT_DIR/../docker/docker-compose.yml" ]; then
        PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
    fi
fi

DOCKER_COMPOSE_FILE="$PROJECT_ROOT/docker/docker-compose.yml"
DOCKERFILE="$PROJECT_ROOT/docker/Dockerfile.all"

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 函数：打印带颜色的消息
print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# 函数：检查必要的命令
check_commands() {
    local commands=("docker" "git")
    for cmd in "${commands[@]}"; do
        if ! command -v $cmd &> /dev/null; then
            print_error "$cmd 命令未找到，请先安装"
            exit 1
        fi
    done
}

# 函数：重建 Docker 镜像
build_image() {
    print_info "重建 Docker 镜像..."
    cd "$PROJECT_ROOT"

    # 构建统一镜像（MUD + Tomcat），使用多阶段构建，无需依赖其他镜像
    print_info "构建统一镜像 (MUD + Tomcat)..."
    if docker build -t xiand-all:latest -f docker/Dockerfile.all .; then
        print_success "统一 Docker 镜像已成功构建"
    else
        print_error "统一 Docker 镜像构建失败"
        exit 1
    fi
}

# 函数：推送镜像到 Docker Hub
push_to_docker_hub() {
    # Docker Hub 配置
    local docker_user="${DOCKER_USER:-lijingmt}"
    local docker_token="${DOCKER_TOKEN:-}"
    local docker_registry="${DOCKER_REGISTRY:-docker.io}"

    # 私有仓库配置（默认为私有）
    local is_private="${IS_PRIVATE_REPO:-true}"

    # 验证必要的 token
    if [ -z "$docker_token" ]; then
        print_error "错误：未设置 DOCKER_TOKEN 环境变量"
        print_info "请设置 DOCKER_TOKEN 环境变量或在脚本中配置"
        print_info "或使用 SKIP_PUSH=1 ./rebuild-image.sh 跳过推送"
        return 1
    fi

    # 获取日期标签（格式：YYYY-MM-DD，不包含时分）
    local date_tag=$(date +%Y-%m-%d)

    # 检查是否指定了自定义镜像标签
    local tag="${DOCKER_HUB_TAG:-}"

    # 如果没有指定标签，则使用日期（不含时分）
    if [ -z "$tag" ]; then
        tag="${date_tag}"
    fi

    print_info "推送镜像到 Docker Hub..."
    echo "镜像标签: $tag"
    echo "用户: $docker_user"
    if [ "$is_private" = "true" ]; then
        echo "仓库类型: 私有 (Private)"
    else
        echo "仓库类型: 公开 (Public)"
    fi
    echo ""

    # 标记镜像
    print_info "[1/3] 标记镜像..."
    docker tag xiand-all:latest ${docker_user}/xiand-all:latest
    print_success "镜像已标记"
    echo ""

    # 登录 Docker Hub
    print_info "[2/3] 登录 Docker Hub..."
    if echo "$docker_token" | docker login -u "$docker_user" --password-stdin > /dev/null 2>&1; then
        print_success "Docker Hub 登录成功"
    else
        print_error "Docker Hub 登录失败，请检查 token 是否正确"
        return 1
    fi
    echo ""

    # 推送统一镜像
    print_info "[3/3] 推送统一镜像 (MUD + Tomcat)..."
    if docker push ${docker_user}/xiand-all:latest; then
        print_success "统一镜像推送完成: ${docker_user}/xiand-all:latest"
    else
        print_error "统一镜像推送失败，请检查网络连接"
        return 1
    fi
    echo ""

    print_success "所有镜像已成功推送到 Docker Hub！"
    echo ""
    echo "镜像地址："
    echo "  - ${docker_user}/xiand-all:latest"
    echo ""
    echo "部署示例："
    echo "  ./restart-docker.sh xd01 9001"
    echo "  （使用 latest 镜像）"
}


# 主流程
main() {
    echo -e "${BLUE}╔════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║   xiand Docker 镜像构建脚本          ║${NC}"
    echo -e "${BLUE}╚════════════════════════════════════════╝${NC}"
    echo ""

    # 显示使用说明
    echo "用法："
    echo "  $0 [选项]"
    echo ""
    echo "功能："
    echo "  - 构建 MUD Docker 镜像"
    echo "  - 自动推送镜像到 Docker Hub（支持公开和私有仓库）"
    echo ""
    echo "环境变量："
    echo "  DOCKER_USER=用户名          指定 Docker Hub 用户名"
    echo "  DOCKER_TOKEN=token          指定 Personal Access Token"
    echo "  IS_PRIVATE_REPO=false       推送到公开仓库（默认为私有）"
    echo "  SKIP_PUSH=1                 跳过 Docker Hub 推送，仅构建本地镜像"
    echo ""
    echo "使用示例："
    echo "  # 私有仓库（默认）"
    echo "  ./rebuild-image.sh"
    echo ""
    echo "  # 公开仓库"
    echo "  IS_PRIVATE_REPO=false ./rebuild-image.sh"
    echo ""
    echo "  # 仅构建，不推送"
    echo "  SKIP_PUSH=1 ./rebuild-image.sh"
    echo ""
    echo "注意："
    echo "  - 镜像构建完全不依赖 GAME_AREA"
    echo "  - GAME_AREA 在运行时通过环境变量指定"
    echo "  - 构建一次，可用于任意游戏区号"
    echo ""

    # 检查必要命令
    check_commands

    # 验证 Dockerfile 存在
    if [ ! -f "$DOCKERFILE" ]; then
        print_error "Dockerfile 不存在：$DOCKERFILE"
        exit 1
    fi

    print_info "项目根目录：$PROJECT_ROOT"
    echo ""

    # 执行步骤
    build_image

    # Docker Hub 推送（可选）
    if [ "${SKIP_PUSH:-0}" = "0" ]; then
        push_to_docker_hub || print_warning "镜像推送失败，但本地镜像已成功构建，可继续使用"
    else
        print_info "跳过 Docker Hub 推送"
    fi

    echo ""
    echo -e "${GREEN}╔════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║   镜像构建完成！                     ║${NC}"
    echo -e "${GREEN}╚════════════════════════════════════════╝${NC}"
    echo ""
    echo "✅ 镜像已准备就绪，可用于任意游戏区号"
    echo ""
    echo "后续启动容器步骤："
    echo "  使用 restart-docker.sh 脚本启动容器："
    echo ""
    echo "  格式: ./restart-docker.sh <游戏区> <端口> [镜像版本]"
    echo ""
    echo "  示例 1: 启动单区 xd01，使用端口 9001（最新镜像）"
    echo "    ./restart-docker.sh xd01 9001"
    echo ""
    echo "  示例 2: 启动合服 xd01-05，使用端口 9005（指定日期版本）"
    echo "    ./restart-docker.sh xd01-05 9005 2025-12-22"
    echo ""
    echo "今天构建的镜像版本: $(date +%Y-%m-%d)"
    echo ""
}

# 执行主函数
main "$@"
