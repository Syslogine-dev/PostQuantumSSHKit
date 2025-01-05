#!/bin/bash

# Source shared configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../shared/config.sh"
source "${SCRIPT_DIR}/../shared/functions.sh"

connect() {
    echo "Post-Quantum SSH Connection Tool"
    echo "--------------------------------"
    
    read -p "Enter the server IP address: " server_host
    read -p "Enter the username: " username
    read -p "Enter the SSH port [22]: " port
    port=${port:-22}

    echo -e "\nSelect the post-quantum algorithm:"
    list_algorithms
    read -p "Enter algorithm number: " choice
    if [[ ! "$choice" =~ ^[0-9]+$ || "$choice" -lt 1 || "$choice" -gt ${#ALGORITHMS[@]} ]]; then
        echo "Invalid algorithm choice. Exiting."
        exit 1
    fi
    
    algorithm="${ALGORITHMS[$((choice-1))]}"
    key_path="${SSH_DIR}/id_${algorithm}"

    echo -e "\nConnecting to ${username}@${server_host}..."
    
    SSH_AUTH_SOCK="" "${BIN_DIR}/ssh" \
        -o "HostKeyAlgorithms=${algorithm}" \
        -o "PubkeyAcceptedKeyTypes=${algorithm}" \
        -i "${key_path}" \
        -p "${port}" \
        "${username}@${server_host}"
}

connect