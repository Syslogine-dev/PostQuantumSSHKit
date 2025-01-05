#!/bin/bash

# Source shared configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../shared/config.sh"
source "${SCRIPT_DIR}/../shared/functions.sh"

setup_directories() {
    echo "Setting up directories..."
    mkdir -p "${KEY_DIR}"
    mkdir -p "${CONFIG_DIR}"
    mkdir -p ~/.ssh
    mkdir -p "${INSTALL_DIR}/var/run"
    chmod 700 ~/.ssh
}

generate_host_key() {
    local key_type=$1
    local host_key="${KEY_DIR}/ssh_host_${key_type}_key"
    
    if [[ ! -f "$host_key" ]]; then
        "${BIN_DIR}/ssh-keygen" -t "$key_type" -f "$host_key" -N ""
        echo "Host key created: $host_key"
    fi
}

create_sshd_config() {
    local key_type=$1
    cat > "${CONFIG_FILE}" << EOF
Port 22
HostKey ${KEY_DIR}/ssh_host_${key_type}_key
HostKeyAlgorithms ${key_type}
PubkeyAcceptedKeyTypes ${key_type}
AuthorizedKeysFile .ssh/authorized_keys
PermitRootLogin no
StrictModes no
PidFile ${INSTALL_DIR}/var/run/sshd.pid
Subsystem sftp ${INSTALL_DIR}/libexec/sftp-server
EOF
    echo "Created sshd_config with $key_type"
}

create_systemd_service() {
    cat > "${SERVICE_FILE}" << EOF
[Unit]
Description=Post-Quantum SSH Server
After=network.target

[Service]
Type=simple
ExecStart=${SBIN_DIR}/sshd -f ${CONFIG_FILE} -D
Restart=always

[Install]
WantedBy=multi-user.target
EOF
    echo "Created systemd service file"
    
    systemctl daemon-reload
    systemctl enable postquantum-sshd.service
}

main() {
    setup_directories
    list_algorithms
    
    read -p "Select an algorithm (1-${#ALGORITHMS[@]}): " choice
    if [[ ! "$choice" =~ ^[0-9]+$ ]] || [ "$choice" -lt 1 ] || [ "$choice" -gt ${#ALGORITHMS[@]} ]; then
        echo "Invalid choice."
        exit 1
    fi
    
    local key_type="${ALGORITHMS[$((choice-1))]}"
    echo "Using algorithm: $key_type"
    
    generate_host_key "$key_type"
    create_sshd_config "$key_type"
    create_systemd_service
    
    echo -e "\nInstallation complete!"
    echo "You can manage the SSH server using:"
    echo "systemctl start postquantum-sshd.service"
    echo "systemctl stop postquantum-sshd.service"
    echo "systemctl status postquantum-sshd.service"
    echo -e "\nNote: Use the key management script to add SSH keys."
}

main