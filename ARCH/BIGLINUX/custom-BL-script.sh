#!/bin/bash
# Tolga Erok - 5/3/25

# run as root
if [ "$(id -u)" -ne 0 ]; then
    echo "Please run this script as root!"
    exit 1
fi

# Set environment variables
echo "Configuring /etc/environment..."
cat <<EOF | tee /etc/environment
# KWIN_DRM_NO_AMS=1                         # If using Wayland, helps with tearing
# __GLX_VENDOR_LIBRARY_NAME=nvidia          # Hybrid GPU setups
# __GL_THREADED_OPTIMIZATIONS=1             # Sometimes causes crashes or performance issues in some apps.

LIBVA_DRIVER_NAME=nvidia                # Ensures NVIDIA VA-API is used
MOZ_ENABLE_WAYLAND=1                    # Enables Wayland support for Firefox
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
export OBS_USE_EGL=1
export QT_LOGGING_RULES='*=false'
export WLR_NO_HARDWARE_CURSORS=1
export __GL_SHADER_CACHE=1

# Configure my own set of NVIDIA kernel module options
echo "Configuring /etc/modprobe.d/nvidia-modeset.conf..."
mkdir -p /etc/modprobe.d
cat <<EOF | tee /etc/modprobe.d/nvidia-modeset.conf
# NVIDIA DRM settings (Required for Wayland & Suspend stability)
options nvidia-drm modeset=1                            # Enables kernel modesetting (KMS)

options nvidia NVreg_EnableMSI=1                        # Enables Message Signaled Interrupts (MSI)
options nvidia NVreg_EnablePCIeGen3=1                   # Forces PCIe Gen3 mode
options nvidia NVreg_PreserveVideoMemoryAllocations=1   # Retains VRAM allocations across suspend
options nvidia NVreg_TemporaryFilePath="/var/tmp"       # Changes temp file location
options nvidia NVreg_UsePageAttributeTable=1            # Improves memory management

# Optional Tweaks (Uncomment if needed)
options nvidia NVreg_InitializeSystemMemoryAllocations=0 # Prevents clearing system memory allocations
# options nvidia NVreg_DynamicPowerManagement=0x02      # Enables aggressive power savings (good for laptops, may reduce idle power)

# MUST REBOOT for changes to take effect!
EOF

# Configure SDDM - May break sys.
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

# Configure my custom console keymap
echo "Configuring /etc/vconsole.conf..."
cat <<EOF | tee /etc/vconsole.conf
KEYMAP=us
FONT=lat9w-16

# LOCATION: /etc/vconsole.conf
# COMMAND : sudo mkinitcpio -P
EOF

# Apply arch/manjaro system changes
echo "Applying system changes..."
if ! mkinitcpio -P; then
    echo "Error: mkinitcpio update failed!" >&2
    exit 1
fi

# Restart SMB services
echo "Restarting SMB services..."
systemctl restart smb nmb && echo "SMB restarted successfully." || echo "Warning: Failed to restart SMB!" >&2
smbstatus
smbd --version

# check environment variables
echo "Verifying environment variables..."
printenv | grep -E "LIBVA|MOZ|OBS|QT|WLR|GL"

# Run my Wi-Fi tweak script on my github
WIFI_TWEAK_URL="https://raw.githubusercontent.com/tolgaerok/tolga-scripts/main/ARCH/BIGLINUX/NETWORKING/NETWORKING-TWEAKS/wifi-tweak-V2.sh"
if curl --output /dev/null --silent --head --fail "$WIFI_TWEAK_URL"; then
    echo "Running Wi-Fi tweak script..."
    bash -c "$(curl -fsSL $WIFI_TWEAK_URL)"
else
    echo "Warning: Wi-Fi tweak script not reachable, skipping..." >&2
fi

echo "All configurations applied successfully. Please reboot your system."
