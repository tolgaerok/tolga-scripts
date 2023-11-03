#!/usr/bin/env bash

# set variables
SOURCE_DIR="//192.168.0.3/LinuxData"
DEST_DIR="/run/media/tolga/LINUX DATA"
USERNAME="tolga"
PASSWORD="ibm450"
EXCLUDE_DIRS=(
    "System Volume Information"
    "*"
    "*$"
)

# mount smb share
sudo mount -t cifs "$SOURCE_DIR" "$DEST_DIR" -o username="$USERNAME",password="$PASSWORD"

# rsync
rsync -avz --exclude-from=<(printf "%s\n" "${EXCLUDE_DIRS[@]}") --ignore-errors --progress --stats \
    --bwlimit=10000 --no-o --no-g --no-perms --no-owner --no-group \
    --usermap='*:tolga' \
    "$SOURCE_DIR/" "$DEST_DIR/"

# unmount smb share
sudo umount "$DEST_DIR"
