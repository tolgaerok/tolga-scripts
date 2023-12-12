#!/bin/bash

# Tolga Erok...
# My personal San-Francisco-family Font Downloader
# 18/11/2023
# Run from remote location:::...1112
# sudo bash -c "$(curl -fsSL https://raw.githubusercontent.com/tolgaerok/tolga-scripts/main/Fedora39/San-Francisco-family/San-Francisco-family.sh)"
clear

# Check if the script is run as root
if [ "$EUID" -ne 0 ]; then
    echo "Please run this script as root or using sudo."
    exit 1
fi

# Assign color variables
RED='\e[1;31m'
GREEN='\e[1;32m'
YELLOW='\e[1;33m'
BLUE='\e[1;34m'
CYAN='\e[1;36m'
WHITE='\e[1;37m'
ORANGE='\e[1;93m'
NC='\e[0m'

# Function to display messages
display_message() {
    clear
    echo -e "\n           Tolga's San-Francisco-family Font Downloader\n"
    echo -e "\e[34m|--------------------\e[33m Currently configuring:\e[34m-------------------|"
    echo -e "|${YELLOW}==>${NC}  $1"
    echo -e "\e[34m|--------------------------------------------------------------|\e[0m"
    echo ""
    sleep 1
}

# Function to check and display errors
check_error() {
    if [ $? -ne 0 ]; then
        display_message "[${RED}✘${NC}] Error occurred !!"
        # Print the error details
        echo "Error details: $1"
        sleep 10
    fi
}

# Check OS type
if [ -f "/etc/os-release" ]; then
    source "/etc/os-release"
    OS_NAME="${PRETTY_NAME}"
    case $ID in
        ubuntu)
            FONTS_DIR="/usr/share/fonts/truetype"
            FC_CACHE_CMD="fc-cache -f -v"
            ;;
        fedora | rhel)
            FONTS_DIR="/usr/share/fonts"
            FC_CACHE_CMD="fc-cache -f -v"
            ;;
        arch)
            FONTS_DIR="/usr/share/fonts"
            FC_CACHE_CMD="fc-cache -fv"
            ;;
        debian)
            FONTS_DIR="/usr/share/fonts/truetype"
            FC_CACHE_CMD="fc-cache -f -v"
            ;;
        *)
            FONTS_DIR="/usr/share/fonts"
            FC_CACHE_CMD="fc-cache -f -v"
            ;;
    esac
else
    OS_NAME=$(uname -s)
    FONTS_DIR="/usr/share/fonts"
    FC_CACHE_CMD="fc-cache -f -v"
fi

# Display OS in blue
display_message "[${BLUE}✔${NC}] Detected OS: ${BLUE}${OS_NAME}${NC}"

# Prompt user before extracting fonts
read -p "Do you want to extract the fonts to $FONTS_DIR? (y/n): " extract_choice

if [ "$extract_choice" != "y" ]; then
    display_message "Exiting font extraction. No changes were made."
    exit 0
fi

# Super tweak I/O scheduler
sudo echo "none" | sudo tee /sys/block/sda/queue/scheduler
cat /sys/block/sda/queue/scheduler
sleep 2

sudo mkdir -p "$FONTS_DIR"
zip_file="San-Francisco-family-master.zip"
curl -LJO https://github.com/wvpianoman/San-Francisco-family/archive/refs/heads/master.zip

# Check if the download was successful
if [ -f "$zip_file" ]; then
    # Unzip the contents to the system-wide fonts directory
    sudo unzip -o "$zip_file" -d "$FONTS_DIR"

    # Update font cache
    sudo $FC_CACHE_CMD

    # Remove the ZIP file
    rm "$zip_file"

    display_message "[${GREEN}✔${NC}] Apple/San-Francisco-family fonts installed successfully."
    sleep 1
else
    display_message "[${RED}✘${NC}] Download failed. Please check the URL and try again."
    check_error
    sleep 2
fi

# Removing zip Files
rm ./San-Francisco-family-master.zip
sudo $FC_CACHE_CMD
