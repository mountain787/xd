#!/bin/bash
##############################################################################
# MySQL Socat 转发服务启动脚本
#
# 作用说明：
#   Docker 容器内的 Pike 程序默认使用 Unix socket 连接 MySQL
#   但 MySQL 运行在宿主机上，需要通过 socat 将容器内的 Unix socket
#   转发到宿主机的 TCP 端口 (172.17.0.1:3306)
#
# 使用场景：
#   - 容器内 Pike 程序连接 /tmp/.mysql_sock
#   - socat 将请求转发到宿主机 MySQL (172.17.0.1:3306)
#   - 无需修改 Pike 代码即可连接外部 MySQL
#
# 注意事项：
#   - 此脚本由容器启动脚本自动调用
#   - 一般无需手动执行
#   - 如需调试，可手动运行此脚本
##############################################################################

SOCKET_PATH="/tmp/.mysql_sock"
MYSQL_HOST="${MYSQL_HOST:-172.17.0.1}"
MYSQL_PORT="${MYSQL_PORT:-3306}"

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

echo "========================================"
echo "MySQL Socat 转发服务"
echo "========================================"
echo ""

# 检查 socat 是否安装
if ! command -v socat &> /dev/null; then
    log_error "socat 未安装"
    echo "安装命令: dnf install -y socat"
    exit 1
fi

log_info "socat 已安装"

# 检查是否已有 socat 进程在运行
if pgrep -f "socat.*$SOCKET_PATH" > /dev/null; then
    log_warn "socat MySQL 转发已在运行"
    log_info "如需重启，请先执行: pkill -f 'socat.*$SOCKET_PATH'"
    exit 0
fi

# 删除旧的 socket 文件
log_info "清理旧的 socket 文件..."
rm -f "$SOCKET_PATH"
rm -f /var/lib/mysql/mysql.sock 2>/dev/null
rm -f /run/mysqld/mysqld.sock 2>/dev/null

# 创建 socket 目录
mkdir -p /run/mysqld
mkdir -p /var/lib/mysql

# 检查 MySQL 是否可访问
log_info "检查 MySQL 连接: $MYSQL_HOST:$MYSQL_PORT..."
if ! nc -z -w5 "$MYSQL_HOST" "$MYSQL_PORT" 2>/dev/null; then
    log_warn "无法连接到 MySQL $MYSQL_HOST:$MYSQL_PORT"
    log_warn "请确保 MySQL 正在运行且端口正确"
fi

# 启动 socat
log_info "启动 socat 转发..."
log_info "  $SOCKET_PATH -> $MYSQL_HOST:$MYSQL_PORT"

socat UNIX-LISTEN:"$SOCKET_PATH",fork,reuseaddr,mode=666 TCP:$MYSQL_HOST:$MYSQL_PORT > /tmp/socat.log 2>&1 &
SOCAT_PID=$!

sleep 1

# 检查 socat 是否启动成功
if ps -p $SOCAT_PID > /dev/null; then
    log_info "socat 已启动 (PID: $SOCAT_PID)"

    # 创建符号链接以兼容不同的连接路径
    ln -sf "$SOCKET_PATH" /var/lib/mysql/mysql.sock 2>/dev/null
    ln -sf "$SOCKET_PATH" /run/mysqld/mysqld.sock 2>/dev/null

    log_info "符号链接已创建:"
    log_info "  /var/lib/mysql/mysql.sock -> $SOCKET_PATH"
    log_info "  /run/mysqld/mysqld.sock -> $SOCKET_PATH"

    echo ""
    echo "========================================"
    log_info "✓ Socat 转发服务已就绪"
    echo "========================================"
    echo ""
    echo "连接方式："
    echo "  mysql -S $SOCKET_PATH -u root -p"
    echo ""
else
    log_error "socat 启动失败"
    log_error "查看日志: cat /tmp/socat.log"
    exit 1
fi
