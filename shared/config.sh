#!/bin/bash

# Get the actual project root directory (parent of this script)
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# Base installation directories
BIN_DIR="${PROJECT_ROOT}/bin"
SBIN_DIR="${PROJECT_ROOT}/sbin"
PREFIX="${PROJECT_ROOT}/oqs"
INSTALL_PREFIX="${PROJECT_ROOT}"

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
    "ssh-mldsa66"
    "ssh-mldsa44"
    "ssh-falcon1024"
    "ssh-dilithium5"
    "ssh-sphincsharaka192frobust"
)