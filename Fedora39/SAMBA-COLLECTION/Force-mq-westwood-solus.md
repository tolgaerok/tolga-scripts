#!/bin/bash
# Tolga Erok
# 7/1/2024
# Solus tweaks

# Create sysctl configuration file
echo 'net.ipv4.tcp_congestion_control = westwood' | sudo tee /etc/sysctl.d/99-custom.conf

# Create udev rule for I/O scheduler
echo 'ACTION=="add|change", KERNEL=="sda", ATTR{queue/scheduler}="deadline"' | sudo tee /etc/udev/rules.d/60-scheduler.rules

# Enable zswap in clr-boot-manager configuration
echo 'zswap.enabled=1' | sudo tee -a /etc/kernel/cmdline

# Apply sysctl changes
sudo udevadm control --reload-rules
sudo udevadm trigger
sudo sysctl --system

# Update clr-boot-manager
sudo clr-boot-manager update

echo "Configuration files created and changes applied. You may need to reboot for the changes to take effect."

# Notes: from fedora && nixos
# sudo bash -c 'echo "westwood" > /proc/sys/net/ipv4/tcp_congestion_control'
# sudo echo mq-deadline | sudo tee /sys/block/sda/queue/scheduler
