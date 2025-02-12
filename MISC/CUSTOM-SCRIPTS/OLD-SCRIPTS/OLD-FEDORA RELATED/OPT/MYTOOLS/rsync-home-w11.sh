#!/bin/bash

# Tolga Erok
# 11/5/2023
# About:
#   Personal RSYNC script that only rsyncs selected folders listed in INCLUDE_FOLDERS variables
#   excluding ALL hidden files and folders from /home/tolga/ to //192.168.0.3/LinuxData/HOME/tolga
#
# Version: 1.1e
#
# Change log: [ V1.1a 13/5/2023 ] #   Added "Music" into INCLUDE_FOLDERS variables
# Change log: [ V1.1b 15/5/2023 ] #   Added ".*" to exclude all hidden files and folders in EXCLUDE_DIRS variables
# Change log: [ V1.1c 15/5/2023 ] #   Mounting error: "/mnt/smb-rsync" > "/mnt/smb-rsync/"
# Change log: [ V1.1d 15/5/2023 ] #   Unmount all /mnt points, reload daemon and fstab
# Change log: [ V1.1e 1/6/2023  ] #   Added ".iso*" to exclude all iso files EXCLUDE_DIRS variables

SOURCE_DIR="/home/tolga/"
DEST_DIR="/mnt/smb-rsync/"
USERNAME="tolga"
PASSWORD="ibm450"
SERVER_IP="192.168.0.3"
MOUNT_OPTIONS="credentials=/etc/samba/credentials,uid=$USER,gid=samba,file_mode=0777,dir_mode=0777"

# Unmount smb share
sudo umount -f /mnt/*
sudo umount -l /mnt/*

# Reload daemon and fstab
sudo systemctl daemon-reload

# set variables
INCLUDE_FOLDERS=(
    "Desktop"
    "Documents"
    "Downloads"
    "Music"
    "Pictures"
    "Public"
    "Templates"
    "Videos"
)
EXCLUDE_DIRS=(
    ".*"
)

# mount smb share
sudo mount -t cifs //$SERVER_IP/LinuxData/HOME/$USERNAME $DEST_DIR -o $MOUNT_OPTIONS

# rsync
for folder in "${INCLUDE_FOLDERS[@]}"; do
    rsync -avz --exclude="${EXCLUDE_DIRS[@]}" "$SOURCE_DIR/$folder/" "$DEST_DIR/$folder/"
done

# Reload daemon, fstab and mount -a
sudo systemctl daemon-reload && sudo mount -a
