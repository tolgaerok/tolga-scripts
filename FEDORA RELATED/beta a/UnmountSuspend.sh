#!/bin/bash

# Try manual way first
sudo umount -f /mnt/*
sudo umount -l /mnt/*
sudo systemctl daemon-reload

# Unmount all mounted filesystems under /mnt
for mount_point in $(mount | grep '/mnt/' | cut -d' ' -f3 | sort -r); do
  sudo umount -l $mount_point
  sudo umount -f $mount_point
  while mountpoint -q $mount_point; do
    sleep 1
  done
  if [ $(mountpoint -q $mount_point) -eq 0 ]; then
    echo "Unmount of $mount_point failed"
  fi
done

# Check if any unmounts failed
if mount | grep '/mnt/' > /dev/null; then
  echo "Unable to unmount all filesystems under /mnt"
else
  # Suspend the system
  sudo systemctl suspend
  exit
fi

# Exit the terminal window
exit 0
