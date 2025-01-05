#!/bin/bash

BIN_DIR="$(pwd)/postquantum-lab/bin"
SSH_DIR="${HOME}/.ssh"

# Supported algorithms
ALGORITHMS=("ssh-mldsa66" "ssh-mldsa44" "ssh-falcon1024" "ssh-dilithium5" "ssh-sphincsharaka192frobust")

list_algorithms() {
    echo "Available algorithms:"
    for i in "${!ALGORITHMS[@]}"; do
        echo "$((i+1)). ${ALGORITHMS[$i]}"
    done
}

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