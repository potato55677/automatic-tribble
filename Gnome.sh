#!/bin/bash

# Exit on error
set -e

# Function to check if a package is installed
check_package() {
    dpkg -l | grep -q "$1" || sudo apt-get install -y "$1"
}

echo "Updating package list..."
sudo apt update

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

echo "Downloading Chrome Remote Desktop..."
wget https://dl.google.com/linux/direct/chrome-remote-desktop_current_amd64.deb

echo "Installing Chrome Remote Desktop..."
sudo dpkg -i chrome-remote-desktop_current_amd64.deb || sudo apt --fix-broken install -y

echo "Enter your Chrome Remote Desktop setup key:"
read -r CRD_KEY

if [[ -z "$CRD_KEY" ]]; then
    echo "No key entered. Please enter a valid CRD key."
    exit 1
fi

echo "Setting up Chrome Remote Desktop..."
DISPLAY= /opt/google/chrome-remote-desktop/start-host --code="$CRD_KEY" --redirect-url="https://remotedesktop.google.com/_/oauthredirect" --name="Gitpod Ubuntu"

echo "Configuring GNOME session..."
echo "exec gnome-session" > ~/.xsession

echo "Disabling Wayland for compatibility..."
sudo sed -i 's/#WaylandEnable=false/WaylandEnable=false/g' /etc/gdm3/custom.conf

echo "Starting dbus session..."
dbus-launch --exit-with-session gnome-session &

echo "Chrome Remote Desktop and GNOME setup is complete!"
echo "You can now connect using Chrome Remote Desktop."
