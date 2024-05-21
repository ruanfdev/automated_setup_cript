#!/bin/bash
# Automated Script to streamline local development setup for Ubuntu

# --- Functions ---

function pre_update() {
    echo "Pre-Update..."
    sudo apt update && sudo apt upgrade -y && sudo apt full-upgrade -y || (echo "Error in pre-update. Fix and rerun from step 1." && exit 1)
    echo "Pre-update completed successfully!"
}

function installations() {
    echo "Installing core components..."

    # Set up MySQL root password using the provided password (if it was set)
    if [[ -n "$mysql_password" ]]; then
        sudo debconf-set-selections <<< "mysql-server mysql-server/root_password password $mysql_password"
        sudo debconf-set-selections <<< "mysql-server mysql-server/root_password_again password $mysql_password"
    fi

    packages=(php php-cli php-fpm php-mysql php-curl php-gd php-mbstring php-xml php-zip curl php-cli unzip apache2 mysql-server phpmyadmin)
    sudo apt install "${packages[@]}" -y || (echo "Error installing core components. Fix and rerun from step 2." && exit 1)

    echo "Core components installation completed successfully!"
}

function node_npm() {
    echo "Setting up node & npm..."
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.3/install.sh | bash && \
    source ~/.bashrc && \
    command -v nvm && \
    nvm install --lts || (echo "Error in node/npm setup. Fix and rerun from step 3." && exit 1)
    echo "Node & npm setup completed successfully!"
}

function composer() {
    echo "Installing Composer..."
    curl -sS https://getcomposer.org/installer -o composer-setup.php && \
    HASH=`curl -sS https://composer.github.io/installer.sig` && \
    php -r "if (hash_file('SHA384', 'composer-setup.php') === '$HASH') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;" && \
    sudo php composer-setup.php --install-dir=/usr/local/bin --filename=composer || (echo "Error installing Composer. Fix and rerun from step 4." && exit 1)
    echo "Composer installation completed successfully!"
}

function composer() {
    echo "Installing Composer..."
    curl -sS https://getcomposer.org/installer -o composer-setup.php && \
    HASH=`curl -sS https://composer.github.io/installer.sig` && \
    php -r "if (hash_file('SHA384', 'composer-setup.php') === '$HASH') { echo 'Installer verified'; } else { echo 'Installer corrupt. Fix and rerun from step 4.'; unlink('composer-setup.php'); exit 1; } echo PHP_EOL;" && \
    sudo php composer-setup.php --install-dir=/usr/local/bin --filename=composer || (echo "Error installing Composer. Fix and rerun from step 4." && exit 1)
    echo "Composer installation completed successfully!"
}

function additional_installs() {
    echo "Installing additional tools..."
    sudo apt install git python3 python3-pip -y || (echo "Error installing additional tools. Fix and rerun from step 5." && exit 1)
    echo "Additional tools installation completed successfully!"
}

function cleanup() {
    echo "Cleaning up..."
    sudo apt autoremove -y && sudo apt clean && sudo rm -rf /tmp/* && rm composer-setup.php
    echo "Cleanup completed successfully!"
}

# --- Main Script ---

echo "Automated setup Script for Ubuntu"
echo "Choose starting step:"
echo "1. Pre-Update"
echo "2. Installations"
echo "3. node & npm"
echo "4. Composer"
echo "5. Additional Installations"
echo "6. Cleanup (Only if everything else is done)"

read -p "Enter your choice: " choice

# Prompt for MySQL password if starting from step 1 or 2
if [[ $choice -le 2 ]]; then
    read -sp "Enter MySQL root password: " mysql_password
    echo "" # Add a new line for better readability
fi

case "$choice" in
    1) pre_update;;
    2) installations;;
    3) node_npm;;
    4) composer;;
    5) additional_installs;;
    6) cleanup;;
    *) echo "Invalid choice." && exit 1;;
esac

echo "Setup completed successfully!"
