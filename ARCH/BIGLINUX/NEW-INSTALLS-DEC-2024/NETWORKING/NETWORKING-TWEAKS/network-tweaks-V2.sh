#!/bin/bash
# Tolga Erok
# network tweaks v2
# 22/12/2024

# Configuration File Details
# --------------------------------------

SYSCTL_CONF="/etc/sysctl.d/99-sysctl.conf"

declare -A sysctl_settings=(
    ["net.core.netdev_max_backlog"]="16384"
    ["net.core.optmem_max"]="25165824"
    ["net.core.rmem_default"]="8388608"
    ["net.core.rmem_max"]="25165824"
    ["net.core.somaxconn"]="8192"
    ["net.core.wmem_default"]="8388608"
    ["net.core.wmem_max"]="25165824"
    ["net.ipv4.tcp_fastopen"]="3"
    ["net.ipv4.tcp_keepalive_intvl"]="10"
    ["net.ipv4.tcp_keepalive_probes"]="6"
    ["net.ipv4.tcp_keepalive_time"]="60"
    ["net.ipv4.tcp_mtu_probing"]="1"
    ["net.ipv4.tcp_rmem"]="4096 25165824 25165824"
    ["net.ipv4.tcp_wmem"]="4096 65536 25165824"
    ["net.ipv4.udp_rmem_min"]="8192"
    ["net.ipv4.udp_wmem_min"]="8192"
    ["vm.dirty_background_ratio"]="5"
    ["vm.dirty_ratio"]="10"
    ["vm.overcommit_memory"]="2"
    ["vm.overcommit_ratio"]="50"
    ["vm.vfs_cache_pressure"]="50"
)

# Create the sysctl file
sudo touch "$SYSCTL_CONF"

# Check and append settings
for key in "${!sysctl_settings[@]}"; do
    value="${sysctl_settings[$key]}"
    if sudo grep -qE "^$key" "$SYSCTL_CONF"; then
        echo "Skipping $key, already set."
    else
        echo "$key = $value" | sudo tee -a "$SYSCTL_CONF" >/dev/null
        echo "Set $key to $value."
    fi
done

# Reload sysctl to apply the changes
sudo sysctl --load=/etc/sysctl.d/99-sysctl.conf
sudo sysctl --system
