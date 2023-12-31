#!/bin/bash

# Tolga Erok
# 31/12/203

# Run from remote location:
# sudo bash -c "$(curl -fsSL https://raw.githubusercontent.com/tolgaerok/tolga-scripts/main/Fedora39/STOP-SNAP-SERVICE/stop_snap_service.sh)"

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

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color
RESET='\033[0m'

display_message() {
    clear
    echo -e "\n                  Tolga's Snap service disabler\n"
    echo -e ""
    echo -e "|${YELLOW}  ==>${NC}  $1"
    echo -e "\e[34m|--------------------------------------------------------------|\e[0m"
    echo ""
}

# Check if Snap is installed
if ! command -v snap &> /dev/null; then
    display_message "[${RED}✖${NC}] Snap is not installed on this system."
    exit 1
fi

# Check if Snap services are active
snap_services_active() {
    sudo systemctl is-active --quiet snapd.socket && sudo systemctl is-active --quiet snapd.service
}

if snap_services_active; then
    display_message "[${GREEN}✔${NC}] Snap services are currently active."

    response=""
    while [[ ! "$response" =~ ^[yYnN]$ ]]; do
        read -p "Do you want to stop and disable Snap services? (y/n): " response
    done

    if [ "$response" == "y" ] || [ "$response" == "Y" ]; then
        # Stop Snap services
        sudo systemctl stop snapd.socket
        sudo systemctl stop snapd.service

        # Disable Snap services
        sudo systemctl disable snapd.socket
        sudo systemctl disable snapd.service

        # Reload systemd manager
        sudo systemctl daemon-reload

        display_message "[${GREEN}✔${NC}] Snap services stopped and disabled."
    else
        display_message "[${YELLOW}✔${NC}] Snap services were not modified. Exiting..."
    fi
else
    display_message "[${YELLOW}✔${NC}] Snap services are not currently active."
fi


