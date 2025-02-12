#!/bin/bash

# Tolga Erok
# 31/12/2023

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
    echo -e "\n                  Tolga's Snap service and app manager\n"
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
    while [[ ! "$response" =~ ^(stop|disable|list|exit)$ ]]; do
        read -p "Do you want to (stop) and disable Snap services, (list) installed apps, or (exit)? " response
    done

    if [ "$response" == "stop" ]; then
        # Stop Snap services
        sudo systemctl stop snapd.socket
        sudo systemctl stop snapd.service

        # Disable Snap services
        sudo systemctl disable snapd.socket
        sudo systemctl disable snapd.service

        # Reload systemd manager
        sudo systemctl daemon-reload

        display_message "[${GREEN}✔${NC}] Snap services stopped and disabled."
    elif [ "$response" == "list" ]; then
        # List installed Snap apps
        snap_list=$(snap list)
        display_message "Installed Snap applications:\n\n${snap_list}"

        read -p "Do you want to uninstall each app individually? (yes/no): " uninstall_response

        if [ "$uninstall_response" == "yes" ]; then
            for app in $(echo "$snap_list" | awk '{print $1}'); do
                read -p "Do you want to uninstall $app? (yes/no): " uninstall_app_response
                if [ "$uninstall_app_response" == "yes" ]; then
                    sudo snap remove "$app"
                    display_message "Uninstalled $app."
                else
                    display_message "Skipped uninstalling $app."
                fi
            done
        else
            display_message "[${YELLOW}✔${NC}] Skipped uninstalling Snap applications."
        fi
    else
        display_message "[${YELLOW}✔${NC}] Snap services were not modified. Exiting..."
    fi
else
    display_message "[${YELLOW}✔${NC}] Snap services are not currently active."
fi
