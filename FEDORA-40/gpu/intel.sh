#!/bin/bash
# Tolga Erok
# Aug 5 2024

PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/snap/bin

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

display_message() {
    clear
    echo -e "\n                  Tolga's INTEL flatpak updater\n"
    echo -e "\e[34m|--------------------\e[33m Currently configuring:\e[34m-------------------|"
    echo -e "|${YELLOW}==>${NC}  $1"
    echo -e "\e[34m|--------------------------------------------------------------|\e[0m"
    echo ""
    gum spin --spinner dot --title "Stand-by..." -- sleep 1
}

# Function to check and display errors
check_error() {
    if [ $? -ne 0 ]; then
        display_message "[${RED}✘${NC}] Error occurred !!"
        # Print the error details
        echo "Error details: $1"
        gum spin --spinner dot --title "Stand-by..." -- sleep 8
    fi
}

# Check if Firefox Flatpak is installed
if flatpak list | grep -q org.mozilla.firefox; then
    display_message "INTEL:   Enabling VAAPI in Firefox Flatpak..."
    flatpak override \
        --user \
        --filesystem=host-os \
        --env=LIBVA_DRIVER_NAME=i965 \
        --env=LIBVA_DRIVERS_PATH=/run/host/usr/lib64/dri \
        --env=LIBVA_MESSAGING_LEVEL=1 \
        --env=MOZ_DISABLE_RDD_SANDBOX=1 \
        --env=MOZ_ENABLE_WAYLAND=1 \
        org.mozilla.firefox
    echo -e "\e[1;32m[✔]\e[0m VAAPI has been enabled in Firefox Flatpak."
else
    echo -e "\e[1;33m[!]\e[0m Firefox Flatpak is not installed. Enabling VAAPI in local Firefox installation..."

    # Environment variables for VAAPI on Intel
    export LIBVA_DRIVER_NAME=i965
    export LIBVA_DRIVERS_PATH=/usr/lib64/dri
    export LIBVA_MESSAGING_LEVEL=1
    export MOZ_DISABLE_RDD_SANDBOX=1
    export MOZ_ENABLE_WAYLAND=1

    # Launch Firefox with the environment variables
    firefox
fi

sleep 3
