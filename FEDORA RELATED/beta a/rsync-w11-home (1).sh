#!/usr/bin/env bash

# set variables
SOURCE_DIR="/mnt/windows-data/"
DEST_DIR="/run/media/tolga/WINDOW DATA/"
USERNAME="tolga"
PASSWORD="ibm450"
EXCLUDE_DIRS=(
    "System Volume Information"
    ".*"
    "$RECYCLE.BIN"
    "Thumbs*"
)

# mount smb share
sudo mount -t cifs "$SOURCE_DIR" "$DEST_DIR" -o username="$USERNAME",password="$PASSWORD"

# rsync
rsync -avz --exclude="${EXCLUDE_DIRS[@]}" --update --progress --stats \
    --bwlimit=10000 --no-o --no-g --no-perms --no-owner --no-group \
    --usermap='*:tolga' \
    "$SOURCE_DIR/" "$DEST_DIR/"

# unmount smb share
#sudo umount "$DEST_DIR"
