#!/bin/bash

# Tolga Erok
# 27-12-2023
# bash -c "$(curl -fsSL https://raw.githubusercontent.com/tolgaerok/tolga-scripts/main/Fedora39/PACKAGE-MANAGER/package-manager.sh)"

# Inspired by Brian Francisco

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
    echo -e "\n                  Tolga's fedora script package management\n"
    echo -e "\e[34m|--------------------\e[33m Inspired by Brian Francisco \e[34m-------------------|"
    echo -e "|${YELLOW}==>${NC}  $1"
    echo -e "\e[34m|--------------------------------------------------------------------|\e[0m"
    echo ""
    sleep 1
}

# Function to create a list of user/local installed packages
create_user_installed_list() {
    dnf repoquery --userinstalled > ~/installed-packages.txt
    display_message "[${GREEN}✔${NC}] Creating user installed package list"
    sleep 0.5
}

# Function to create a list of all installed packages on user's system
create_all_installed_list() {
    dnf repoquery --installed > ~/packages.txt
    display_message "[${GREEN}✔${NC}] Creating list if local installed package list"
    sleep 0.5
}

# Function to show the installed packages on current set-up
show_installed_packages() {
    display_message "[${GREEN}✔${NC}] Installed package list"
    echo "Installed packages:"
    dnf list installed
    read -p "  Press enter to continue:==> "
}

# Function to prepare the file for dnf shell use
prep_file_for_dnf_shell() {

    display_message "[${GREEN}✔${NC}] Prepare installed package list"
    if [ -s ~/installed-packages.txt ]; then
        sed 's/^/install /' ~/installed-packages.txt > ~/pkgs.txt
        echo "run" >> ~/pkgs.txt
        echo "File prepared successfully."
        echo ""
        read -p "  Press enter to continue:==> "
    else
        display_message "[${RED}✘${NC}] ERROR"
        echo "Error: The list of user-installed packages is empty."
        sleep 3
    fi
}

# Function to install all packages from the prepared file
install_packages() {
    display_message "[${GREEN}✔${NC}] Installing package list"
    sleep 0.5
    dnf shell ~/pkgs.txt
    echo ""
    read -p "  Installed, press enter to continue:==> "
}

# Main menu
while true; do
    clear
    display_message "[${GREEN}✔${NC}] Main Menu"
    echo " 1. Create a list of user && all installed packages"
    echo " 2. Show installed packages"
    echo " 3. Prepare the file for dnf shell use"
    echo " 4. Install packages on a new system"
    echo ""
    echo -e "\e[34m|-------------------------------------------------------------------|\e[0m"

    echo "  6. Exit"
    echo -e "\e[34m|-------------------------------------------------------------------|\e[0m"

    read -p "  Choose an option (1-6): " choice

    case $choice in
        1)
            create_user_installed_list
            create_all_installed_list
            ;;
        2)
            show_installed_packages
            ;;
        3)
            prep_file_for_dnf_shell
            ;;
        4)
            install_packages
            ;;

        6)
            echo "Exiting script."
            exit 0
            ;;
        *)
            echo "Invalid option. Please choose a number between 1 and 6."
            sleep 1.5
            ;;
    esac
done
