#!/bin/bash
# Tolga Erok
# 9/5/2023
# Version: 1.1a
#
# Change log:
#   13/5/2023 [ Added sudo systemctl daemon-reload && sudo mount -a ]

sudo systemctl daemon-reload && sudo mount -a

# Unmount all mounted filesystems under /mnt
sudo umount -f /mnt/*
sudo umount -l /mnt/*

# Reload systemd and mount all filesystems in /etc/fstab
if sudo systemctl daemon-reload && sudo mount -a; then
    echo "All filesystems mounted successfully"
else
    echo "Error mounting filesystems"
fi

exit 0


