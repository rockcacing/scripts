#!/bin/bash

# bash <(wget -qO- https://raw.githubusercontent.com/rockcacing/scripts/refs/heads/main/setup_rpi.sh)

LOGFILE="/var/log/raspi-setup.log"
exec > >(tee -a "$LOGFILE") 2>&1

echo "Starting Raspberry Pi setup at $(date)"

# Update and Upgrade
sudo apt update && sudo apt upgrade -y

# Install curl
sudo apt install curl -y

echo "System update and upgrade completed."

# Install Tailscale
if ! command -v tailscale &> /dev/null; then
    echo "Installing Tailscale..."
    sudo apt install lsb-release -y
    curl -fsSL https://pkgs.tailscale.com/stable/raspbian/$(lsb_release -cs).noarmor.gpg | sudo tee /usr/share/keyrings/tailscale-archive-keyring.gpg >/dev/null
    echo "deb [signed-by=/usr/share/keyrings/tailscale-archive-keyring.gpg] https://pkgs.tailscale.com/stable/raspbian $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/tailscale.list
    sudo apt update
    sudo apt install tailscale -y
    sudo systemctl enable --now tailscaled
else
    echo "Tailscale is already installed."
fi

# Install Node.js using NVM
if ! command -v nvm &> /dev/null; then
    echo "Installing NVM..."
    curl -fsSL https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.4/install.sh | bash
fi

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \ . "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \ . "$NVM_DIR/bash_completion"

if ! command -v node &> /dev/null; then
    echo "Installing Node.js via NVM..."
    nvm install 20.11.0
    nvm use 20.11.0
    nvm alias default 20.11.0
else
    echo "Node.js is already installed."
fi

# Install Node.js tools
echo "Installing Node.js global tools..."
npm i -g ts-node nodemon env-cmd pm2

# Configure PM2 to start on boot
echo "Configuring PM2 startup..."
PM2_CMD=$(pm2 startup | grep 'sudo' | tail -n 1)  # Extract the sudo command
eval $PM2_CMD

# Raspberry Pi Configurations
echo "Applying Raspberry Pi configurations..."
sudo raspi-config nonint do_expand_rootfs
sudo raspi-config nonint do_ssh 0  # Enable SSH
sudo raspi-config nonint do_boot_splash 1  # Disable splash screen
sudo raspi-config nonint do_piconnect 0  # Enable Raspberry Pi Connect
sudo raspi-config nonint do_serial 0  # Enable serial port
sudo raspi-config nonint do_serial_console 0  # Disable serial console (login=no)

# Disable Bluetooth
echo "Disabling Bluetooth..."
echo "dtoverlay=disable-bt" | sudo tee -a /boot/firmware/config.txt

# Finish
echo "Setup completed at $(date)"
