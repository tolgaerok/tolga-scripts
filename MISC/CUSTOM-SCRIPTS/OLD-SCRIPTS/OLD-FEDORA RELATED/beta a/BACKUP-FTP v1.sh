#!/bin/bash

backup_SRC="/mnt/linux-data/BACKUP-TEST/2023/"
backup_DST="192.168.0.9"
backup_port="4231"
backup_dir="/device/Download/"
backup_file="$(date +'%a - %b %d - %Y - %I-%M-%S %p').tar.gz"
username="pc"
password="1970"

echo "Starting backup..."
tar -czvf "/tmp/$backup_file" "$backup_SRC"
if [ $? -ne 0 ]; then
    echo "Backup failed."
    exit 1
fi

echo "Copying backup to FTP server..."

# Connect to FTP server and debug the FTP connection
ftp -inv "$backup_DST" "$backup_port" << EOF
user "$username" "$password"
cd "$backup_dir"
put "/tmp/$backup_file" "$backup_file"
quit
EOF

if [ $? -ne 0 ]; then
    echo "Failed to upload backup to FTP server."
    exit 1
fi

echo "Backup complete."
