#!/bin/bash
# Tolga Erok
# network tweaks v2
# 22/12/2024

# Configuration File Details
# --------------------------------------

SYSCTL_CONF="/etc/sysctl.d/99-sysctl.conf"

declare -A sysctl_settings=(
    # Networking Tweaks
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

    # BBR and Congestion Control
    ["net.core.default_qdisc"]="cake"
    ["net.core.rmem_max"]="1073741824"
    ["net.core.wmem_max"]="1073741824"
    ["net.ipv4.tcp_congestion_control"]="bbr"
    ["net.ipv4.tcp_ecn"]="1"
    ["net.ipv4.tcp_fastopen"]="3"
    ["net.ipv4.tcp_low_latency"]="1"
    ["net.ipv4.tcp_rmem"]="4096 87380 1073741824"
    ["net.ipv4.tcp_window_scaling"]="1"
    ["net.ipv4.tcp_wmem"]="4096 87380 1073741824"

    # IPv4 Configuration
    ["net.ipv4.conf.all.accept_redirects"]="0"
    ["net.ipv4.conf.all.send_redirects"]="0"
    ["net.ipv4.conf.default.accept_redirects"]="0"
    ["net.ipv4.conf.default.send_redirects"]="0"
    ["net.ipv4.ip_forward"]="1"

    # Virtual Memory Management
    ["vm.dirty_background_bytes"]="474217728"
    ["vm.dirty_bytes"]="742653184"
    ["vm.dirty_expire_centisecs"]="500"
    ["vm.dirty_writeback_centisecs"]="300"
    ["vm.swappiness"]="1"

    # File System Tweaks
    ["fs.inotify.max_queued_events"]="1048576"
    ["fs.inotify.max_user_instances"]="1048576"
    ["fs.inotify.max_user_watches"]="1048576"

    # Security and Miscellaneous
    ["kernel.core_uses_pid"]="1"
    ["kernel.kptr_restrict"]="1"
    ["kernel.randomize_va_space"]="2"
    ["kernel.sysrq"]="0"
    ["kernel.unprivileged_bpf_disabled"]="1"
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
