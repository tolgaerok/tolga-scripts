#!/bin/bash
# Tolga Erok
# 30-3-24

# Color Variables
declare -A COLORS
COLORS[RED]='\e[1;31m'
COLORS[GREEN]='\e[1;32m'
COLORS[YELLOW]='\e[1;33m'
COLORS[BLUE]='\e[1;34m'
COLORS[CYAN]='\e[1;36m'
COLORS[WHITE]='\e[1;37m'
COLORS[ORANGE]='\e[1;93m'
COLORS[NC]='\e[0m'

# Check Root Privileges
if [ "$EUID" -ne 0 ]; then
    echo "${COLORS[RED]}Please run this script as root or using sudo.${COLORS[NC]}"
    exit 1
fi

# Display Message Function
display_message() {
    clear
    echo -e "\n  ${COLORS[CYAN]}Tolga's Custom Fonts${COLORS[NC]}"
    echo -e "${COLORS[BLUE]}|------------------------ ${COLORS[YELLOW]}$1${COLORS[BLUE]} -------------------------|"
    echo -e "${COLORS[BLUE]}|--------------------------------------------------------------|${COLORS[NC]}"
    echo ""
}

# Error Check Function (Modified to handle command output directly)
check_error() {
    if [ $? -ne 0 ]; then
        display_message "[${COLORS[RED]}✘${COLORS[NC]}] Error occurred !!"
        echo "Error details: $1"
    fi
}

# Install Custom Fonts Function (Optimized for Manjaro/Arch)
install_custom_fonts() {
    display_message "[${COLORS[GREEN]}✔${COLORS[NC]}] Installing Custom Fonts"

    # Update Package Database (Best Practice)
    echo "Updating package database..."
    sudo pacman -Sy

    # Install Fonts
    display_message "[${COLORS[GREEN]}✔${COLORS[NC]}] Installing Fonts"
    sudo pacman -S --noconfirm --needed \
        ttf-dejavu ttf-liberation noto-fonts ttf-roboto \
        ttf-fira-mono ttf-fira-sans ttf-droid
    check_error "Font Installation"

    # Install Additional Tools
    display_message "[${COLORS[GREEN]}✔${COLORS[NC]}] Installing Additional Tools"
    sudo pacman -S --noconfirm --needed curl cabextract fontconfig
    check_error "Tools Installation"

    # Microsoft Core Fonts (Using AUR for ttf-ms-win10-auto, as it's not in official repos)
    display_message "[${COLORS[GREEN]}✔${COLORS[NC]}] Installing Microsoft Core Fonts via AUR"
    if ! command -v yay &> /dev/null; then
        # Install yay if not available
        echo "Installing yay..."
        sudo pacman -S --noconfirm --needed git
        git clone https://aur.archlinux.org/yay.git
        cd yay
        makepkg -si
        cd ..
        rm -rf yay
    fi
    yay -S --noconfirm ttf-ms-win10-auto
    check_error "Microsoft Core Fonts Installation"
}

# Call the Main Function
install_custom_fonts
