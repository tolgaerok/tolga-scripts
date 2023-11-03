#!/bin/bash

# Check if running as root
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root."
   exit 1
fi

# Function to create folder if it doesn't exist
create_folder() {
    if [ ! -d "$1" ]; then
        echo "Creating folder: $1"
        sudo mkdir -p "$1"
    fi
}

# Copy files function
copy_files() {
    echo "Copying files to $2"
    sudo cp "$1" "$2"
}

# Mount the shares and start services
echo "Mounting the shares and starting services"
sudo mount -a || { echo "Mount failed"; exit 1; }
sudo systemctl enable smb nmb || { echo "Failed to enable services"; exit 1; }
sudo systemctl restart smb.service nmb.service || { echo "Failed to restart services"; exit 1; }
sudo systemctl daemon-reload

# Test the fstab entries
echo "Testing the fstab entries"
sudo ls /media/w11-home || { echo "Failed to list Linux data"; exit 1; }
sudo ls /mnt/linux-data || { echo "Failed to list Linux data"; exit 1; }
sudo ls /mnt/smb || { echo "Failed to list SMB share"; exit 1; }
sudo ls /mnt/windows-data || { echo "Failed to list Windows data"; exit 1; }

# Copy WALLPAPER to /usr/share/backgrounds
echo "Copying WALLPAPER to /usr/share/backgrounds"
wallpaper_path="/usr/share/backgrounds/Fedora"

create_folder "$wallpaper_path"
copy_files "./SYS-FILES/IMAGES/WALLPAPER/fedora.jpg" "$wallpaper_path"

echo "Continuing..."
sleep 1
clear

# Copy samba files
echo "Copying samba files"
script_folder="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
backup_folder="/etc/samba/backup"
original_folder="/etc/samba/ORIGINAL"

create_folder "$backup_folder"
create_folder "$original_folder"

shopt -s extglob
mv /etc/samba/!(ORIGINAL) "$original_folder"
cp -R "$original_folder"/* "$backup_folder"

source_folder="$script_folder/SYS-FILES/samba"

if [ -d "$source_folder" ]; then
    cp -R "$source_folder"/* /etc/samba
else
    echo "Source folder not found: $source_folder"
fi

systemctl restart smb.service

# Copy script files
echo "Copying script files"
script_folder="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source_folder="$script_folder/SYS-FILES/SCRIPTS"
destination_folder="/opt/MYTOOLS"

create_folder "$destination_folder"

if [ -d "$source_folder" ]; then
    cp -R "$source_folder"/* "$destination_folder"
    chmod -R +rwx "$destination_folder"
    echo "Files copied successfully to $destination_folder."
else
    echo "Source folder not found: $source_folder"
fi

echo "Complete"
echo "Done... Close the window."

exit 0
