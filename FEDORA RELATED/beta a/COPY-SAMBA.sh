#!/bin/bash

# Get the script's folder path
script_folder="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Define the backup folder path
backup_folder="/etc/samba/backup"

# Create the backup folder if it doesn't exist
mkdir -p "$backup_folder"

# Define the original folder path
original_folder="/etc/samba/ORIGINAL"

# Create the original folder if it doesn't exist
mkdir -p "$original_folder"

# Move contents of /etc/samba to original folder
mv /etc/samba/* "$original_folder"

# Move the original folder to backup folder
mv "$original_folder" "$backup_folder"

# Create a new original folder
mkdir -p "$original_folder"

# Copy contents of samba folder to /etc/samba
cp -R "$script_folder/SYS-FILES/samba"/* /etc/samba

# Refresh /etc/samba
systemctl restart smb.service
