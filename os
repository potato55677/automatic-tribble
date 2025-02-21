#!/bin/bash

# ChimeraOS Installer Script for VPS (No USB Needed)
set -e  # Stop on error

echo "⚡ ChimeraOS Automated Installer for VPS ⚡"
echo "WARNING: This will replace your current OS!"
read -p "Do you want to continue? (yes/no): " choice
if [[ "$choice" != "yes" ]]; then
    echo "Installation canceled."
    exit 1
fi

# Step 1: Download ChimeraOS ISO
CHIMERA_URL="https://github.com/ChimeraOS/chimera/releases/latest/download/chimeraos.img.gz"
CHIMERA_IMG="chimeraos.img.gz"
echo "📥 Downloading ChimeraOS..."
wget -O $CHIMERA_IMG $CHIMERA_URL

# Step 2: Extract the image
echo "🗜 Extracting ChimeraOS..."
gunzip -k $CHIMERA_IMG
CHIMERA_IMG_RAW="chimeraos.img"

# Step 3: Identify the disk (WARNING: This assumes a single disk setup)
DISK=$(lsblk -dno NAME | head -n 1)
DISK_PATH="/dev/$DISK"
echo "💾 Target Disk: $DISK_PATH"

read -p "Proceed with installation on $DISK_PATH? This will erase everything! (yes/no): " confirm
if [[ "$confirm" != "yes" ]]; then
    echo "Installation aborted."
    exit 1
fi

# Step 4: Flash the OS image to the disk
echo "🔥 Installing ChimeraOS..."
dd if=$CHIMERA_IMG_RAW of=$DISK_PATH bs=4M status=progress

# Step 5: Update GRUB bootloader
echo "🔧 Updating GRUB..."
update-grub || grub-mkconfig -o /boot/grub/grub.cfg

echo "✅ Installation Complete! Reboot to enter ChimeraOS."
read -p "Do you want to reboot now? (yes/no): " reboot_choice
if [[ "$reboot_choice" == "yes" ]]; then
    reboot
fi
