#!/bin/bash

# Function to display spinner animation
spinner() {
    local pid=$1
    local delay=0.15
    local spinstr='|/-\'
    while [ "$(ps a | awk '{print $1}' | grep $pid)" ]; do
        local temp=${spinstr#?}
        printf " [%c]  " "$spinstr"
        local spinstr=$temp${spinstr%"$temp"}
        sleep $delay
        printf "\b\b\b\b\b\b"
    done
    printf "    \b\b\b\b"
}

# Function to install snap package with error handling
install_snap() {
    if ! snap list "$1" &> /dev/null; then
        sudo snap install "$1" &
        spinner $!
    else
        echo "$1 is already installed."
    fi
}

# Install required snap packages
install_snap postman
install_snap skype
install_snap discord
install_snap vlc
install_snap redis
install_snap qbittorrent-arnatious
install_snap orion-desktop
install_snap notepad-plus-plus

# Install Git via apt-get if not already installed
if ! command -v git &> /dev/null; then
    sudo apt-get update
    echo "Installing Git..."
    if sudo DEBIAN_FRONTEND=noninteractive apt-get install -y git; then
        echo "Git installed successfully."
    else
        echo "Error: Failed to install Git."
    fi
else
    echo "Git is already installed."
fi

# Install GNOME Shell Extensions
echo "Installing GNOME Shell Extensions..."
sudo apt-get install -y gnome-shell-extensions


# Install PHP 8.2 via ondrej/php PPA
if ! command -v php8.2 &> /dev/null; then
    echo "Installing PHP 8.2..."
    sudo add-apt-repository -y ppa:ondrej/php
    sudo apt-get update
    if sudo DEBIAN_FRONTEND=noninteractive apt-get install -y php8.2; then
        echo "PHP 8.2 installed successfully."
    else
        echo "Error: Failed to install PHP 8.2."
    fi
else
    echo "PHP 8.2 is already installed."
fi

# Clone VS Code repository from GitHub
echo "Cloning VS Code repository..."
if [ ! -d "vscode" ]; then
    git clone https://github.com/microsoft/vscode.git
    cd vscode || exit
    # Install dependencies and build
    yarn install
    yarn run compile
else
    echo "VS Code repository is already cloned."
fi

# Set up Docker's apt repository
echo "Setting up Docker's apt repository..."
if [ ! -f "/etc/apt/sources.list.d/docker.list" ]; then
    sudo apt-get update
    sudo apt-get install -y ca-certificates curl
    sudo install -m 0755 -d /etc/apt/keyrings
    sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
    sudo chmod a+r /etc/apt/keyrings/docker.asc
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "$UBUNTU_CODENAME") stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    sudo apt-get update
    sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
else
    echo "Docker's apt repository is already set up."
fi

echo "Snap, PHP, Git, Docker's apt repository installation complete."
