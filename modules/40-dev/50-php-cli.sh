#!/bin/bash
# PHP 8.3 CLI Installation Module
# Installs PHP 8.3 CLI with Laravel-required extensions and Composer
# Does NOT install Apache, php-fpm, or any web server components
# PHP 8.3 is available in Ubuntu 24.04 (Noble) default repositories — no PPA needed

set -euo pipefail

# Source common library
source "$(dirname "$0")/../../lib/common.sh"

# ============================================================================
# PHP 8.3 CLI Installation Functions
# ============================================================================

# Install PHP 8.3 CLI and required extensions
# PHP 8.3 ships in Ubuntu 24.04 default repos — no external PPA required
install_php_cli() {
    log_info "Starting PHP 8.3 CLI installation..."

    # Check if PHP 8.3 is already installed
    if command -v php &>/dev/null; then
        local current_version
        current_version=$(php --version 2>/dev/null | head -1 || echo "installed")
        log_info "PHP already installed ($current_version), skipping"
        return 0
    fi

    log_info "Updating package list..."
    export DEBIAN_FRONTEND=noninteractive
    apt-get update -qq || die "Failed to update package list"

    # Install PHP 8.3 CLI and Laravel-required extensions
    # Explicitly excluded: apache2, libapache2-mod-php, php8.3-fpm
    # Bundled in php8.3-cli (no extra package needed): ctype, fileinfo, filter,
    #   hash, openssl, pcre, pdo, session, tokenizer
    log_info "Installing PHP 8.3 CLI and extensions..."
    apt-get install -y -qq \
        php8.3-cli \
        php8.3-curl \
        php8.3-mbstring \
        php8.3-xml \
        php8.3-zip \
        unzip \
        || die "Failed to install PHP 8.3 CLI packages"

    log_info "PHP 8.3 CLI installation complete"
}

# ============================================================================
# Composer Installation Functions
# ============================================================================

# Install Composer globally to /usr/local/bin using checksum verification
install_composer() {
    log_info "Starting Composer installation..."

    # Check if Composer is already installed
    if command -v composer &>/dev/null; then
        local current_version
        current_version=$(composer --version 2>/dev/null | head -1 || echo "installed")
        log_info "Composer already installed ($current_version), skipping"
        return 0
    fi

    local setup_file
    setup_file=$(mktemp /tmp/composer-setup.XXXXXX.php)

    # Ensure temp file is cleaned up on exit
    trap 'rm -f "$setup_file"' EXIT

    log_info "Downloading Composer installer..."
    curl -fsSL https://getcomposer.org/installer -o "$setup_file" \
        || die "Failed to download Composer installer"

    # Verify installer checksum against official signature
    log_info "Verifying Composer installer checksum..."
    local expected_checksum actual_checksum
    expected_checksum=$(curl -fsSL https://composer.github.io/installer.sig) \
        || die "Failed to fetch Composer installer checksum"
    actual_checksum=$(php -r "echo hash_file('sha384', '$setup_file');") \
        || die "Failed to compute Composer installer checksum"

    if [[ "$expected_checksum" != "$actual_checksum" ]]; then
        rm -f "$setup_file"
        die "Composer installer checksum verification FAILED — possible tampering"
    fi

    log_info "Checksum verified. Installing Composer..."
    php "$setup_file" \
        --install-dir=/usr/local/bin \
        --filename=composer \
        --quiet \
        || die "Failed to install Composer"

    rm -f "$setup_file"
    trap - EXIT

    log_info "Composer installation complete"
}

# ============================================================================
# Verification
# ============================================================================

verify_php_cli() {
    log_info "Verifying PHP 8.3 CLI installation..."

    command -v php &>/dev/null || die "PHP not found in PATH after installation"
    command -v composer &>/dev/null || die "Composer not found in PATH after installation"

    local php_version composer_version
    php_version=$(php --version | head -1)
    composer_version=$(composer --version)

    log_info "Verified: $php_version"
    log_info "Verified: $composer_version"
}

# ============================================================================
# Main Execution
# ============================================================================

main() {
    install_php_cli
    install_composer
    verify_php_cli
    log_info "PHP 8.3 CLI and Composer setup complete"
}

main "$@"
