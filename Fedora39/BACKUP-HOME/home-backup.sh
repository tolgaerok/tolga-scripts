#!/bin/bash

# Personal home folder archiver backup
# Tolga Erok. ¯\_(ツ)_/¯
# 1/1/2024

# Run from remote location:
# bash -c "$(curl -fsSL https://raw.githubusercontent.com/tolgaerok/tolga-scripts/main/Fedora39/BACKUP-HOME/home-backup.sh)"

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

# Check if the script is run with sudo from terminal
if [ "$(id -u)" -eq 0 ]; then
    echo "Please do not run this script as root or with sudo privileges."
    exit 1
fi

# Define the backup folder path
backup_folder="$HOME"

# Get the current date and time in the required format
current_date=$(date +"%Y_%b_%a_%l-%M%p")
backup_subfolder=$(date +"%Y/%b/%a_%l_%M%p")

# Create the backup folder structure if it doesn't exist
mkdir -p "$backup_folder/$backup_subfolder"

# Define the backup filename without extension
backup_filename=$(date +"%a_%l_%M%p")

# Navigate to the home folder before executing zip
cd "$HOME" || exit

# Include specific default folders while excluding dot files (except .config) and exclude trash/rubbish bin
zip -r "$backup_folder/$backup_subfolder/$backup_filename.zip" \
    "$HOME/Documents" \
    "$HOME/Pictures" \
    "$HOME/Downloads" \
    "$HOME/.config" \
    -x ".local/share/Trash/*" \
    -x ".*"

echo "Backup completed and stored in $backup_folder/$backup_subfolder/$backup_filename.zip"

