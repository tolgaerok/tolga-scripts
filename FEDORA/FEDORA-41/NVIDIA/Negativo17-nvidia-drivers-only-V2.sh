#!/bin/bash
# Tolga Erok
# 18/2/25

# Install NVIDIA drivers from the Negativo17 repository only

set -ouex pipefail

# Set Fedora release version
RELEASE="$(rpm -E %fedora)"
DISTRO="$(cat /etc/os-release | grep -w NAME | cut -d '=' -f2 | tr -d '\"')"
INSTALL="dnf install -y"

# Disable RPM Fusion and Cisco OpenH264 for NVIDIA-related packages
sed -i 's@enabled=1@enabled=0@g' /etc/yum.repos.d/rpmfusion-nonfree-nvidia.repo
sed -i 's@enabled=1@enabled=0@g' /etc/yum.repos.d/rpmfusion-nonfree-updates.repo
sed -i 's@enabled=1@enabled=0@g' /etc/yum.repos.d/fedora-cisco-openh264.repo

# Enable Negativo17 repo for NVIDIA drivers
sed -i 's@enabled=0@enabled=1@' /etc/yum.repos.d/negativo17-fedora-nvidia.repo

# Install NVIDIA drivers from Negativo17 !
${INSTALL} \
    nvidia-driver \            # Core NVIDIA driver for GPU functionality
    nvidia-driver-cuda \       # CUDA toolkit for GPU-accelerated computing
    nvidia-driver-libs.i686 \  # 32-bit NVIDIA driver libraries for legacy apps
    nvidia-settings \          # Graphical configuration tool for NVIDIA settings
    libnvidia-fbc \            # Library for NVIDIA Framebuffer Capture (screen recording, streaming)
    libnvidia-ml.i686 \        # 32-bit NVIDIA Management Library for GPU monitoring
    libva-nvidia-driver \      # VA-API driver for GPU hardware video decoding/encoding
    mesa-vulkan-drivers.i686   # 32-bit Vulkan drivers for GPU-accelerated graphics

# NVIDIA-specific kernel config
sed -i "s/^MODULE_VARIANT=.*/MODULE_VARIANT=nvidia/" /etc/nvidia/kernel.conf

# Enable NVIDIA DRM mode setting for Wayland support
if ! grep -q "nvidia-drm.modeset=1" /etc/default/grub; then
    sed -i 's/GRUB_CMDLINE_LINUX="/GRUB_CMDLINE_LINUX="nvidia-drm.modeset=1 /' /etc/default/grub
    sudo grub2-mkconfig -o /boot/grub2/grub.cfg
fi

# Universal Blue-specific Initramfs fixes
cp /etc/modprobe.d/nvidia-modeset.conf /usr/lib/modprobe.d/nvidia-modeset.conf
sed -i 's@omit_drivers@force_drivers@g' /usr/lib/dracut/dracut.conf.d/99-nvidia.conf
sed -i 's@ nvidia @ i915 amdgpu nvidia @g' /usr/lib/dracut/dracut.conf.d/99-nvidia.conf

# Regenerate initramfs
sudo dracut --force

# Reboot
echo "# ----------------------------------------------------------------------- #"
echo "  NVIDIA drivers installed with Wayland support. A reboot is recommended."
echo "# ----------------------------------------------------------------------- #"
echo "Distro: $DISTRO"
echo "Release: $RELEASE"
