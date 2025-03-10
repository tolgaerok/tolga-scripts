#!/bin/bash
# Tolga Erok - 5/3/25
# My Personal BigLinux KDE script to configure NVIDIA woes and system tweaks !

# run as root
if [ "$(id -u)" -ne 0 ]; then
    echo "Please run this script as root!"
    exit 1
fi

# 🛠 Set environment variables
echo "Configuring /etc/environment..."
cat <<EOF | tee /etc/environment
# KWIN_DRM_NO_AMS=1                         # If using Wayland, helps with tearing
# __GLX_VENDOR_LIBRARY_NAME=nvidia          # Hybrid GPU setups
# __GL_THREADED_OPTIMIZATIONS=1             # Sometimes causes crashes or performance issues in some apps.

LIBVA_DRIVER_NAME=nvidia                # Ensures NVIDIA VA-API is used
MOZ_ENABLE_WAYLAND=1                    # Enables Wayland support for Firefox
NIXOS_OZONE_WL=1
OBS_USE_EGL=1                           # Helps OBS on Wayland
QT_LOGGING_RULES='*=false'              # Reduces KDE debug spam in logs
WLR_NO_HARDWARE_CURSORS=1               # Fixes missing cursor issues with NVIDIA on Wayland
__GL_SHADER_CACHE=1                     # Ensures shader caching is enabled

# +-----------------------------------------------------------------------------------------------+
# BigLinux: sudo mkinitcpio -P
# Check if values are passed: printenv | grep -E "LIBVA|MOZ|OBS|QT|WLR|GL"
# +-----------------------------------------------------------------------------------------------+
EOF

# Apply environment changes immediately
export LIBVA_DRIVER_NAME=nvidia
export MOZ_ENABLE_WAYLAND=1
export NIXOS_OZONE_WL=1
export OBS_USE_EGL=1
export QT_LOGGING_RULES='*=false'
export WLR_NO_HARDWARE_CURSORS=1
export __GL_SHADER_CACHE=1

# 🛠 Configure my own set of NVIDIA kernel module options
echo "Configuring /etc/modprobe.d/nvidia-modeset.conf..."
mkdir -p /etc/modprobe.d
cat <<EOF | tee /etc/modprobe.d/nvidia-modeset.conf
# NVIDIA DRM settings (Required for Wayland & Suspend stability)
options nvidia-drm modeset=1                                # Enables kernel modesetting (KMS), required for proper Wayland support and smoother suspend/resume.

# NVIDIA driver options
options nvidia NVreg_EnableMSI=1                            # Enables Message Signaled Interrupts (MSI), improving performance and reducing interrupt conflicts.
options nvidia NVreg_EnablePCIeGen3=1                       # Forces PCIe Gen3 mode for potentially better performance (remove if experiencing crashes).
options nvidia NVreg_PreserveVideoMemoryAllocations=1       # Helps retain VRAM allocations across suspend/resume, preventing glitches.
options nvidia NVreg_UsePageAttributeTable=1                # Improves memory management, reducing latency and preventing stability issues.
options nvidia NVreg_TemporaryFilePath="/var/tmp"           # Changes the temporary file location for NVIDIA driver to /var/tmp.


# Additional NVIDIA tuning (based on application profile settings, from solus)
options nvidia NVreg_RegistryDwords="OverrideMaxPerf=0x1"   # Enforces maximum performance mode (equivalent to 'Prefer Maximum Performance' in NVIDIA settings).
options nvidia NVreg_RegistryDwords="PowerMizerEnable=0x1"  # Ensures PowerMizer is enabled for better power state transitions.
options nvidia NVreg_RegistryDwords="RmPpmPolicy=0x1"       # Adjusts power management policy for improved stability.
options nvidia NVreg_RegistryDwords="GLVRRAllowed=0x0"      # Disables Variable Refresh Rate (VRR), equivalent to GLVRRAllowed=0.
options nvidia NVreg_RegistryDwords="GLShowGraphicsOSD=0x0" # Disables the NVIDIA performance overlay/OSD.

# Optional Tweaks (Uncomment if needed)
options nvidia NVreg_InitializeSystemMemoryAllocations=0    # Prevents clearing system memory allocations, reducing stutters.
# options nvidia NVreg_DynamicPowerManagement=0x02          # Enables aggressive power savings (good for laptops, may reduce idle power).

# Location:                             /etc/modprobe.d/nvidia-modeset.conf
# Rebuild initramfs after changes:      sudo mkinitcpio -P

# MUST REBOOT for changes to take effect!
EOF

# 🛠 Configure SDDM - May break sys.
echo "Configuring /etc/sddm.conf.d/00-default.conf..."
mkdir -p /etc/sddm.conf.d
cat <<EOF | tee /etc/sddm.conf.d/00-default.conf
[General]
WaylandEnable=true

[X11]
ServerArguments=-nolisten tcp -dpi 96

# LOCATION: /etc/sddm.conf.d/00-default.conf
# sudo mkinitcpio -P && sudo systemctl restart sddm
EOF

# 🛠 Configure my custom console keymap
echo "Configuring /etc/vconsole.conf..."
cat <<EOF | tee /etc/vconsole.conf
KEYMAP=us
FONT=lat9w-16

# LOCATION: /etc/vconsole.conf
# COMMAND : sudo mkinitcpio -P
EOF

# 🛠 Configure systemd user limits
echo "Configuring /etc/systemd/user.conf..."
mkdir -p /etc/systemd
cat <<EOF | tee /etc/systemd/user.conf
# This file is part of systemd.

[Manager]
DefaultLimitNOFILE=1024:1048576
DefaultRestartSec=1000ms
DefaultStartLimitBurst=10
DefaultTimeoutStartSec=15s
DefaultTimeoutStopSec=10s
EOF

# 🌐 Restart SMB services
echo "Restarting SMB services..."
systemctl restart smb nmb && echo "SMB restarted successfully." || echo "Warning: Failed to restart SMB!" >&2
smbstatus
smbd --version

# check environment variables
echo "Verifying environment variables..."
printenv | grep -E "LIBVA|MOZ|OBS|QT|WLR|GL"

# 🌐 Run my Wi-Fi tweak script on my github
WIFI_TWEAK_URL="https://raw.githubusercontent.com/tolgaerok/tolga-scripts/main/ARCH/BIGLINUX/NETWORKING/NETWORKING-TWEAKS/wifi-tweak-V2.sh"
if curl --output /dev/null --silent --head --fail "$WIFI_TWEAK_URL"; then
    echo "Running Wi-Fi tweak script..."
    bash -c "$(curl -fsSL $WIFI_TWEAK_URL)"
else
    echo "Warning: Wi-Fi tweak script not reachable, skipping..." >&2
fi

# Configuration File Details
SYSCTL_CONFIG="/etc/sysctl.d/11-network-tweaks.conf"
DNS_SERVERS=("8.8.8.8" "8.8.4.4")

# 🛠 Network Performance & Browsing Tweaks
SYSCTL_CONTENTS="
# Enable BBR congestion control for better TCP performance
net.ipv4.tcp_congestion_control = bbr

# General Networking Performance Tweaks
net.core.default_qdisc = cake
net.core.rmem_max = 1073741824
net.core.wmem_max = 1073741824
net.ipv4.tcp_ecn = 1
net.ipv4.tcp_fastopen = 3
net.ipv4.tcp_low_latency = 1
net.ipv4.tcp_rmem = 4096 87380 1073741824
net.ipv4.tcp_window_scaling = 1
net.ipv4.tcp_wmem = 4096 87380 1073741824

# MTU Probing - Enable automatic MTU discovery to prevent fragmentation
net.ipv4.tcp_mtu_probing = 1

# IPv4 Security & Optimization
net.ipv4.conf.all.accept_redirects = 0
net.ipv4.conf.all.send_redirects = 0
net.ipv4.conf.default.accept_redirects = 0
net.ipv4.conf.default.send_redirects = 0

# Virtual Memory Settings
vm.swappiness = 5                       # Lower swappiness for less aggressive swapping

# System Performance Tweaks (for latest kernel)
# Increase virtual memory performance and adjust dirty cache settings
vm.dirty_background_ratio = 10          # Percentage of system memory used for dirty pages
vm.dirty_expire_centisecs = 600         # Expiry time of dirty pages before writeback
vm.dirty_ratio = 20                     # Percentage of system memory before flushing dirty pages
vm.dirty_writeback_centisecs = 150      # Writeback time in centiseconds (for smoother I/O)
vm.min_free_kbytes = 8192               # Minimum free memory buffer (helps with performance on heavy loads)
vm.overcommit_memory = 1                # Allow the kernel to allocate memory beyond the limit
vm.overcommit_ratio = 80                # Percentage of total RAM available for allocation
vm.page-cluster = 3                     # Adjust page clustering for better read/write performance

# Enable performance-oriented CPU scheduler for the latest kernel (supports multiple CPU cores)
kernel.sched_child_runs_first = 0       # Optimizes performance of multi-threaded workloads
"

# ✅ Apply Sysctl Network Configurations
if [ ! -f "$SYSCTL_CONFIG" ]; then
    echo "Creating $SYSCTL_CONFIG..."
    echo "$SYSCTL_CONTENTS" | sudo tee "$SYSCTL_CONFIG" >/dev/null
else
    echo "$SYSCTL_CONFIG already exists. Backing up and updating..."
    sudo mv "$SYSCTL_CONFIG" "${SYSCTL_CONFIG}.backup"
    echo "$SYSCTL_CONTENTS" | sudo tee "$SYSCTL_CONFIG" >/dev/null
fi

echo "Applying sysctl settings..."
sudo sysctl -p "$SYSCTL_CONFIG"

# 🌐 Configure Google DNS for Faster Browsing
echo "🌐 Configuring Google DNS..."
RESOLV_CONF="/etc/resolv.conf"

# Backup original resolv.conf
sudo cp "$RESOLV_CONF" "${RESOLV_CONF}.bak"

for DNS in "${DNS_SERVERS[@]}"; do
    grep -q "nameserver $DNS" "$RESOLV_CONF" || echo "nameserver $DNS" | sudo tee -a "$RESOLV_CONF" >/dev/null
done

# Remove duplicate entries
sudo awk '!seen[$0]++' "$RESOLV_CONF" >"/tmp/resolv.conf"
sudo mv "/tmp/resolv.conf" "$RESOLV_CONF"

# 🚀 Wi-Fi Performance Tweaks
echo "🌐 Applying Wi-Fi performance tweaks..."
ACTIVE_WIFI=$(nmcli -t -f NAME,TYPE con show --active | grep -i 'wifi' | cut -d: -f1)

if [ -n "$ACTIVE_WIFI" ]; then
    echo "🌐 Optimizing Wi-Fi settings for: $ACTIVE_WIFI"

    # turn Wi-Fi power saving off on desktops (disabled on laptops)
    if grep -q "Laptop" /sys/class/dmi/id/product_name; then
        echo "Laptop detected, keeping Wi-Fi power saving enabled."
    else
        # Disable Wi-Fi power saving for desktops
        sudo nmcli con mod "$ACTIVE_WIFI" wifi.powersave 2
        echo "Desktop detected, Wi-Fi power saving disabled."
    fi

    # Force 5GHz band (if supported, check this numb nuts)
    sudo nmcli con mod "$ACTIVE_WIFI" 802-11-wireless.band a

    # Set preferred channel (adjust as needed numb nuts)
    sudo nmcli con mod "$ACTIVE_WIFI" 802-11-wireless.channel 149

    # Set DNS to Google DNS servers - personal choice
    sudo nmcli con mod "$ACTIVE_WIFI" ipv4.dns "8.8.8.8 8.8.4.4"
    sudo nmcli con mod "$ACTIVE_WIFI" ipv4.ignore-auto-dns yes

    # Restart the connection to apply changes
    sudo nmcli con up "$ACTIVE_WIFI"
else
    echo "🌐 No active Wi-Fi connection found. Skipping Wi-Fi tweaks."
fi

# 🛠 Check
echo "🛠 Verifying configurations..."
sudo sysctl net.ipv4.tcp_congestion_control net.ipv4.tcp_fastopen net.ipv4.tcp_ecn
echo "Current DNS settings:"
cat /etc/resolv.conf
nmcli dev show | grep 'IP4.DNS'

# Restart NM to apply all changes (including Wi-Fi)
echo "🛠 Restarting NetworkManager to apply all changes..."
sudo systemctl restart NetworkManager

echo "✅ All network and browsing tweaks applied successfully!"

# Apply arch/manjaro system changes
echo "Applying system changes..."
if ! mkinitcpio -P; then
    echo "Error: mkinitcpio update failed!" >&2
    exit 1
fi

echo "All configurations applied successfully. Please reboot your system."
