#!/bin/bash

# Tolga Erok
# Simple rsync script
# 23/4/24

# rsync user home folder to server in this case located on:
# smb://192.168.0.11/tolga/F39-BACKUP/RSYNC/FEDORA/TOLGA/


# Parameters
SOURCE_DIR="/home/$(whoami)"
SERVER_IP="192.168.0.11"
SHARE_PATH="tolga/F39-BACKUP/RSYNC/FEDORA/TOLGA"
MOUNT_DIR="/mnt/smb-rsync"

# Mount options (create credentials file in /etc/samba and put server user and password)
MOUNT_OPTIONS="credentials=/etc/samba/credentials,uid=$(id -u),gid=$(id -g)"

# Function to mount the SMB share from set value
mount_smb_share() {
    sudo mkdir -p "$MOUNT_DIR"
    sudo mount -t cifs "//$SERVER_IP/$SHARE_PATH" "$MOUNT_DIR" -o "$MOUNT_OPTIONS"
}

# Function to unmount the SMB share in the parameters above
unmount_smb_share() {
    sudo umount "$MOUNT_DIR"
    sudo rmdir "$MOUNT_DIR"
}

# Function to forcefully unmount anything mounted at the specified mount point on local machine
force_unmount() {
    echo "Forcefully unmounting anything mounted at $MOUNT_DIR..."
    if mountpoint -q "$MOUNT_DIR"; then
        sudo umount -f "$MOUNT_DIR" || { echo "Failed to forcefully unmount $MOUNT_DIR."; exit 1; }
        echo "Successfully forcefully unmounted $MOUNT_DIR."
    else
        echo "$MOUNT_DIR is not currently mounted."
    fi
}

# Function to perform rsync to server (lmde6)
perform_rsync() {
    rsync -az --progress --bwlimit=1000M --relative --hard-links --update --stats --exclude=".*" --exclude=".*/" --exclude="lost+found/" "$SOURCE_DIR/" "$MOUNT_DIR/"

}

# Main function
main() {
    echo "Forcefully unmounting anything mounted at $MOUNT_DIR..."
    force_unmount

    echo "Mounting SMB share..."
    mount_smb_share || { echo "Failed to mount SMB share. Exiting."; exit 1; }
    echo "SMB share mounted successfully."

    echo "Performing rsync..."
    perform_rsync || { echo "Rsync operation failed. Exiting."; unmount_smb_share; exit 1; }
    echo "Rsync completed."

    echo "Unmounting SMB share..."
    unmount_smb_share || echo "Failed to unmount SMB share."

    echo "Script execution completed."
}

# Execute main function
main
