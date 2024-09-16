#!/bin/bash
# Tolga Erok
# 16 Sep 2024

# Define colors and symbols
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
WHITE='\033[1;37m'   # Bright white for Flatpak names
NC='\033[0m'         # No Color
TICK='\u2714'        # Unicode for check mark
RED='\033[0;31m'     # Red for error messages

clear

# Remote flatpak list (my personal collection)
FLATPAK_LIST=$(curl -s https://raw.githubusercontent.com/tolgaerok/tolga-scripts/main/FEDORA-40/flatpaks | tr '\n' ' ')

# Add Flathub remote repository if it doesn't already exist
echo -e "${YELLOW}Adding Flathub repository if not present...${NC}"
flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo

# Install or update the Flatpaks from my list
echo -e "${YELLOW}****************************************************${NC}"
echo -e "${RED}Installing or updating Flatpaks from Tolga's list...${NC}"
echo -e "${YELLOW}****************************************************${NC}\n"
for app in $FLATPAK_LIST; do
    if [ -n "$app" ]; then
        echo -e "${YELLOW}Processing: ${WHITE}$app${NC}"
        flatpak --system -y install --or-update flathub "$app" > /dev/null 2>&1
        if [ $? -eq 0 ]; then
            echo -e "${GREEN}[$TICK] Successfully installed or updated: ${WHITE}$app${NC}\n"
        else
            echo -e "${RED}✘ Failed to process: ${WHITE}$app${NC}\n"
        fi
    fi
done

# Check & Install Distrobox if not already installed
if ! command -v distrobox &> /dev/null; then
    echo -e "${YELLOW}Installing Distrobox...${NC}"
    curl -s https://raw.githubusercontent.com/89luca89/distrobox/main/install | sudo sh
    sudo dnf copr enable alciregi/distrobox
    sudo dnf install -y distrobox
else
    echo -e "${GREEN}Distrobox is already installed.${NC}\n"
fi

echo -e "${GREEN}All operations completed.${NC}"

