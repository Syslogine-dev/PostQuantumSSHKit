#!/bin/bash

# Check if script is run as root
if [ "$EUID" -ne 0 ]; then
    echo "This wizard must be run as root (sudo)."
    exit 1
fi

# Ensure scripts have execution permissions
ensure_permissions() {
    local scripts=(
        "build_oqs_openssh.sh"
        "server/server.sh"
        "client/keygen.sh"
        "client/copy_key_to_server.sh"
        "client/connect.sh"
    )

    for script in "${scripts[@]}"; do
        if [ -f "$script" ]; then
            chmod +x "$script"
        else
            echo "Error: $script not found"
            exit 1
        fi
    done
}

print_header() {
    clear
    echo "================================================"
    echo "      Post-Quantum SSH Installation Wizard"
    echo "================================================"
    echo
}

show_mode_selection() {
    echo "Is this machine a server or client?"
    echo "1. Server"
    echo "2. Client"
    echo "3. Exit"
    echo
}

show_server_menu() {
    echo "Server Configuration Options:"
    echo "1. Build and install OQS-OpenSSH"
    echo "2. Configure Server"
    echo "3. Back to mode selection"
    echo "4. Exit"
    echo
}

show_client_menu() {
    echo "Client Configuration Options:"
    echo "1. Build and install OQS-OpenSSH"
    echo "2. Generate Keys"
    echo "3. Copy Key to Server"
    echo "4. Connect to Server"
    echo "5. Back to mode selection"
    echo "6. Exit"
    echo
}

handle_build() {
    echo "Starting OQS-OpenSSH build process..."
    if bash build_oqs_openssh.sh; then
        echo "Build completed successfully!"
    else
        echo "Build process failed. Please check the logs."
        exit 1
    fi
}

handle_server() {
    echo "Starting server configuration..."
    bash server/server.sh
}

handle_client() {
    echo "Starting key generation..."
    bash client/keygen.sh
}

handle_copy_key() {
    echo "Starting key copy process..."
    bash client/copy_key_to_server.sh
}

handle_connect() {
    echo "Starting SSH connection..."
    bash client/connect.sh
}

handle_server_menu() {
    while true; do
        print_header
        show_server_menu
        read -p "Enter your choice: " choice
        echo

        case $choice in
            1)
                handle_build
                read -p "Press Enter to continue..."
                ;;
            2)
                handle_server
                read -p "Press Enter to continue..."
                ;;
            3)
                return
                ;;
            4)
                echo "Thank you for using the Post-Quantum SSH Wizard!"
                exit 0
                ;;
            *)
                echo "Invalid choice. Please try again."
                read -p "Press Enter to continue..."
                ;;
        esac
    done
}

handle_client_menu() {
    while true; do
        print_header
        show_client_menu
        read -p "Enter your choice: " choice
        echo

        case $choice in
            1)
                handle_build
                read -p "Press Enter to continue..."
                ;;
            2)
                handle_client
                read -p "Press Enter to continue..."
                ;;
            3)
                handle_copy_key
                read -p "Press Enter to continue..."
                ;;
            4)
                handle_connect
                read -p "Press Enter to continue..."
                ;;
            5)
                return
                ;;
            6)
                echo "Thank you for using the Post-Quantum SSH Wizard!"
                exit 0
                ;;
            *)
                echo "Invalid choice. Please try again."
                read -p "Press Enter to continue..."
                ;;
        esac
    done
}

main() {
    # Check and set permissions at startup
    ensure_permissions

    while true; do
        print_header
        show_mode_selection
        read -p "Enter your choice (1-3): " mode_choice
        echo

        case $mode_choice in
            1)
                handle_server_menu
                ;;
            2)
                handle_client_menu
                ;;
            3)
                echo "Thank you for using the Post-Quantum SSH Wizard!"
                exit 0
                ;;
            *)
                echo "Invalid choice. Please try again."
                read -p "Press Enter to continue..."
                ;;
        esac
    done
}

main