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

# Define color codes
GREEN="\033[1;32m"
RESET="\033[0m"

# header with a border
print_header() {
  echo -e "\n${GREEN}┌───────────────────────────────────────────────────────────────────────────────────────────────┐ ${RESET}\n$1"
  echo -e "${GREEN}└───────────────────────────────────────────────────────────────────────────────────────────────┘ ${RESET}\n"
}

# Clear pacman cache (Manjaro's package manager) without prompting
print_header "      Clearing pacman cache..."
sudo pacman -Scc --noconfirm

# Clear systemd journal logs to free up disk space
print_header "      Clearing systemd journal logs..."
sudo journalctl --rotate
sudo journalctl --vacuum-time=1s --vacuum-size=1

# Drop Linux filesystem caches to free up memory
print_header "      Dropping filesystem caches..."
sudo sync
echo 3 | sudo tee /proc/sys/vm/drop_caches > /dev/null

# Clear thumbnail cache (if exists)
print_header "      Clearing thumbnail cache..."
sudo rm -rf ~/.thumbnails/*

# Restart NetworkManager 
print_header "      Restarting NetworkManager..."
sudo systemctl restart NetworkManager

# Reload system configuration and udev rules
print_header "      Reloading system configuration and udev rules..."
sudo sysctl --load=/etc/sysctl.d/99-sysctl.conf
sudo sysctl --system
sudo udevadm control --reload-rules
sudo udevadm trigger

# cleanup
echo -e "\n${GREEN}┌───────────────────────────────────────────────────────────────────────────────────────────────┐ ${RESET}\n"
echo "  Temporary slowdowns cleared. System might feel more responsive now."

# Display system resources after cleanup
echo "  System Resources After Cleanup:"
echo "  ---------------------------"
echo "  Memory Usage:"
free -h
echo "  ---------------------------"
echo "  Disk Usage:"
df -h
echo -e "\n${GREEN}└───────────────────────────────────────────────────────────────────────────────────────────────┘ ${RESET}\n"

# Display system information
print_header "      System io scheduler and tcp congestion"
cat /sys/block/sda/queue/scheduler
sysctl net.ipv4.tcp_congestion_control
