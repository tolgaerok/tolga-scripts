#!/bin/bash

# Tolga Erok
# My personal Fedora 39 KDE Nvidia installer
# 5/1/2024

# Run from remote location:
# sudo bash -c "$(curl -fsSL https://raw.githubusercontent.com/tolgaerok/tolga-scripts/main/Fedora39/NVIDIA-FEDORA/nvidia.sh)"

#  ¯\_(ツ)_/¯
#    █████▒▓█████ ▓█████▄  ▒█████   ██▀███   ▄▄▄
#  ▓██   ▒ ▓█   ▀ ▒██▀ ██▌▒██▒  ██▒▓██ ▒ ██▒▒████▄
#  ▒████ ░ ▒███   ░██   █▌▒██░  ██▒▓██ ░▄█ ▒▒██  ▀█▄
#  ░▓█▒  ░ ▒▓█  ▄ ░▓█▄   ▌▒██   ██░▒██▀▀█▄  ░██▄▄▄▄██
#  ░▒█░    ░▒████▒░▒████▓ ░ ████▓▒░░██▓ ▒██▒ ▓█   ▓██▒
#   ▒ ░    ░░ ▒░ ░ ▒▒▓  ▒ ░ ▒░▒░▒░ ░ ▒▓ ░▒▓░ ▒▒   ▓▒█░
#   ░       ░ ░  ░ ░ ▒  ▒   ░ ▒ ▒░   ░▒ ░ ▒░  ▒   ▒▒ ░
#   ░ ░       ░    ░ ░  ░ ░ ░ ░ ▒    ░░   ░   ░   ▒
#   ░  ░      ░    ░ ░     ░              ░  ░   ░

# https://github.com/massgravel/Microsoft-Activation-Scripts

clear

# Check if the script is run as root
if [ "$EUID" -ne 0 ]; then
    echo "Please run this script as root or using sudo."
    exit 1
fi

# Assign a color variable based on the RANDOM number
RED='\e[1;31m'
GREEN='\e[1;32m'
YELLOW='\e[1;33m'
BLUE='\e[1;34m'
CYAN='\e[1;36m'
WHITE='\e[1;37m'
ORANGE='\e[1;93m'
NC='\e[0m'

# Function to display messages
display_message() {
    clear
    echo -e "\n                  Tolga's online fedora updater\n"
    echo -e "\e[34m|--------------------\e[33m Currently configuring:\e[34m-------------------|"
    echo -e "|${YELLOW}==>${NC}  $1"
    echo -e "\e[34m|--------------------------------------------------------------|\e[0m"
    echo ""
    sleep 1
}

# Function to check and display errors
check_error() {
    if [ $? -ne 0 ]; then
        display_message "[${RED}✘${NC}] Error occurred !!"
        # Print the error details
        echo "Error details: $1"
        sleep 3
    fi
}

# Update Time (Enable Network Time)
sudo timedatectl set-ntp true

# Update User Dirs
[ -f /usr/bin/xdg-user-dirs-update ] && xdg-user-dirs-update

# Set to performance
[ -f /usr/bin/powerprofilesctl ] && powerprofilesctl list | grep -q performance && powerprofilesctl set performance

clear

# Configure I/O Scheduler
echo -e "\n${BLUE}Configuring I/O Scheduler to: ${NC}\n"
echo "mq-deadline" | sudo tee /sys/block/sda/queue/scheduler
printf "\n${YELLOW}I/O Scheduler has been set to ==>  ${NC}"
cat /sys/block/sda/queue/scheduler
echo ""

# Install NVIDIA drivers and related packages
install_nvidia_drivers() {
    display_message "[${GREEN}✔${NC}]  Installing NVIDIA drivers..."

    # Clean up and update system
    sudo dnf clean all
    sudo dnf update --refresh -y --allowerasing

    # Enable RPM Fusion repositories
    sudo dnf install -y https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm 
    sudo dnf install -y https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
    sudo dnf config-manager --set-enabled rpmfusion-free rpmfusion-free-updates rpmfusion-nonfree rpmfusion-nonfree-updates

    # Install NVIDIA drivers and tools
    sudo dnf install -y akmod-nvidia nvidia-modprobe nvidia-persistenced nvidia-settings nvidia-gpu-firmware --allowerasing

    # Reset and enable NVIDIA module if needed
    sudo dnf module reset nvidia-driver
    sudo dnf module enable nvidia-driver

    # Install specific packages with --allowerasing
    sudo dnf install -y nvidia-libXNVCtrl nvidia-xconfig --allowerasing

    # Additional packages with --allowerasing
    sudo dnf install -y kernel-devel xorg-x11-drv-nvidia-cuda xorg-x11-drv-nvidia-cuda-libs gcc kernel-headers xorg-x11-drv-nvidia xorg-x11-drv-nvidia-libs
    sudo dnf install -y gcc kernel-headers kernel-devel xorg-x11-drv-nvidia xorg-x11-drv-nvidia-libs xorg-x11-drv-nvidia-libs.i686
    sudo dnf install -y vdpauinfo libva-vdpau-driver libva-utils vulkan akmods nvidia-vaapi-driver libva-utils vdpauinfo
    sudo dnf install -y kernel-devel kernel-headers gcc make dkms acpid libglvnd-glx libglvnd-opengl libglvnd-devel pkgconfig
    sudo dnf install -y mesa-vdpau-drivers nvidia-vaapi-driver vdpauinfo libva-utils

    # Install CUDA and related packages with --allowerasing
    sudo dnf install -y cuda libva-utils vdpauinfo libva-vdpau-driver nvidia-vaapi-driver kernel-headers kernel-devel

    # Install additional drivers and utilities with --allowerasing
    sudo dnf install -y libva-vdpau-driver libva-utils mesa-vdpau-drivers intel-media-driver.x86_64

    # Install necessary tools with --allowerasing
    sudo dnf -y install akmods
    sudo dnf install -y kernel-headers kernel-devel gcc make dkms acpid libglvnd-glx libglvnd-opengl libglvnd-devel pkgconfig
    sudo dnf install -y kernel-devel-$(uname -r)
    sudo dnf install -y mesa-vdpau-drivers nvidia-vaapi-driver libva-utils vdpauinfo

    # Update kernel
    sudo dnf update -y kernel
    sudo dnf install -y kernel-headers kernel-devel

    # Enable NVIDIA services
    sudo systemctl enable nvidia-suspend nvidia-resume nvidia-hibernate

    # Update kernel arguments for NVIDIA
    sudo grubby --update-kernel=ALL --args='nvidia-drm.modeset=1'
      sudo dnf install xrandr
        sudo cp -p /usr/share/X11/xorg.conf.d/nvidia.conf /etc/X11/xorg.conf.d/nvidia.conf
sudo dnf config-manager --set-enabled rpmfusion-nonfree-nvidia-driver
     # Blacklist some modules
        echo "blacklist nouveau" >>/etc/modprobe.d/blacklist.conf
        echo "blacklist iTCO_wdt" >>/etc/modprobe.d/blacklist.conf

        # KMS stands for "Kernel Mode Setting" which is the opposite of "Userland Mode Setting". This feature allows to set the screen resolution
        # on the kernel side once (at boot), instead of after login from the display manager.
        sudo sed -i '/GRUB_CMDLINE_LINUX/ s/"$/ rd.driver.blacklist=nouveau modprobe.blacklist=nouveau nvidia-drm.modeset=1"/' /etc/default/grub

        # remove nouveau
        sudo dnf remove -y xorg-x11-drv-nouveau

        # Backup old initramfs nouveau image #
        sudo mv /boot/initramfs-$(uname -r).img /boot/initramfs-$(uname -r)-nouveau.img

        # Create new initramfs image #
        sudo dracut /boot/initramfs-$(uname -r).img $(uname -r)

         sudo systemctl enable nvidia-{suspend,resume,hibernate}

 
        sudo akmods --force

        # Make sure the boot image got updated as well
        sudo dracut --force

 

    # Nvidia suspend issue workaround
    echo "options nvidia NVreg_TemporaryFilePath=/tmp" | sudo tee /etc/modprobe.d/nvidia.conf > /dev/null

    display_message "[${GREEN}✔${NC}]  NVIDIA drivers installed successfully."
    sleep 1
}

# Call the function to install NVIDIA drivers
install_nvidia_drivers

# Final message
display_message "[${GREEN}✔${NC}]  Installation complete!"
echo -e "${GREEN}Installation complete! You may need to reboot your system.${NC}"
