#!/bin/bash

# set -x
set -o errexit
set -o nounset
set -o pipefail

readonly SCRIPT_NAME=$(basename "$0")
readonly SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
readonly SCRIPT_VERSION="1.0.0"
readonly BUILD_PATH=${SCRIPT_DIR}/build
readonly BIN_PATH=${SCRIPT_DIR}/bin

build_command() {
    # 1. remove last build
    rm -rfv ${BUILD_PATH}
    rm -rfv ${BIN_PATH}

    # 2. create new build
    mkdir -p ${BUILD_PATH}

    cd ${BUILD_PATH}
    cmake ..
    make
}

main() {
    build_command
}

main "$@"


