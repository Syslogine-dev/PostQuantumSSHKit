#!/bin/bash

# Get the actual project root directory (parent of this script)
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# Build directories
BUILD_DIR="${PROJECT_ROOT}/build"
BIN_DIR="${BUILD_DIR}/bin"
SBIN_DIR="${BUILD_DIR}/sbin"
PREFIX="${BUILD_DIR}/oqs"
INSTALL_PREFIX="${BUILD_DIR}"

# Repository information
LIBOQS_REPO="https://github.com/open-quantum-safe/liboqs.git"
LIBOQS_BRANCH="main"
OPENSSH_REPO="https://github.com/open-quantum-safe/openssh.git"
OPENSSH_BRANCH="OQS-v9"

# System directories
OPENSSL_SYS_DIR="/usr"
SSH_DIR="${HOME}/.ssh"

# Supported algorithms
ALGORITHMS=(
    "ssh-falcon1024"
    "ssh-mldsa66"
    "ssh-mldsa44"
    "ssh-dilithium5"
    "ssh-sphincsharaka192frobust"
    "ssh-sphincssha256128frobust"
    "ssh-sphincssha256192frobust"
    "ssh-falcon512"
    "ssh-dilithium2"
    "ssh-dilithium3"
)