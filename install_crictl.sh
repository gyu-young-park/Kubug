#!/bin/bash

TEMP_INSTALL_DIR=_temp_install_crictl
BIN=/usr/local/bin/
CRICTL_GITHUB=https://github.com/kubernetes-sigs/cri-tools/releases/download/v1.33.0/crictl-v1.33.0-linux-amd64.tar.gz
CRICTL_TAR_FILE=crictl-v1.33.0-linux-amd64.tar.gz

function get_parameter() {
    while getopts "v:" opt "$@"; do
        case "$opt" in
            v) VERSION="$OPTARG" ;;
            *) echo "Usage: $0 -v <version>"; exit 1 ;;
        esac
    done

    if [ "$VERSION" = "" ]; then
        VERSION=v1.33.0
    fi

    CRICTL_GITHUB=https://github.com/kubernetes-sigs/cri-tools/releases/download/${VERSION}/crictl-${VERSION}-linux-amd64.tar.gz
    CRICTL_TAR_FILE=crictl-${VERSION}-linux-amd64.tar.gz
}

function download_crictl() {
    if [ ! -d ./${TEMP_INSTALL_DIR} ]; then
        mkdir ./${TEMP_INSTALL_DIR}  
    fi

    wget -P ./${TEMP_INSTALL_DIR} ${CRICTL_GITHUB}
    ls ./${TEMP_INSTALL_DIR}
}

function install_crictl() {
    pushd ./${TEMP_INSTALL_DIR}
    tar -zxvf ${CRICTL_TAR_FILE}
    sudo mv crictl ${BIN}
    cat << EOF | sudo tee /etc/crictl.yaml > /dev/null
runtime-endpoint: unix:///run/containerd/containerd.sock
image-endpoint: unix:///run/containerd/containerd.sock
EOF
    ${BIN}/crictl --version
    popd
}

function remove_temp_installation_file() {
    if [ -d ./${TEMP_INSTALL_DIR} ]; then
        rm ./${TEMP_INSTALL_DIR} -rf
    fi
}

get_parameter "$@"
download_crictl
install_crictl
remove_temp_installation_file