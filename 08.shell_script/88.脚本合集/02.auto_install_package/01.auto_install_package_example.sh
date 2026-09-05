#!/bin/bash

set -x

readonly SCRIPT_NAME=$(basename "$0")
readonly SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
readonly PACKAGE_LIST="
gdb
cmake
autoconf
build-essential
git
subversion
"

show_usage() {
    echo "Usage: $0"
}

check_params() {
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -h|--help)
                show_usage "$@"
                exit 0
                ;;
            *)
        esac
    done
}

apt_install_function() {
    sudo apt install -y $1
    if [ $? != 0 ]; then
        echo "exec \"sudo apt install -y $1\" failed. please check."
        exit 1
    else 
        echo "sudo apt install -y $1 success."
    fi
}

auto_install_package_list() {
    soft_sum=0;
    for PACKAGE in $PACKAGE_LIST; do
        apt_install_function $PACKAGE
        soft_sum=$((soft_sum + 1))
    done
    echo "all ${soft_sum} packages were installed successfully."
}

main() {

    # 1. check params
    check_params "$@"

    # 2. update list
    sudo apt update -y

    # 3. install package list
    auto_install_package_list
}

main "$@"