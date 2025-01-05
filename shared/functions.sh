#!/bin/bash

# Source config file
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/config.sh"

# Shared functions
list_algorithms() {
    echo "Available algorithms:"
    for i in "${!ALGORITHMS[@]}"; do
        echo "$((i+1)). ${ALGORITHMS[$i]}"
        case ${ALGORITHMS[$i]} in
            "ssh-falcon1024")
                echo "   ↳ Recommended: Fast lattice-based signing"
                ;;
            "ssh-mldsa66")
                echo "   ↳ Stronger variant of MLDSA"
                ;;
            "ssh-sphincsharaka192frobust")
                echo "   ↳ Hash-based, most conservative choice"
                ;;
        esac
    done
}