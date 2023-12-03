#!/bin/bash
# Tolga erok
# my personal fedora39 setup file...


# bash -c "$(curl -fsSL https://raw.githubusercontent.com/tolgaerok/tolga-scripts/main/Fedora39/setup.sh)"

#  ¯\_(ツ)_/¯
#    █████▒▓█████ ▓█████▄  ▒█████   ██▀███   ▄▄▄
#  ▓██   ▒ ▓█   ▀ ▒██▀ ██▌▒██▒  ██▒▓██ ▒ ██▒▒████▄
#  ▒████ ░ ▒███   ░██   █▌▒██░  ██▒▓██ ░▄█ ▒▒██  ▀█▄
#  ░▓█▒  ░ ▒▓█  ▄ ░▓█▄   ▌▒██   ██░▒██▀▀█▄  ░██▄▄▄▄██
#  ░▒█░    ░▒████▒░▒████▓ ░ ████▓▒░░██▓ ▒██▒ ▓█   ▓██▒
#   ▒ ░    ░░ ▒░ ░ ▒▒▓  ▒ ░ ▒░▒░▒░ ░ ▒▓ ░▒▓░ ▒▒   ▓▒█░
#   ░       ░ ░  ░ ░ ▒  ▒   ░ ▒ ▒░   ░▒ ░ ▒░  ▒   ▒▒ ░
#   ░ ░       ░    ░ ░  ░ ░ ░ ░ ▒    ░░   ░   ░   ▒
#   ░  ░      ░    ░ ░     ░              ░  ░   ░

clear

# Check if the effective user ID (EUID) is equal to 0 (root) or if the script is run with sudo
if [ "$EUID" -eq 0 ] || [ "$(id -u)" -eq 0 ]; then
    clear
    echo ""
    echo "Please do not run this script as root or using sudo."
    echo ""
    exit 1
fi

# Assign a color variable based on the RANDOM number
RED='\e[1;31m'
GREEN='\e[1;32m'
YELLOW='\e[1;33m'
BLUE='\e[1;34m'
CYAN='\e[1;36m'
WHITE='\e[1;37m'
ORANGE='\e[1;93m'
NC='\e[0m'
YELLOW='\e[1;33m'
NC='\e[0m'

# Function to display messages
display_message() {
    clear
    echo -e "\n                  Tolga's online fedora setup\n"
    echo -e "\e[34m|--------------------\e[33m Setup Complete \e[34m-------------------|"
    echo -e "|${YELLOW}==>${NC}    $1"
    echo -e "\e[34m|-------------------------------------------------------|\e[0m"
    echo "" 
    sleep 1
}

# Define URLs
DESKTOP_FILE_URL="https://raw.githubusercontent.com/tolgaerok/tolga-scripts/main/Fedora39/my-online-fedora.desktop"
DESKTOP_FILE_URL2="https://raw.githubusercontent.com/tolgaerok/tolga-scripts/main/Fedora39/google-chrome.desktop"
MY_TOOLS_URL="https://raw.githubusercontent.com/tolgaerok/tolga-scripts/main/Fedora39/MY-TOOLS.zip"

# Paths
DESKTOP_FILE_DEST="$HOME/Desktop/my-online-fedora.desktop"
DESKTOP_FILE_DEST2="$HOME/Desktop/google-chrome.desktop"
MY_TOOLS_DEST="$HOME/.config/MY-TOOLS"

# Download and copy desktop file
curl -o "$DESKTOP_FILE_DEST" "$DESKTOP_FILE_URL"
curl -o "$DESKTOP_FILE_DEST2" "$DESKTOP_FILE_URL2"

# Hardcode the full path to the icon in the desktop file
ICON_PATH="/$HOME/.config/MY-TOOLS/images/tolga-profile-5.png"
sed -i "s|Icon=.*|Icon=$ICON_PATH|" "$DESKTOP_FILE_DEST"

# Download MY-TOOLS folder
wget -O /tmp/MY-TOOLS.zip "$MY_TOOLS_URL"

# Create MY-TOOLS directory if it doesn't exist
mkdir -p "$HOME/.config/MY-TOOLS"

# Extract MY-TOOLS folder to ~/.config/
unzip -q -o "/tmp/MY-TOOLS.zip" -d "$HOME/.config/"

# Set permissions
chmod +x "$DESKTOP_FILE_DEST"
chmod +x "$DESKTOP_FILE_DEST2"
chmod -R +xw "$HOME/.config/MY-TOOLS"

# Clean up
rm /tmp/MY-TOOLS.zip

clear
display_message "Files copied and permissions set successfully."
sleep 1
display_message "Check new shortcut(s) on your desktop"
