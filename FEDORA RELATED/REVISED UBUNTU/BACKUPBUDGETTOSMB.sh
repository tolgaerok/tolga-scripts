#!/bin/bash

backup_SRC="/mnt/linux-data/BACKUP-TEST/"
backup_DST="//192.168.0.1/tolga/BACK-UP"
# backup_file="$(date +'%Y-%m-%d_%H-%M-%S').tar.gz"
# backup_file="$(date +'%Y-%m-%d_%I-%M-%S_%p').tar.gz"
backup_file="$(date +'%a - %b %d - %Y - %I-%M-%S %p').tar.gz"

# Extract the year, month, and day from the current date
year=$(date +'%Y')
month=$(date +'%b')
# day=$(date +'%a')
day=$(date +'%a %d')

# Create the destination directory if it doesn't exist
mkdir -p "$backup_DST/$year/$month/$day"

echo "Starting backup..."
tar -czvf "/tmp/$backup_file" "$backup_SRC"
if [ $? -ne 0 ]; then
    echo "Backup failed."
    exit 1
fi

echo "Copying backup to destination directory..."
if [ ! -d "/mnt/smb" ]; then
    sudo mkdir "/mnt/smb"
fi
sudo mount -t cifs "$backup_DST" /mnt/smb -o username=tolga,password=ibm450,vers=1.0
if [ $? -ne 0 ]; then
    echo "Failed to mount SMB share."
    exit 1
fi

sudo mkdir -p "/mnt/smb/$year"
sudo mkdir -p "/mnt/smb/$year/$month"
sudo mkdir -p "/mnt/smb/$year/$month/$day"

sudo cp "/tmp/$backup_file" "/mnt/smb/$year/$month/$day/$backup_file"
if [ $? -ne 0 ]; then
    echo "Failed to copy backup to destination directory."
    exit 1
fi

sudo umount -f /mnt/smb
if [ $? -ne 0 ]; then
    echo "Failed to unmount SMB share."
    exit 1
fi

echo "Backup complete."
