我来为您创建一个实用的 Shell 脚本通用模板，包含最佳实践和常用功能：

```shell
#!/bin/bash
#===============================================================================
#
# FILE: script_template.sh
#
# USAGE: ./script_template.sh [options] <arguments>
#
# DESCRIPTION: Shell 脚本通用模板
#
# OPTIONS: 详见下方定义
# REQUIREMENTS: Bash 4.0+
# AUTHOR: Your Name
# VERSION: 1.0.0
# CREATED: 2024-01-01
# REVISION: ---
#===============================================================================

#-------------------------------------------------------------------------------
# 严格模式设置
#-------------------------------------------------------------------------------
set -o errexit # 遇错即停
set -o nounset # 未定义变量报错
set -o pipefail # 管道错误传递

#-------------------------------------------------------------------------------
# 全局变量定义
#-------------------------------------------------------------------------------
readonly SCRIPT_NAME=$(basename "$0")
readonly SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
readonly SCRIPT_VERSION="1.0.0"
readonly LOG_FILE="/var/log/${SCRIPT_NAME%.sh}.log"

# 颜色定义（用于终端输出）
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly NC='\033[0m' # No Color

# 默认配置
VERBOSE=false
DRY_RUN=false
CONFIG_FILE=""

#-------------------------------------------------------------------------------
# 日志函数
#-------------------------------------------------------------------------------
log() {
    local level="$1"
    shift
    local message="$*"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    # 写入日志文件
    echo "[${timestamp}] [${level}] ${message}" >> "$LOG_FILE"
    
    # 终端彩色输出
    case "$level" in
        ERROR) echo -e "${RED}[ERROR]${NC} $message" >&2 ;;
        WARN) echo -e "${YELLOW}[WARN]${NC} $message" ;;
        INFO) echo -e "${GREEN}[INFO]${NC} $message" ;;
        DEBUG) [[ "$VERBOSE" == true ]] && echo -e "${BLUE}[DEBUG]${NC} $message" ;;
    esac
}

# 快捷函数
error_exit() {
    log ERROR "$1"
    exit "${2:-1}"
}

#-------------------------------------------------------------------------------
# 用法说明
#-------------------------------------------------------------------------------
usage() {
    cat << EOF
用法: ${SCRIPT_NAME} [选项] <参数>

选项:
    -h, --help 显示此帮助信息
    -v, --verbose 启用详细输出模式
    -V, --version 显示版本信息
    -c, --config FILE 指定配置文件
    -d, --dry-run 试运行模式（不执行实际操作）

示例:
    ${SCRIPT_NAME} -v -c config.ini target_file
    ${SCRIPT_NAME} --dry-run --config /etc/app.conf

EOF
}

#-------------------------------------------------------------------------------
# 参数解析
#-------------------------------------------------------------------------------
parse_args() {
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -h|--help)
                usage
                exit 0
                ;;
            -v|--verbose)
                VERBOSE=true
                shift
                ;;
            -V|--version)
                echo "${SCRIPT_NAME} version ${SCRIPT_VERSION}"
                exit 0
                ;;
            -c|--config)
                CONFIG_FILE="$2"
                shift 2
                ;;
            -d|--dry-run)
                DRY_RUN=true
                shift
                ;;
            --)
                shift
                break
                ;;
            -*)
                error_exit "未知选项: $1 (使用 -h 查看帮助)"
                ;;
            *)
                break
                ;;
        esac
    done
    
    # 剩余参数处理
    REMAINING_ARGS=("$@")
    
    # 参数验证示例
    if [[ ${#REMAINING_ARGS[@]} -eq 0 ]]; then
        error_exit "缺少必需参数"
    fi
}

#-------------------------------------------------------------------------------
# 清理函数（脚本退出时执行）
#-------------------------------------------------------------------------------
cleanup() {
    local exit_code=$?
    log INFO "脚本执行结束，退出码: $exit_code"
    # 清理临时文件等操作
    [[ -n "${TEMP_DIR:-}" ]] && rm -rf "$TEMP_DIR"
    exit $exit_code
}

# 设置退出陷阱
trap cleanup EXIT
trap 'error_exit "脚本被中断"' INT TERM

#-------------------------------------------------------------------------------
# 功能函数示例
#-------------------------------------------------------------------------------
check_root() {
    if [[ $EUID -ne 0 ]]; then
        error_exit "此脚本需要 root 权限运行，请使用 sudo"
    fi
}

check_dependencies() {
    local deps=("curl" "jq" "awk")
    for cmd in "${deps[@]}"; do
        if ! command -v "$cmd" &> /dev/null; then
            error_exit "缺少依赖: $cmd"
        fi
    done
    log INFO "所有依赖检查通过"
}

load_config() {
    if [[ -n "$CONFIG_FILE" && -f "$CONFIG_FILE" ]]; then
        # shellcheck source=/dev/null
        source "$CONFIG_FILE"
        log INFO "已加载配置文件: $CONFIG_FILE"
    else
        log WARN "未找到配置文件，使用默认设置"
    fi
}

# 安全执行命令（支持试运行模式）
safe_exec() {
    if [[ "$DRY_RUN" == true ]]; then
        log INFO "[试运行] 将执行: $*"
    else
        log DEBUG "执行: $*"
        "$@"
    fi
}

#-------------------------------------------------------------------------------
# 主逻辑
#-------------------------------------------------------------------------------
main() {
    log INFO "========== 脚本开始执行 =========="
    log INFO "脚本路径: $SCRIPT_DIR"
    log INFO "工作目录: $(pwd)"
    
    # 检查权限（按需启用）
    # check_root
    
    # 检查依赖
    check_dependencies
    
    # 加载配置
    load_config
    
    # 主业务逻辑
    log INFO "处理参数: ${REMAINING_ARGS[*]}"
    
    for arg in "${REMAINING_ARGS[@]}"; do
        safe_exec echo "处理: $arg"
        # 在这里添加实际业务逻辑
    done
    
    log INFO "========== 脚本执行成功 =========="
}

#-------------------------------------------------------------------------------
# 脚本入口
#-------------------------------------------------------------------------------
parse_args "$@"
main
```

 模板特性说明
特性 说明
严格模式 set -euo pipefail 防止常见错误
日志系统 分级日志（ERROR/WARN/INFO/DEBUG），支持彩色终端输出
参数解析 支持长短选项、配置文件指定、试运行模式
错误处理 统一的错误退出和清理机制
信号捕获 优雅处理中断信号（Ctrl+C）
 快速使用
1. 复制模板 → 修改 SCRIPT_NAME 和描述
2. 添加依赖 → 在 check_dependencies 中列出所需命令
3. 编写主逻辑 → 在 main() 函数中实现业务功能
4. 运行测试：chmod +x script_template.sh
./script_template.sh -v --dry-run test_arg

需要我针对特定场景（如备份脚本、部署脚本、监控脚本）定制更具体的模板吗？