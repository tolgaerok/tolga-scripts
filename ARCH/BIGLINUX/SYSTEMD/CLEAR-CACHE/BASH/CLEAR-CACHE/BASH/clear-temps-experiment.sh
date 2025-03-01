#!/usr/bin/env bash

# Metadata
# ----------------------------------------------------------------------------
AUTHOR="Tolga Erok"
VERSION="1"
DATE_CREATED="21/12/2024"
DISTRO="Manjaro (Arch Linux)"
UPDATE_REASON="Implemented more aggressive systemd journal management and automated user input"

# Configuration
# ----------------------------------------------------------------------------

# Clear pacman cache (Manjaro's package manager) without prompting.
sudo pacman -Scc --noconfirm

# Clear systemd journal to free up disk space without prompting
sudo journalctl --rotate
sudo journalctl --vacuum-time=1s --vacuum-size=1
sleep 1

# Drop Linux file system caches
sudo sync
sudo tee /proc/sys/vm/drop_caches <<<3

# Optionally, clear thumbnail cache (can get large) without prompting
sudo rm -rf ~/.thumbnails/*

# Restart some services to free up resources
sudo systemctl restart NetworkManager

echo "Temporary slowdowns cleared. System might feel more responsive now."

# Additional Information (optional)
echo "System Resources After Cleanup:"
echo "---------------------------"
echo "Memory Usage:"
free -h
echo "---------------------------"
echo "Disk Usage:"
df -h
