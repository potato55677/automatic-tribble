#!/bin/bash

# Set default username and password
username="user"
password="root"

# Set default CRP value (User will enter it)
CRP=""

# Set default Pin value
Pin="123456"

# Set default Autostart value
Autostart=true

echo "Creating User and Setting it up"
sudo useradd -m "$username"
sudo adduser "$username" sudo
echo "$username:$password" | sudo chpasswd
sudo sed -i 's/\/bin\/sh/\/bin\/bash/g' /etc/passwd
echo "User created and configured with username '$username' and password '$password'"

echo "Installing necessary packages"
sudo apt update
sudo apt install -y ubuntu-desktop gnome-terminal dbus-x11 wget curl

echo "Setting up Chrome Remote Desktop"
wget https://dl.google.com/linux/direct/chrome-remote-desktop_current_amd64.deb
sudo dpkg --install chrome-remote-desktop_current_amd64.deb
sudo apt install --assume-yes --fix-broken

echo "Configuring Chrome Remote Desktop for Ubuntu Desktop"
echo "exec /usr/bin/gnome-session" | sudo tee /etc/chrome-remote-desktop-session

sudo adduser "$username" chrome-remote-desktop

echo "Installing Google Chrome"
wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
sudo dpkg --install google-chrome-stable_current_amd64.deb
sudo apt install --assume-yes --fix-broken

# Prompt user for CRP value
read -p "Enter CRP value: " CRP

echo "Finalizing Setup"
if [ "$Autostart" = true ]; then
    mkdir -p "/home/$username/.config/autostart"
    link="https://youtu.be/d9ui27vVePY?si=TfVDVQOd0VHjUt_b"
    colab_autostart="[Desktop Entry]\nType=Application\nName=Colab\nExec=sh -c 'sensible-browser $link'\nIcon=\nComment=Open a predefined notebook at session signin.\nX-GNOME-Autostart-enabled=true"
    echo -e "$colab_autostart" | sudo tee "/home/$username/.config/autostart/colab.desktop"
    sudo chmod +x "/home/$username/.config/autostart/colab.desktop"
    sudo chown "$username:$username" "/home/$username/.config"
fi

# Restart CRD service properly
sudo kill -9 $(pgrep -f chrome-remote-desktop) 2>/dev/null
sudo rm -rf /tmp/.X11-unix/X*
sudo /opt/google/chrome-remote-desktop/chrome-remote-desktop --stop
sudo /opt/google/chrome-remote-desktop/chrome-remote-desktop --start

# Start CRD session
command="$CRP --pin=$Pin"
sudo su - "$username" -c "$command"

echo "Setup Completed Successfully"
while true; do sleep 10; done
