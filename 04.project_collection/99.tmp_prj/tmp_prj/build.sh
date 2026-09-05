#!/bin/bash

# set -x
set -o errexit
set -o nounset
set -o pipefail

readonly SCRIPT_NAME=$(basename "$0")
readonly SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
readonly SCRIPT_VERSION="1.0.0"
readonly BUILD_DIR=${SCRIPT_DIR}/build

readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly NC='\033[0m'

# echo -e "${RED}[ERROR]${NC} $message"     -- ERROR
# echo -e "${YELLOW}[WARN]${NC} $message"   -- WARN
# echo -e "${GREEN}[INFO]${NC} $message"    -- INFO
# echo -e "${BLUE}[DEBUG]${NC} $message"    -- DEBUG

usage() {
    cat << EOF

用法: ${SCRIPT_NAME} [选项] <参数>

选项:
    -h, --help 输出帮助信息

示例:
    ./${SCRIPT_NAME} -h

EOF
}

# 清理现有环境的残余数据
clean_up_old_data() {
    if [ -d "${BUILD_DIR}" ]; then
        echo -e "${GREEN}[INFO]${NC} 目录 '$BUILD_DIR' 存在。"
        rm -rfv ${BUILD_DIR}
    else
        echo -e "${GREEN}[INFO]${NC} 目录 '$BUILD_DIR' 不存在。"
    fi
    mkdir -p ${BUILD_DIR}
}

# 编译工程
build_prj() {
    # 清理现有环境的残余数据
    clean_up_old_data

    cd ${BUILD_DIR}
    cmake ..
    make
}

parse_args() {
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -h|--help)
                usage
                shift
                ;;
            *)
                echo -e "${RED}[ERROR]${NC} 脚本的参数错误"     -- ERROR
                ;;
        esac
    done

    REMAINING_ARGS=("$@")
    if [[ ${#REMAINING_ARGS[@]} -ne 0 ]]; then
        usage
        echo -e "${RED}[ERROR]${NC} 请参考上面的说明输入参数，不要输入多余无用的参数。"
    fi
}

main() {
    echo -e "${GREEN}[INFO]${NC} ========== 脚本开始执行 =========="
    echo -e "${GREEN}[INFO]${NC} 脚本路径: ${SCRIPT_DIR}"
    echo -e "${GREEN}[INFO]${NC} 工作目录: $(pwd)"

    if [[ $# -eq 0 ]]; then
        build_prj
        echo -e "${GREEN}[INFO]${NC} ========== 脚本执行成功 =========="
        exit 0
    fi

    parse_args "$@"

    echo -e "${GREEN}[INFO]${NC} ========== 脚本执行成功 =========="
}

main "$@"