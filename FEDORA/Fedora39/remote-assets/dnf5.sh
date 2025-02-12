#!/bin/bash

# Tolga Erok.
# My personal Fedora 39 KDE tweaker
# 18/11/2023 .

# Run from remote location:::.
# sudo bash -c "$(curl -fsSL https://raw.githubusercontent.com/tolgaerok/tolga-scripts/main/Fedora39/remote-assets/multimedia.sh)"

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

# Assign a color variable based on the RANDOM number
RED='\e[1;31m'
GREEN='\e[1;32m'
YELLOW='\e[1;33m'
BLUE='\e[1;34m'
CYAN='\e[1;36m'
WHITE='\e[1;37m'
ORANGE='\e[1;93m'
NC='\e[0m' # Keep this line only once

# Check if the script is run as root
if [ "$EUID" -ne 0 ]; then
    echo "Please run this script as root or using sudo."
    exit 1
fi

# Function to display messages
display_message() {
    clear
    echo -e "\n                  Tolga's online fedora updater\n"
    echo -e "\e[34m|--------------------\e[33m Currently configuring:\e[34m-------------------|"
    echo -e "| ===>    $1"
    echo -e "\e[34m|--------------------------------------------------------------|\e[0m"
    echo ""
    sleep 1
}

# Function to check and display errors
check_error() {
    if [ $? -ne 0 ]; then
        display_message "Error occurred. Exiting."

        # Print the error details
        echo "Error details: $1"
        exit 1
    fi
}

# Install new dnf5
dnf5() {
    # Ask the user if they want to install dnf5
    display_message "Beta: DNF5 for fedora 40/41 testing"
    read -p "Do you want to install dnf5? (y/n): " install_dnf5
    if [[ $install_dnf5 =~ ^[Yy]$ ]]; then
        sudo dnf install dnf5 -y
        sleep 1
        display_message "Updating system via DNF5.."
        sudo dnf5 update && sudo dnf5 makecache
        sleep 2
        display_message "In order to use dnf, you need to use sudo dnf5 update"
        sleep 3

    else
        check_error
        echo "Aborted installation of dnf5. Returning to the main menu."
    fi

}

# Call the function to install multimedia codecs
dnf5
