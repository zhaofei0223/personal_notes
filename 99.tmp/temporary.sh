#!/bin/bash

# ==============================================================================
# 脚本名称: generic_script.sh
# 描述: 这是一个通用Shell脚本模板，包含错误处理、日志记录和参数解析。
# 作者: Your Name
# 日期: YYYY-MM-DD
# 版本: 1.0
# ==============================================================================

# --- 安全设置 ---
# set -e: 任何命令返回非零退出状态码时立即退出
# set -u: 尝试引用未定义变量时报错
# set -o pipefail: 管道命令中任何部分失败则视为整个管道失败
set -euo pipefail

# --- 变量定义 ---
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_FILE="${SCRIPT_DIR}/script.log"

# --- 日志记录函数 ---
log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1" | tee -a "${LOG_FILE}"
}

error() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] [ERROR] $1" | tee -a "${LOG_FILE}" >&2
}

# --- 帮助信息 ---
usage() {
    echo "用法: $0 [选项] [参数]"
    echo "选项:"
    echo "  -h, --help    显示此帮助信息"
    echo "  -v, --verbose 启用详细日志"
    exit 1
}

# --- 参数解析 ---
VERBOSE=false
while [[ $# -gt 0 ]]; do
    case "$1" in
        -h|--help) usage ;;
        -v|--verbose) VERBOSE=true; shift ;;
        *) break ;; # 结束选项解析
    esac
done

# --- 主逻辑 ---
main() {
    log "脚本开始执行..."

    # 在此处添加你的脚本逻辑
    # 示例:
    # if [ "$VERBOSE" = true ]; then log "调试模式已启用"; fi

    log "脚本执行成功。"
}

# --- 执行主逻辑 ---
main "$@"
