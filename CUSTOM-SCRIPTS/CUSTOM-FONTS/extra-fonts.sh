#!/bin/bash

# Tolga Erok
# 24/2/24

# Run from remote location:
# sudo bash -c "$(curl -fsSL https://raw.githubusercontent.com/tolgaerok/tolga-scripts/main/CUSTOM-SCRIPTS/CUSTOM-FONTS/extra-fonts.sh)"


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

# https://github.com/massgravel/Microsoft-Activation-Scripts

clear

# Check if the script is run as root
if [ "$EUID" -ne 0 ]; then
    echo "Please run this script as root or using sudo."
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

echo '[charm]
name=Charm
baseurl=https://repo.charm.sh/yum/
enabled=1
gpgcheck=1
gpgkey=https://repo.charm.sh/yum/gpg.key' | sudo tee /etc/yum.repos.d/charm.repo

sudo yum install gum -y
clear

# Function to display messages
display_message() {
    clear
    echo -e "\n                  Tolga's Custom font's\n"
    echo -e "\e[34m|--------------------\e[33m Currently configuring:\e[34m-------------------|"
    echo -e "|${YELLOW}==>${NC}  $1"
    echo -e "\e[34m|--------------------------------------------------------------|\e[0m"
    echo ""
    gum spin --spinner dot --title "Stand-by..." -- sleep 1
}

# Function to check and display errors
check_error() {
    local error_msg="$1"
    if [ -n "$error_msg" ]; then
        display_message "[${RED}✘${NC}] Error occurred !!"
        # Print the error details
        echo "Error details: $error_msg"
        gum spin --spinner dot --title "Stand-by..." -- sleep 3
    fi
}

install_custom_fonts() {
    display_message "[${GREEN}✔${NC}]  Installing afew custon font's..."
    
    # Run commands and capture stderr
    error_msg=$(sudo dnf install ibm-plex-mono-fonts ibm-plex-sans-fonts ibm-plex-serif-fonts \
    redhat-display-fonts redhat-text-fonts \
    lato-fonts \
    jetbrains-mono-fonts \
    fira-code-fonts mozilla-fira-mono-fonts mozilla-fira-sans-fonts mozilla-zilla-slab-fonts \
    adobe-source-serif-pro-fonts adobe-source-sans-pro-fonts \
    intel-clear-sans-fonts intel-one-mono-fonts 2>&1)
    check_error "$error_msg"

    # Run commands and capture stderr
    error_msg=$(sudo dnf install curl cabextract xorg-x11-font-utils fontconfig 2>&1)
    check_error "$error_msg"

    # Run commands and capture stderr
    error_msg=$(sudo rpm -i https://downloads.sourceforge.net/project/mscorefonts2/rpms/msttcore-fonts-installer-2.6-1.noarch.rpm 2>&1)
    check_error "$error_msg"
}

# Call the function
install_custom_fonts
