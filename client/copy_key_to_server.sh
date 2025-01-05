#!/bin/bash

# Source shared configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../shared/config.sh"
source "${SCRIPT_DIR}/../shared/functions.sh"

list_keys() {
    echo "Available public keys in ${SSH_DIR}:"
    local keys=($(ls "${SSH_DIR}"/*.pub 2>/dev/null))
    if [[ ${#keys[@]} -eq 0 ]]; then
        echo "No public keys found in ${SSH_DIR}. Please generate a key first."
        exit 1
    fi
    for i in "${!keys[@]}"; do
        echo "$((i+1)). ${keys[$i]}"
    done
    echo "Select a key by number:"
}

copy_client_key() {
    local server_host=$1
    local server_user=$2
    local public_key_file=$3
    local server_port=$4
    local algorithm=$5
    
    # Get private key path by removing .pub extension
    local private_key_file="${public_key_file%.pub}"

    if [[ ! -f "${public_key_file}" ]]; then
        echo "Error: Public key file ${public_key_file} not found."
        exit 1
    fi
    echo "Copying public key to ${server_user}@${server_host}..."
    local public_key
    public_key=$(cat "${public_key_file}")
    
    "${BIN_DIR}/ssh" -i "${private_key_file}" \
                     -o HostKeyAlgorithms="${algorithm}" \
                     -o PubkeyAcceptedKeyTypes="${algorithm}" \
                     -p "${server_port}" \
                     "${server_user}@${server_host}" << EOF
mkdir -p ~/.ssh && chmod 700 ~/.ssh
touch ~/.ssh/authorized_keys && chmod 600 ~/.ssh/authorized_keys
if ! grep -q "${public_key}" ~/.ssh/authorized_keys; then
    echo "${public_key}" >> ~/.ssh/authorized_keys
    echo "Key added to authorized_keys."
else
    echo "Key already exists in authorized_keys."
fi
EOF
}

main() {
    echo "Copy Client Key to Server"
    read -p "Enter the server IP address: " server_host
    read -p "Enter the server username: " server_user
    read -p "Enter the server SSH port [22]: " server_port
    server_port=${server_port:-22}

    echo -e "\nSelect the post-quantum algorithm:"
    list_algorithms
    read -p "Enter algorithm number: " alg_choice
    if [[ ! "$alg_choice" =~ ^[0-9]+$ || "$alg_choice" -lt 1 || "$alg_choice" -gt ${#ALGORITHMS[@]} ]]; then
        echo "Invalid algorithm choice. Exiting."
        exit 1
    fi
    local algorithm="${ALGORITHMS[$((alg_choice-1))]}"
    echo "Selected algorithm: ${algorithm}"

    echo -e "\nSelect the public key to copy:"
    list_keys
    read -p "Select a key by number: " choice
    local keys=($(ls "${SSH_DIR}"/*.pub 2>/dev/null))
    if [[ ! "$choice" =~ ^[0-9]+$ || "$choice" -lt 1 || "$choice" -gt ${#keys[@]} ]]; then
        echo "Invalid key choice. Exiting."
        exit 1
    fi
    local public_key_file="${keys[$((choice-1))]}"
    echo "Selected key: ${public_key_file}"
    
    copy_client_key "${server_host}" "${server_user}" "${public_key_file}" "${server_port}" "${algorithm}"
}

main