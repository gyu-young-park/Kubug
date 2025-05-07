#!/bin/bash

VERSION=v1.33.0

while getopts "v:" opt; do
    case "$opt" in
        v) VERSION="$OPTARG" ;;
        *) echo "Usage: $0 -v <version>"; exit 1 ;;
    esac
done

CRICTL_GITHUB=https://github.com/kubernetes-sigs/cri-tools/releases/download/${VERSION}/crictl-${VERSION}-linux-amd64.tar.gz
CRICTL_TAR_FILE=crictl-${VERSION}-linux-amd64.tar.gz
TEMP_INSTALL_DIR=_temp_install_crictl
BIN=/usr/local/bin/

function download_crictl() {
    mkdir ./${TEMP_INSTALL_DIR}
    wget -P ./${TEMP_INSTALL_DIR} ${CRICTL_GITHUB}
    ls ./${TEMP_INSTALL_DIR}
}

function install_crictl() {
    pushd ./${TEMP_INSTALL_DIR}
    tar -zxvf ${CRICTL_TAR_FILE}
    # sudo mv crictl ${BIN}
    ${BIN}/crictl --version
    popd
}

function remove_temp_installation_file() {
    rm ${TEMP_INSTALL_DIR} -rf
}

download_crictl
install_crictl
remove_temp_installation_file