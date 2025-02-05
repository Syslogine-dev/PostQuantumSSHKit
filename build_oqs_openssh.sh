#!/bin/bash

###########
# Build and install OQS-OpenSSH (Open Quantum Safe OpenSSH)
###########

set -eo pipefail

LOG_FILE="${BUILD_DIR}/oqs_build.log"

# Source shared configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/shared/config.sh"
source "${SCRIPT_DIR}/shared/functions.sh"

log() {
    mkdir -p "$(dirname "$LOG_FILE")"
    echo "$(date "+%Y-%m-%d %H:%M:%S") - $1" | tee -a "$LOG_FILE"
}

check_error() {
    if [ $? -ne 0 ]; then
        log "Error: $1"
        exit 1
    fi
}

install_dependencies() {
    log "Installing dependencies..."
    if [ -f /etc/debian_version ]; then
        sudo apt-get update
        sudo apt-get install -y autoconf automake cmake gcc libtool libssl-dev make ninja-build zlib1g-dev git doxygen graphviz
        check_error "Failed to install dependencies"
        sudo mkdir -p -m 0755 /var/empty
        if ! getent group sshd >/dev/null; then sudo groupadd sshd; fi
        if ! getent passwd sshd >/dev/null; then sudo useradd -g sshd -c 'sshd privsep' -d /var/empty -s /bin/false sshd; fi
    else
        log "WARNING: Non-Debian system detected. Please install dependencies manually."
    fi
}

# Copy necessary shared libraries
handle_shared_libraries() {
    log "Setting up shared libraries..."
    
    # Create lib directory if it doesn't exist
    mkdir -p "${INSTALL_PREFIX}/lib"
    
    # Copy liboqs libraries
    if [ -d "${PREFIX}/lib" ]; then
        cp -R ${PREFIX}/lib/* ${INSTALL_PREFIX}/lib/
        log "Copied liboqs libraries to ${INSTALL_PREFIX}/lib/"
    else
        log "Error: liboqs libraries not found in ${PREFIX}/lib"
        exit 1
    fi
    
    # Update ldconfig if on Linux
    if [ "$(uname)" == "Linux" ]; then
        echo "${INSTALL_PREFIX}/lib" | sudo tee /etc/ld.so.conf.d/oqs-ssh.conf
        sudo ldconfig
        log "Updated system library cache"
    fi
}

# Main installation process
main() {
    log "Starting OQS-OpenSSH installation..."
    
    # Create build directory
    mkdir -p "${BUILD_DIR}"
    cd "${PROJECT_ROOT}"
    
    # Install dependencies
    install_dependencies
    
    # Step 1: Clone liboqs
    log "Cloning liboqs..."
    rm -rf "${BUILD_DIR}/tmp" && mkdir -p "${BUILD_DIR}/tmp"
    git clone --branch ${LIBOQS_BRANCH} --single-branch ${LIBOQS_REPO} "${BUILD_DIR}/tmp/liboqs"
    check_error "Failed to clone liboqs"

    # Step 2: Build liboqs
    log "Building liboqs..."
    cd "${BUILD_DIR}/tmp/liboqs"
    rm -rf build
    mkdir build && cd build
    cmake .. -GNinja -DBUILD_SHARED_LIBS=ON -DCMAKE_POSITION_INDEPENDENT_CODE=ON -DCMAKE_INSTALL_PREFIX=${PREFIX}
    check_error "CMake configuration failed"
    ninja
    check_error "Ninja build failed"
    ninja install
    check_error "Ninja install failed"
    cd "${PROJECT_ROOT}"

    # Step 3: Clone OpenSSH
    log "Cloning OpenSSH..."
    git clone --branch ${OPENSSH_BRANCH} --single-branch ${OPENSSH_REPO} "${BUILD_DIR}/openssh"
    check_error "Failed to clone OpenSSH"

    # Step 4: Build OpenSSH
    log "Building OpenSSH..."
    cd "${BUILD_DIR}/openssh"
    
    autoreconf -i
    check_error "Autoreconf failed"

    ./configure --prefix="${INSTALL_PREFIX}" \
               --with-ldflags="-Wl,-rpath -Wl,${INSTALL_PREFIX}/lib" \
               --with-libs=-lm \
               --with-ssl-dir="${OPENSSL_SYS_DIR}" \
               --with-liboqs-dir="${PREFIX}" \
               --with-cflags="-I${INSTALL_PREFIX}/include" \
               --sysconfdir="${INSTALL_PREFIX}/etc" \
               --with-privsep-path="${INSTALL_PREFIX}/var/empty" \
               --with-pid-dir="${INSTALL_PREFIX}/var/run" \
               --with-xauth="${INSTALL_PREFIX}/bin/xauth" \
               --with-default-path="/usr/local/bin:/usr/bin:/bin" \
               --with-privsep-user=sshd
    check_error "Configure failed"

    make -j$(nproc)
    check_error "Make failed"

    handle_shared_libraries
    
    make install
    check_error "Make install failed"
    
    cd "${PROJECT_ROOT}"

    log "Installation completed successfully!"
    log "OQS-OpenSSH has been installed to: ${INSTALL_PREFIX}"
    log "liboqs has been installed to: ${PREFIX}"
}

# Run the main installation
main

# Optional: Run basic tests
log "Installation complete. Would you like to run the test suite?"
read -p "Run tests? (y/N): " run_tests
if [[ "${run_tests}" == "y" || "${run_tests}" == "Y" ]]; then
    if [ -d "${BUILD_DIR}/openssh" ] && [ -f "${BUILD_DIR}/openssh/oqs-test/run_tests.sh" ]; then
        log "Starting test suite..."
        cd "${BUILD_DIR}/openssh" && ./oqs-test/run_tests.sh
    else
        log "Error: Test script not found. Cannot run tests."
    fi
else
    log "Skipping tests."
fi