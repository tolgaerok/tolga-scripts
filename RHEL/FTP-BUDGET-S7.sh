#!/bin/bash

#####################################################################
# Tolga Erok                                                        #
# 25/5/2023                                                         #
#                                                                   #
# Script: backup_and_upload to FTP Server on Samsung S7             #
# Description: This script performs a backup of a specified source  #
#              directory and uploads the backup file to an FTP      #
#              server. It creates a directory structure on the FTP  #
#              server based on the current date.                    #
#####################################################################

# Check if running as root
if [ "$EUID" -ne 0 ]; then
  echo "This script must be run as root."
  exit 1
fi

backup_SRC="/mnt/linux-data/BACKUP-TEST/2023/"
backup_DST="192.168.0.9"
backup_port="4231"
backup_dir="/device/Download/"
username="pc"
password="1970"

# Extract the year, month, and day from the current date
year=$(date +'%Y')
month=$(date +'%b')
day=$(date +'%a %d')

# Create the destination directory if it doesn't exist
echo "Creating destination directory..."
ftp -inv "$backup_DST" "$backup_port" << EOF
user "$username" "$password"
mkdir "$backup_dir$year"
cd "$backup_dir$year"
mkdir "$month"
cd "$month"
mkdir "$day"
quit
EOF

if [ $? -ne 0 ]; then
  echo "Failed to create destination directory on FTP server."
  exit 1
fi

echo "Starting backup..."
backup_file="$(date +'%a - %b %d - %Y - %I-%M-%S %p').tar.gz"
tar -czvf "/tmp/$backup_file" "$backup_SRC"
if [ $? -ne 0 ]; then
  echo "Backup failed."
  exit 1
fi

echo "Copying backup to FTP server..."
ftp -inv "$backup_DST" "$backup_port" << EOF
user "$username" "$password"
cd "$backup_dir$year/$month/$day"
put "/tmp/$backup_file" "$backup_file"
quit
EOF

if [ $? -ne 0 ]; then
  echo "Failed to upload backup to FTP server."
  exit 1
fi

echo "Backup complete."

