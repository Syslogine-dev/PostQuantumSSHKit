#!/bin/bash

# Source shared configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../config.sh"

list_algorithms() {
    echo "Available algorithms:"
    for i in "${!ALGORITHMS[@]}"; do
        echo "$((i+1)). ${ALGORITHMS[$i]}"
    done
}

generate_key() {
    local key_type=$1
    local key_file="${KEY_DIR}/id_${key_type}"
    echo "Generating ${key_type} key..."
    if [[ -f "${key_file}" || -f "${key_file}.pub" ]]; then
        read -p "Key already exists. Overwrite? (y/N): " overwrite
        if [[ "${overwrite}" != "y" && "${overwrite}" != "Y" ]]; then
            echo "Skipping key generation."
            return
        fi
    fi
    read -p "Do you want to protect this key with a password? (y/N): " use_password
    if [[ "${use_password}" == "y" || "${use_password}" == "Y" ]]; then
        "${BIN_DIR}/ssh-keygen" -t "${key_type}" -f "${key_file}"
    else
        "${BIN_DIR}/ssh-keygen" -t "${key_type}" -f "${key_file}" -N ""
    fi
    echo "Key generated at ${key_file}."
}

main() {
    echo "Welcome to the Post-Quantum Key Generator!"
    list_algorithms
    read -p "Select an algorithm by number (1-${#ALGORITHMS[@]}): " choice
    if [[ ! "$choice" =~ ^[0-9]+$ ]] || (( choice < 1 || choice > ${#ALGORITHMS[@]} )); then
        echo "Invalid choice. Exiting."
        exit 1
    fi
    key_type="${ALGORITHMS[$((choice-1))]}"
    generate_key "${key_type}"
}

main
