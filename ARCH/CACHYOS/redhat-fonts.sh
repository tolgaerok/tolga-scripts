#!/bin/bash
# Tolga Erok
# 30-3-24

# Check if the script is run as root
if [ "$EUID" -ne 0 ]; then
    echo "Please run this script as root or using sudo."
    exit 1
fi

# Assign a color variable
RED='\e[1;31m'
GREEN='\e[1;32m'
YELLOW='\e[1;33m'
BLUE='\e[1;34m'
CYAN='\e[1;36m'
WHITE='\e[1;37m'
ORANGE='\e[1;93m'
NC='\e[0m'

# Display messages function
display_message() {
    clear
    echo -e "\n                  Tolga's Custom font's\n"
    echo -e "\e[34m|--------------------\e[33m Currently configuring:\e[34m-------------------|"
    echo -e "|${YELLOW}==>${NC}  $1"
    echo -e "\e[34m|--------------------------------------------------------------|\e[0m"
    echo ""
}

# Function to check and display errors
check_error() {
    local error_msg="$1"
    # Check if error_msg contains actual error messages
    if [[ "$error_msg" == *"error"* || "$error_msg" == *"Error"* ]]; then
        display_message "[${RED}✘${NC}] Error occurred !!"
        # Print the error details
        echo "Error details: $error_msg"
    fi
}

# Function to install custom fonts
install_custom_fonts() {
    display_message "[${GREEN}✔${NC}]  ..:: Installing afew custom fonts ::.."

    # Install fonts
    sudo pacman -S --noconfirm --needed ttf-dejavu ttf-liberation noto-fonts ttf-roboto ttf-fira-mono ttf-fira-sans ttf-droid

    # Install additional tools
    sudo pacman -S --noconfirm --needed curl cabextract fontconfig

    # Install Microsoft Core Fonts (assuming ttf-ms-win10-auto provides it)
    sudo pacman -S --noconfirm --needed cachyos/ttf-ms-win10-auto

    # Check for errors after each installation
    check_error ""
}

# Call the function
install_custom_fonts
