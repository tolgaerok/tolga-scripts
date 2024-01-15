#!/bin/bash
# tolga erok
# 15/1/2024

# Replace these values with your actual SMB share details
SMB_SERVER="192.168.0.11"
SMB_SHARE_PATH="/tolga/T3"
USERNAME="tolga"
PASSWORD="xxxxxxxxxxxxxxxx"
MOUNT_POINT="/mnt/smb"

# Create the mount point if it does not exist
[ -d "$MOUNT_POINT" ] || sudo mkdir -p "$MOUNT_POINT"

# Mount the SMB share with optimized options
sudo mount -t cifs -o username=$USERNAME,password=$PASSWORD,vers=3.0,uid=$(id -u),gid=$(id -g),cache=loose //$SMB_SERVER$SMB_SHARE_PATH "$MOUNT_POINT"

# Check if the mount was successful
if [ $? -eq 0 ]; then
    echo "SMB share mounted successfully."

    # Run rsync with optimizations
    rsync -h --progress --stats --compress -r -tgo -p -l -D --update --delete-after --protect-args -e "ssh -T -c arcfour -o Compression=no -x" --bwlimit=100m /home/tolga/ "$MOUNT_POINT"

    # Unmount the SMB share after rsync
    sudo umount "$MOUNT_POINT"
    echo "SMB share unmounted."
else
    echo "Failed to mount SMB share."
fi
