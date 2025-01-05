#!/bin/bash

# Source shared configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../shared/config.sh"
source "${SCRIPT_DIR}/../shared/functions.sh"

# Override SSH_DIR for the actual user when script is run with sudo
if [ -n "$SUDO_USER" ]; then
    REAL_USER="${SUDO_USER}"
    REAL_USER_HOME=$(getent passwd "$REAL_USER" | cut -d: -f6)
    SSH_DIR="${REAL_USER_HOME}/.ssh"
fi

# Function for key generation
generate_key() {
    local key_type=$1
    local key_file="${SSH_DIR}/id_${key_type}"
    
    # Create .ssh directory if it doesn't exist
    if [[ ! -d "${SSH_DIR}" ]]; then
        mkdir -p "${SSH_DIR}"
        chmod 700 "${SSH_DIR}"
        chown "${REAL_USER}:${REAL_USER}" "${SSH_DIR}"
    fi
    
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
        sudo -u "${REAL_USER}" "${BIN_DIR}/ssh-keygen" -t "${key_type}" -f "${key_file}"
    else
        sudo -u "${REAL_USER}" "${BIN_DIR}/ssh-keygen" -t "${key_type}" -f "${key_file}" -N ""
    fi
    
    # Ensure correct ownership and permissions
    chown "${REAL_USER}:${REAL_USER}" "${key_file}"* 2>/dev/null
    chmod 600 "${key_file}" 2>/dev/null
    chmod 644 "${key_file}.pub" 2>/dev/null
    
    echo "Key generated at ${key_file}."
}

# Main function
main() {
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