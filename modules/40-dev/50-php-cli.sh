#!/bin/bash
# PHP 8.4 CLI Installation Module
# Installs PHP 8.4 CLI with Laravel-required extensions and Composer
# Uses ppa:ondrej/php (Launchpad) — PHP 8.4 is not in Ubuntu 24.04 default repos
# Does NOT install Apache, php-fpm, or any web server components

set -euo pipefail

# Source common library
source "$(dirname "$0")/../../lib/common.sh"

# ============================================================================
# PHP 8.3 Cleanup Functions
# ============================================================================

# Remove PHP 8.3 packages if installed from a previous run or Ubuntu defaults
remove_php83_if_present() {
    if dpkg -l 'php8.3*' 2>/dev/null | grep -q '^ii'; then
        log_info "Existing PHP 8.3 packages detected — purging before installing 8.4..."
        export DEBIAN_FRONTEND=noninteractive
        apt-get purge -y 'php8.3*' || die "Failed to purge PHP 8.3 packages"
        apt-get autoremove -y --purge || die "Failed to autoremove PHP 8.3 dependencies"
        log_info "PHP 8.3 removed"
    else
        log_info "No PHP 8.3 packages found, skipping cleanup"
    fi
}

# ============================================================================
# PHP 8.4 PPA Setup
# ============================================================================

# Add ondrej/php Launchpad PPA (Ubuntu-specific — NOT packages.sury.org which is Debian-only)
setup_php_ppa() {
    # Skip if sources list already present (idempotent)
    if [[ -f /etc/apt/sources.list.d/ondrej-php.list ]]; then
        log_info "ondrej/php PPA already configured, skipping"
        return 0
    fi

    log_info "Adding ondrej/php Launchpad PPA..."

    export DEBIAN_FRONTEND=noninteractive
    apt-get update -qq || die "Failed to update package list"
    apt-get install -y -qq ca-certificates curl gnupg || die "Failed to install prerequisites"

    # Add ondrej/php signing key from Ubuntu keyserver
    log_info "Fetching ondrej/php signing key..."
    install -m 0755 -d /etc/apt/keyrings || die "Failed to create keyrings directory"
    curl -fsSL "https://keyserver.ubuntu.com/pks/lookup?op=get&search=0xB8DC7E53946656EFBCE4C1DD71DAEAAB4AD4CAB6" \
        | gpg --dearmor -o /etc/apt/keyrings/ondrej-php.gpg \
        || die "Failed to download ondrej/php signing key"
    chmod a+r /etc/apt/keyrings/ondrej-php.gpg || die "Failed to set permissions on signing key"

    # Add Launchpad PPA apt source
    log_info "Adding ondrej/php apt repository..."
    local arch codename
    arch=$(dpkg --print-architecture)
    codename=$(. /etc/os-release && echo "$VERSION_CODENAME")
    echo "deb [arch=${arch} signed-by=/etc/apt/keyrings/ondrej-php.gpg] https://ppa.launchpadcontent.net/ondrej/php/ubuntu ${codename} main" \
        > /etc/apt/sources.list.d/ondrej-php.list \
        || die "Failed to write ondrej/php sources list"

    apt-get update -qq || die "Failed to update package list after adding ondrej/php PPA"

    log_info "ondrej/php PPA configured"
}

# ============================================================================
# PHP 8.4 CLI Installation
# ============================================================================

install_php_cli() {
    log_info "Starting PHP 8.4 CLI installation..."

    # Check if PHP 8.4 is already installed
    if php --version 2>/dev/null | grep -q 'PHP 8\.4'; then
        local current_version
        current_version=$(php --version | head -1)
        log_info "PHP 8.4 already installed ($current_version), skipping"
        return 0
    fi

    # Install PHP 8.4 CLI and Laravel-required extensions
    # Explicitly excluded: apache2, libapache2-mod-php, php8.4-fpm
    # Bundled in php8.4-cli (no extra package needed): ctype, fileinfo, filter,
    #   hash, openssl, pcre, pdo, session, tokenizer
    log_info "Installing PHP 8.4 CLI and extensions..."
    export DEBIAN_FRONTEND=noninteractive
    apt-get install -y -qq \
        php8.4-cli \
        php8.4-curl \
        php8.4-mbstring \
        php8.4-xml \
        php8.4-zip \
        unzip \
        || die "Failed to install PHP 8.4 CLI packages"

    log_info "PHP 8.4 CLI installation complete"
}

# ============================================================================
# Composer Installation
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
    log_info "Verifying PHP 8.4 CLI installation..."

    command -v php &>/dev/null || die "PHP not found in PATH after installation"
    php --version 2>/dev/null | grep -q 'PHP 8\.4' || die "PHP 8.4 not active — wrong version in PATH"
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
    remove_php83_if_present
    setup_php_ppa
    install_php_cli
    install_composer
    verify_php_cli
    log_info "PHP 8.4 CLI and Composer setup complete"
}

main "$@"
