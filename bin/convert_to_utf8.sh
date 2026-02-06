#!/bin/bash
# 批量转换文件编码从 GBK 到 UTF-8
# 使用方法: ./convert_to_utf8.sh [目录路径]

TARGET_DIR="${1:-/usr/local/games/xiand}"
LOG_FILE="$TARGET_DIR/convert_utf8.log"
PID_FILE="$TARGET_DIR/convert_utf8.pid"

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 检查是否已有实例在运行
if [ -f "$PID_FILE" ]; then
    old_pid=$(cat "$PID_FILE")
    if ps -p "$old_pid" > /dev/null 2>&1; then
        echo -e "${YELLOW}转换进程已在运行 (PID: $old_pid)${NC}"
        echo "如需重新启动，请先运行: kill $old_pid"
        exit 1
    else
        rm -f "$PID_FILE"
    fi
fi

# 保存 PID
echo $$ > "$PID_FILE"

# 日志函数
log() {
    echo -e "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

log_info() {
    log -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    log -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    log -e "${RED}[ERROR]${NC} $1"
}

# 统计函数
count_files() {
    find "$TARGET_DIR" -type f ! -path "*/.git/*" ! -path "*/.svn/*" 2>/dev/null | wc -l
}

count_utf8() {
    find "$TARGET_DIR" -type f ! -path "*/.git/*" ! -path "*/.svn/*" -exec file -b {} \; 2>/dev/null | grep -c "UTF-8"
}

# 开始
log_info "========== UTF-8 转换脚本启动 =========="
log_info "目标目录: $TARGET_DIR"
log_info "日志文件: $LOG_FILE"

# 获取 CPU 核心数
CPU_CORES=$(nproc 2>/dev/null || sysctl -n hw.ncpu 2>/dev/null || echo 4)
log_info "CPU 核心数: $CPU_CORES，将使用 $((CPU_CORES * 2)) 个并行进程"

# 统计总文件数
log_info "正在统计文件总数..."
TOTAL_FILES=$(count_files)
log_info "总文件数: $TOTAL_FILES"

# 显示当前 UTF-8 文件数
UTF8_BEFORE=$(find "$TARGET_DIR" -type f ! -path "*/.git/*" ! -path "*/.svn/*" -exec file -b {} \; 2>/dev/null | grep -c "UTF-8" 2>/dev/null || echo 0)
log_info "当前 UTF-8 文件数: $UTF8_BEFORE"

# 开始转换
log_info "开始转换..."
START_TIME=$(date +%s)

# 使用 find + parallel 方式转换
converted=0
failed=0

export -f log_info
export -f log_error
export TARGET_DIR

# 转换函数
convert_file() {
    local file="$1"
    # 检查是否已经是 UTF-8
    encoding=$(file -b "$file" 2>/dev/null)
    if echo "$encoding" | grep -q "UTF-8"; then
        return 0
    fi
    # 尝试转换
    if iconv -f GBK -t UTF-8 "$file" > "$file.utf8" 2>/dev/null; then
        mv "$file.utf8" "$file"
        echo 1
    else
        # 尝试 GB2312
        if iconv -f GB2312 -t UTF-8 "$file" > "$file.utf8" 2>/dev/null; then
            mv "$file.utf8" "$file"
            echo 1
        else
            echo 0
        fi
    fi
}

export -f convert_file

# 主转换循环
log_info "使用 find + xargs 并行转换..."

find "$TARGET_DIR" -type f ! -path "*/.git/*" ! -path "*/.svn/*" -print0 2>/dev/null | \
    xargs -0 -P $((CPU_CORES * 2)) -I {} bash -c '
        file="{}"
        encoding=$(file -b "$file" 2>/dev/null)
        if echo "$encoding" | grep -q "UTF-8"; then
            exit 0
        fi
        if iconv -f GBK -t UTF-8 "$file" > "$file.utf8" 2>/dev/null; then
            mv "$file.utf8" "$file"
            exit 0
        fi
        if iconv -f GB2312 -t UTF-8 "$file" > "$file.utf8" 2>/dev/null; then
            mv "$file.utf8" "$file"
            exit 0
        fi
        rm -f "$file.utf8"
    ' \;

END_TIME=$(date +%s)
DURATION=$((END_TIME - START_TIME))

# 最终统计
log_info "========== 转换完成 =========="
log_info "耗时: $DURATION 秒 ($((DURATION / 60)) 分钟)"

UTF8_AFTER=$(find "$TARGET_DIR" -type f ! -path "*/.git/*" ! -path "*/.svn/*" -exec file -b {} \; 2>/dev/null | grep -c "UTF-8" 2>/dev/null || echo 0)
log_info "转换后 UTF-8 文件数: $UTF8_AFTER"
log_info "新增 UTF-8 文件: $((UTF8_AFTER - UTF8_BEFORE))"

# 清理
rm -f "$PID_FILE"
log_info "脚本执行完成！"
