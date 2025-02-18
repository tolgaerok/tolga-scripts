#!/bin/bash
# Tolga Erok
# 18/2/25

set -ouex pipefail

# Set Fedora release version
RELEASE="$(rpm -E %fedora)"
INSTALL="dnf install -y"

# Disable RPM Fusion and Cisco OpenH264 for NVIDIA-related packages
sed -i 's@enabled=1@enabled=0@g' /etc/yum.repos.d/rpmfusion-nonfree-nvidia.repo
sed -i 's@enabled=1@enabled=0@g' /etc/yum.repos.d/rpmfusion-nonfree-updates.repo
sed -i 's@enabled=1@enabled=0@g' /etc/yum.repos.d/fedora-cisco-openh264.repo

# Enable Negativo17 repo for NVIDIA drivers
sed -i 's@enabled=0@enabled=1@' /etc/yum.repos.d/negativo17-fedora-nvidia.repo

# Install NVIDIA drivers from Negativo17 !
${INSTALL} \
    nvidia-driver \
    nvidia-driver-cuda \
    nvidia-driver-libs.i686 \
    nvidia-settings \
    libnvidia-fbc \
    libnvidia-ml.i686 \
    libva-nvidia-driver \
    mesa-vulkan-drivers.i686

# Apply NVIDIA-specific kernel configuration
sed -i "s/^MODULE_VARIANT=.*/MODULE_VARIANT=nvidia/" /etc/nvidia/kernel.conf

# Enable NVIDIA DRM mode setting for Wayland support
if ! grep -q "nvidia-drm.modeset=1" /etc/default/grub; then
    sed -i 's/GRUB_CMDLINE_LINUX="/GRUB_CMDLINE_LINUX="nvidia-drm.modeset=1 /' /etc/default/grub
    grub2-mkconfig -o /boot/grub2/grub.cfg
fi

# Universal Blue-specific Initramfs fixes (adjusted for standard Fedora)
cp /etc/modprobe.d/nvidia-modeset.conf /usr/lib/modprobe.d/nvidia-modeset.conf
sed -i 's@omit_drivers@force_drivers@g' /usr/lib/dracut/dracut.conf.d/99-nvidia.conf
sed -i 's@ nvidia @ i915 amdgpu nvidia @g' /usr/lib/dracut/dracut.conf.d/99-nvidia.conf

# Regenerate initramfs
dracut --force

# Reboot recommendation
echo "NVIDIA drivers installed with Wayland support. A reboot is recommended."
