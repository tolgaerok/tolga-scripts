#!/bin/bash
# Tolga Erok
# vm tweaks
# 19/12/2024

# Configuration File Details
CONFIG_FILE="/etc/sysctl.d/11-optimizations.conf"
CONFIG_CONTENTS="
# Enable BBR congestion control
net.ipv4.tcp_congestion_control = bbr

# General Networking Tweaks
net.core.default_qdisc = cake
net.core.wmem_max = 1073741824
net.core.rmem_max = 1073741824
net.ipv4.tcp_rmem = 4096 87380 1073741824
net.ipv4.tcp_wmem = 4096 87380 1073741824
net.ipv4.tcp_low_latency = 1
net.ipv4.tcp_window_scaling = 1
net.ipv4.tcp_ecn = 1
net.ipv4.tcp_fastopen = 3

# IPv4 Configuration
net.ipv4.conf.all.accept_redirects = 0
net.ipv4.conf.all.send_redirects = 0
net.ipv4.conf.default.accept_redirects = 0
net.ipv4.conf.default.send_redirects = 0
net.ipv4.ip_forward = 1

# Virtual Memory Management
vm.swappiness = 1
vm.dirty_background_bytes = 474217728
vm.dirty_bytes = 742653184
vm.dirty_expire_centisecs = 500
vm.dirty_writeback_centisecs = 300

# File System
fs.inotify.max_user_watches = 1048576
fs.inotify.max_user_instances = 1048576
fs.inotify.max_queued_events = 1048576

# Security and Miscellaneous
kernel.unprivileged_bpf_disabled = 1
kernel.core_uses_pid = 1
kernel.sysrq = 0
kernel.kptr_restrict = 1
kernel.randomize_va_space = 2
"

# Create Configuration File if it doesn't existt
if [ ! -f "$CONFIG_FILE" ]; then
    echo "Creating $CONFIG_FILE..."
    echo "$CONFIG_CONTENTS" | sudo tee "$CONFIG_FILE" >/dev/null
    echo "File created and populated successfully."
else
    echo "$CONFIG_FILE already exists. Backing up the original and overwriting with new configurations..."
    sudo mv "$CONFIG_FILE" "${CONFIG_FILE}.backup"
    echo "$CONFIG_CONTENTS" | sudo tee "$CONFIG_FILE" >/dev/null
    echo "Configurations updated."
fi

# Apply Sysctl Configurations
echo "Applying sysctl configurations..."
sudo sysctl -p "$CONFIG_FILE"
echo "Configurations applied. Verifying..."
echo ""

# Verify Selected Configurations
echo ""
echo "Verification:"
sudo sysctl net.ipv4.tcp_congestion_control vm.swappiness kernel.unprivileged_bpf_disabled
