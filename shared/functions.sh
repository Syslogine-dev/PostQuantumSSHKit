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
                echo "   ↳ Recommended: Fast lattice-based signing, NIST Level 5 security"
                ;;
            "ssh-mldsa66")
                echo "   ↳ Modified LDS scheme, higher security variant"
                ;;
            "ssh-mldsa44")
                echo "   ↳ Modified LDS scheme, balanced security/performance"
                ;;
            "ssh-dilithium5")
                echo "   ↳ NIST PQC winner, lattice-based with strong security guarantees"
                ;;
            "ssh-sphincsharaka192frobust")
                echo "   ↳ Hash-based signature scheme, quantum-resistant with minimal assumptions"
                ;;
            "ssh-sphincssha256128frobust")
                echo "   ↳ SPHINCS+ variant using SHA-256, faster but lower security level"
                ;;
            "ssh-sphincssha256192frobust")
                echo "   ↳ SPHINCS+ SHA-256 variant with NIST Level 3-4 security"
                ;;
            "ssh-falcon512")
                echo "   ↳ Faster Falcon variant, NIST Level 1 security, suitable for constrained devices"
                ;;
            "ssh-dilithium2")
                echo "   ↳ Lighter Dilithium variant, NIST Level 2 security"
                ;;
            "ssh-dilithium3")
                echo "   ↳ Medium Dilithium variant, NIST Level 3 security"
                ;;
        esac
    done
}