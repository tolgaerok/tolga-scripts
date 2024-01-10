#!/usr/bin/env bash
#!/bin/bash

# Tolga Erok  14/5/2023 Script to mount all /mnt and /media points

# Function to mount a directory
mount_directory() {
  local dir=$1

  # Mount the directory
  if sudo mount $dir 2>/dev/null; then
    echo "Mount of $dir successful"
    return 0
  else
    echo "Mount of $dir failed"
    return 1
  fi
}

# Mount all directories under /mnt
failed_mounts=0
for dir in /mnt/*; do
  if [ -d "$dir" ]; then
    if ! mount_directory $dir; then
      failed_mounts=$((failed_mounts + 1))
    fi
  fi
done

# Mount all directories under /media
for dir in /media/*; do
  if [ -d "$dir" ]; then
    if ! mount_directory $dir; then
      failed_mounts=$((failed_mounts + 1))
    fi
  fi
done

sudo systemctl daemon-reload

# Check if any mounts failed
if [ $failed_mounts -eq 0 ]; then
  echo "Mounting done."
else
  echo "Unable to mount all directories."
fi
# Disable network
sudo systemctl stop NetworkManager.service

# Enable network
sudo systemctl start NetworkManager.service

# Wait for the network to be fully disabled
sleep 2
exit 0
