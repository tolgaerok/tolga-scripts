#!/bin/bash

backup_SRC="/mnt/linux-data/BACKUP-TEST/2023/"
backup_DST="//192.168.0.3/LinuxData/BUDGET-ARCHIVE"  # Update with the correct SMB share path
#backup_DST="//192.168.0.1/tolga/BUDGET-ARCHIVE"
backup_file="$(date +'%a - %b %d - %Y - %I-%M-%S %p').7z"

# Extract the year, month, and day from the current date
year=$(date +'%Y')
month=$(date +'%b')
day=$(date +'%a %d')

# Create the destination directory if it doesn't exist
sudo mkdir -p "$backup_DST/$year/$month/$day"

echo "Starting backup..."
7z a "/tmp/$backup_file" "$backup_SRC"
if [ $? -ne 0 ]; then
    echo "Backup failed."
    exit 1
fi

echo "Copying backup to destination directory..."
if [ ! -d "/mnt/smb-budget" ]; then
    sudo mkdir "/mnt/smb-budget"
fi

# sudo mount -t cifs -o username=tolga,password=ibm450,vers=1.0 "$backup_DST" /mnt/smb-budget  # Update with the correct SMB share path
sudo mount -t cifs -o username=tolga,password=ibm450,vers=3.0 "$backup_DST" /mnt/smb-budget  # Update with the correct SMB share path

if [ $? -ne 0 ]; then
    echo "Failed to mount SMB share."
    exit 1
fi

sudo mkdir -p "/mnt/smb-budget/$year"
sudo mkdir -p "/mnt/smb-budget/$year/$month"
sudo mkdir -p "/mnt/smb-budget/$year/$month/$day"

sudo cp "/tmp/$backup_file" "/mnt/smb-budget/$year/$month/$day/$backup_file"
if [ $? -ne 0 ]; then
    echo "Failed to copy backup to destination directory."
    exit 1
fi

sudo umount -f /mnt/smb-budget
if [ $? -ne 0 ]; then
    echo "Failed to unmount SMB share."
    exit 1
fi

clear

echo "Backup complete."

echo "Output directories:"
echo "Source: $backup_SRC
"
echo "Destination: $backup_DST/$year/$month/$day
"
echo "Backup file name: $backup_file
"

echo "Full directory path and commands used:
"
echo "Source directory: $backup_SRC
"
echo "Destination directory: $backup_DST/$year/$month/$day"
echo "Backup command: 7z a /tmp/$backup_file $backup_SRC"
echo "Mount command: sudo mount -t cifs -o username=tolga,password=ibm450,vers=3.0 $backup_DST /mnt/smb-budget"
echo "Copy command: sudo cp /tmp/$backup_file /mnt/smb-budget/$year/$month/$day/$backup_file"
echo "Unmount command: sudo umount -f /mnt/smb-budget"
