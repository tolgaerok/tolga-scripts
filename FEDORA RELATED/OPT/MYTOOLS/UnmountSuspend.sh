#!/bin/bash

# Try manual way first
#sudo umount -f /mnt/*
#sudo umount -l /mnt/*
#sudo systemctl daemon-reload

# Function to unmount a directory
unmount_directory() {
  local dir=$1

  # Unmount the directory
  sudo umount -lf $dir

  # Wait until the directory is unmounted
  while mountpoint -q $dir; do
    sleep 1
  done

  # Check if unmounting was successful
  if mountpoint -q $dir; then
    echo "Unmount of $dir failed"
    return 1
  fi

  return 0
}

# Unmount all mounted filesystems under /mnt
for mount_point in $(mount | awk '$3 ~ /^\/mnt/ {print $3}'); do
  unmount_directory $mount_point
done

# Unmount all mounted filesystems under /media
for mount_point in $(mount | awk '$3 ~ /^\/media/ {print $3}'); do
  unmount_directory $mount_point
done

# Check if any unmounts failed
if mount | grep -E '^/mnt/|^/media/' > /dev/null; then
  echo "Unable to unmount all filesystems under /mnt and /media"
else
  echo "Unmount done."

  # Disable network
  sudo systemctl stop NetworkManager.service
  sudo systemctl suspend
fi

exit 0



