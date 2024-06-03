#!/bin/bash
# Automated Script to streamline local development setup for Fedora-based systems

# Change to home directory before starting
cd ~

# --- Functions ---
function pre_update() {
    echo "Pre-Update..."
    sudo dnf upgrade -y --refresh || (echo "Error in pre-update. Fix and rerun script." && exit 1)
    echo "Pre-update completed successfully!"
}

function installations() {
    echo "Installing core components..."

    # MySQL/MariaDB root password will be asked manually during installation
    packages=(php php-cli php-fpm php-mysqlnd php-curl php-gd php-mbstring php-xml php-zip curl unzip httpd mariadb-server phpMyAdmin)
    sudo dnf install "${packages[@]}" -y || (echo "Error installing core components. Fix and rerun script." && exit 1)

    # Enable and start services
    sudo systemctl enable --now httpd
    sudo systemctl enable --now mariadb

    echo "Core components installation completed successfully!"
}

function node_npm() {
    echo "Setting up node & npm..."
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash && \
    source ~/.bashrc && \
    command -v nvm && \
    nvm install --lts || (echo "Error in node/npm setup. Fix and rerun script." && exit 1)
    echo "Node & npm setup completed successfully!"
}

function composer() {
    echo "Installing Composer..."
    curl -sS https://getcomposer.org/installer -o composer-setup.php && \
    HASH=`curl -sS https://composer.github.io/installer.sig` && \
    php -r "if (hash_file('SHA384', 'composer-setup.php') === '$HASH') { echo 'Installer verified'; } else { echo 'Installer corrupt. Fix and rerun script.'; unlink('composer-setup.php'); }" && \
    php composer-setup.php --install-dir=/usr/local/bin --filename=composer || (echo "Error installing Composer. Fix and rerun script." && exit 1)
    echo "Composer installation completed successfully!"
}

function additional_installs() {
    echo "Installing additional tools..."
    sudo dnf install git python3 python3-pip -y || (echo "Error installing additional tools. Fix and rerun script." && exit 1)
    echo "Additional tools installation completed successfully!"
}

function cleanup() {
    echo "Cleaning up..."
    sudo dnf autoremove -y && sudo dnf clean all && sudo rm -rf /tmp/* && rm composer-setup.php
    echo "Cleanup completed successfully!"
}


# --- Main Script ---
pre_update
installations
node_npm
composer
additional_installs
cleanup

echo "Setup completed successfully!"