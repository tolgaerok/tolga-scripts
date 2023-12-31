#!/bin/bash

# Tolga Erok
# 31/12/203



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

# Check if Snap is present
if command -v snap &> /dev/null
then
    snap_version=$(snap --version)
    snap_series=$(snap version | grep series | awk '{print $2}')
    snap_info="Snap version: $snap_version\nSeries: $snap_series"

    display_message "[${GREEN}✔${NC}] Snap is present.\n\n${snap_info}"
    
    read -p "Do you want to stop and disable Snap services? (y/n): " response
    if [ "$response" == "y" ]; then
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
    display_message "[${RED}✖${NC}] Snap is not installed on this system."
fi
