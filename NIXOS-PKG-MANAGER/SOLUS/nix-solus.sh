#!/usr/bin/env bash

# tolga erok
# 25 Dec 2023
# bash -c "$(curl -fsSL https://raw.githubusercontent.com/tolgaerok/tolga-scripts/main/NIXOS-PKG-MANAGER/SOLUS/nix-solus.sh)"

clear
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

# Template
# display_message "[${GREEN}✔${NC}]
# display_message "[${RED}✘${NC}]

# Function to display messages
display_message() {
    clear
    echo -e "\n                  Tolga's online Nix-Package setup\n"
    echo -e "\e[34m|--------------------\e[33m Currently configuring:\e[34m-------------------|"
    echo -e "|${YELLOW}==>${NC}  $1"
    echo -e "\e[34m|--------------------------------------------------------------|\e[0m"
    echo ""
   
}

# Ask for the username
display_message "[${GREEN}✔${NC}] User-name required"
echo ""
read -p "Enter the username: " username

# setup nix pkgs on solus
cd /home/$username

display_message "[${GREEN}✔${NC}] Downloading nix pgk manager"

sh <(curl -L https://nixos.org/nix/install) --no-daemon
. /home/$username/.nix-profile/etc/profile.d/nix.sh
nix --version

display_message "[${GREEN}✔${NC}] Setting up profile PATHS"

# Add the following lines to append export statements to .bashrc
echo "export PATH=\"/home/$username/.nix-profile/bin:\$PATH\"" >> /home/$username/.bashrc
echo ". /home/$username/.nix-profile/etc/profile.d/nix.sh" >> /home/$username/.bashrc

sleep 2

display_message "[${GREEN}✔${NC}] Setting up default.nix in $HOME"

# Create a default.nix file in the home directory
echo '{ pkgs ? import <nixpkgs> {} }: pkgs.mkShell { buildInputs = [ pkgs.nixpkgs-fmt ]; }' > /home/$username/default.nix

# Source the modified .bashrc to apply changes without restarting the shell
source /home/$username/.bashrc

sleep 2

# Verify that the changes took effect
nix --version
nix-shell

display_message "[${GREEN}✔${NC}] Finished"
sleep 1
echo -e"\nDone\n"

