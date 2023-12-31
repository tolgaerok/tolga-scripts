#!/bin/bash

# Tolga Erok
# 12/5/2023
# About:
#   Personal RSYNC script that only rsyncs selected folders listed in INCLUDE_FOLDERS variables
#   excluding ALL hidden files and folders from //192.168.0.3/LinuxData/HOME/tolga into /home/tolga
#
# Version: 1.2
#
# Change log:
#   Added "Music" into INCLUDE_FOLDERS variables
# Corrected wrong permissions and group created on /home/tolga when transferred back into home folder:
#   Added sudo chown -R tolga:tolga "$DEST_DIR/$folder
#   Added sudo chmod -R u+rwx "$DEST_DIR/$folder

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
    ".cache"
)

SOURCE_DIR="/mnt/smb-rsync"
DEST_DIR="/home/tolga/"
USERNAME="tolga"
PASSWORD="ibm450"
SERVER_IP="192.168.0.3"
MOUNT_OPTIONS="credentials=/etc/samba/credentials,uid=$USER,gid=samba,file_mode=0777,dir_mode=0777"

# mount smb share
sudo mount -t cifs //$SERVER_IP/LinuxData/HOME/$USERNAME $SOURCE_DIR -o $MOUNT_OPTIONS

# rsync
for folder in "${INCLUDE_FOLDERS[@]}"; do
    rsync -avz --exclude="${EXCLUDE_DIRS[@]}" "$SOURCE_DIR/$folder/" "$DEST_DIR/$folder/"
    sudo chown -R tolga:tolga "$DEST_DIR/$folder/"
    sudo chmod -R u+rwx "$DEST_DIR/$folder/"
done


# unmount smb share
sudo umount $SOURCE_DIR
