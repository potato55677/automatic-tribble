#!/bin/bash

# Exit on error
set -e

# Variables
USERNAME="crduser"
PASSWORD="password123"  # Change this to a secure password

# Update package list
echo "Updating package list..."
sudo apt update

# Install required dependencies
echo "Installing required dependencies..."
DEBIAN_FRONTEND=noninteractive sudo apt install -y \
    dbus-x11 \
    xserver-xorg \
    x11-xserver-utils \
    gnome-session \
    gnome-terminal \
    gdm3 \
    gnome-shell \
    ubuntu-session \
    gnome-control-center \
    gnome-tweaks \
    tasksel \
    wget \
    curl \
    nano \
    unzip \
    pulseaudio \
    xvfb \
    xrdp \
    fonts-liberation \
    libgbm1 \
    libxkbcommon-x11-0

# Create a new user for CRD
if ! id "$USERNAME" &>/dev/null; then
    echo "Creating user: $USERNAME"
    sudo adduser --disabled-password --gecos "" "$USERNAME"
    echo "$USERNAME:$PASSWORD" | sudo chpasswd
    sudo usermod -aG sudo "$USERNAME"
fi

# Download and install Chrome Remote Desktop
echo "Downloading Chrome Remote Desktop..."
wget https://dl.google.com/linux/direct/chrome-remote-desktop_current_amd64.deb
echo "Installing Chrome Remote Desktop..."
sudo dpkg -i chrome-remote-desktop_current_amd64.deb || sudo apt --fix-broken install -y

# Ask user for CRD setup key
echo "Enter your Chrome Remote Desktop setup key:"
read -r CRD_KEY

if [[ -z "$CRD_KEY" ]]; then
    echo "No key entered. Please enter a valid CRD key."
    exit 1
fi

# Configure Chrome Remote Desktop for the new user
echo "Configuring Chrome Remote Desktop..."
sudo -u "$USERNAME" bash -c "DISPLAY= /opt/google/chrome-remote-desktop/start-host --code=\"$CRD_KEY\" --redirect-url=\"https://remotedesktop.google.com/_/oauthredirect\" --name=\"Gitpod Ubuntu\""

# Set GNOME as the default session for CRD user
echo "Setting GNOME as the default session..."
sudo -u "$USERNAME" bash -c 'echo "exec gnome-session" > ~/.chrome-remote-desktop-session'
sudo chmod 644 /home/$USERNAME/.chrome-remote-desktop-session

# Disable Wayland (CRD requires Xorg)
echo "Disabling Wayland for compatibility..."
sudo sed -i 's/#WaylandEnable=false/WaylandEnable=false/g' /etc/gdm3/custom.conf

# Manually start dbus for the CRD user
echo "Starting dbus session..."
sudo -u "$USERNAME" bash -c 'export $(dbus-launch)'

# Start Chrome Remote Desktop without systemd
echo "Starting Chrome Remote Desktop service..."
sudo -u "$USERNAME" bash -c "/opt/google/chrome-remote-desktop/start-host &"

echo "✅ Setup Complete!"
echo "You can now connect using Chrome Remote Desktop."
