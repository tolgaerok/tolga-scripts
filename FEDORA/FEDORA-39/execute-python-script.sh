#!/bin/bash

# Tolga Erok.
# My personal Fedora 39 KDE python launcher
# 23/11/2023

# Run from remote location
# sudo bash -c "$(curl -fsSL https://raw.githubusercontent.com/tolgaerok/tolga-scripts/main/Fedora39/execute-python-script.sh)"

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

# List of required Python packages for Fedora
essential_packages=("python3" "python3-pip" "python3-setuptools" "python3-devel")

# Function to check and install essential packages for Fedora
install_essentials() {
    for package in "${essential_packages[@]}"; do
        if ! rpm -q "$package" &>/dev/null; then
            echo "Installing $package..."
            sudo dnf install -y "$package"
        else
            echo "$package is already installed."
        fi
    done
}

# Check and install essential packages
install_essentials

# Execute the Python code
curl -fsSL https://raw.githubusercontent.com/tolgaerok/tolga-scripts/main/Fedora39/TolgasFedoraUpdaterApp.py | python3 -
