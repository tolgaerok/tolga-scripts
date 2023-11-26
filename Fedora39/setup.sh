#!/bin/bash
# Tolga erok
# my personal fedora39 setup file
# bash -c "$(curl -fsSL https://raw.githubusercontent.com/tolgaerok/tolga-scripts/main/Fedora39/setup.sh)"

# Check if the effective user ID (EUID) is equal to 0 (root) or if the script is run with sudo
if [ "$EUID" -eq 0 ] || [ "$(id -u)" -eq 0 ]; then
    clear
    echo ""
    echo "Please do not run this script as root or using sudo."
    echo ""
    exit 1
fi

# Function to display messages
display_message() {
    clear
    echo -e "\n                  Tolga's online fedora updater\n"
    echo -e "\e[34m|--------------------\e[33m Setup Complete \e[34m-------------------|"
    echo -e "|      ===>    $1"
    echo -e "\e[34m|-------------------------------------------------------|\e[0m"
    echo "" 
    sleep 1
}

# Define URLs
DESKTOP_FILE_URL="https://raw.githubusercontent.com/tolgaerok/tolga-scripts/main/Fedora39/my-online-fedora.desktop"
MY_TOOLS_URL="https://raw.githubusercontent.com/tolgaerok/tolga-scripts/main/Fedora39/MY-TOOLS.zip"

# Paths
DESKTOP_FILE_DEST="$HOME/Desktop/my-online-fedora.desktop"
MY_TOOLS_DEST="$HOME/.config/MY-TOOLS"

# Download and copy desktop file
curl -o "$DESKTOP_FILE_DEST" "$DESKTOP_FILE_URL"

# Download MY-TOOLS folder
wget -O /tmp/MY-TOOLS.zip "$MY_TOOLS_URL"

# Create MY-TOOLS directory if it doesn't exist
mkdir -p "$HOME/.config/MY-TOOLS"

# Extract MY-TOOLS folder to ~/.config/
unzip -q -o "/tmp/MY-TOOLS.zip" -d "$HOME/.config/"

# Set permissions
chmod +x "$DESKTOP_FILE_DEST"
chmod -R +xw "$HOME/.config/MY-TOOLS"

# Clean up
rm /tmp/MY-TOOLS.zip

clear
display_message "Files copied and permissions set successfully."
sleep 1
display_message "Check new shortcut on your desktop"
