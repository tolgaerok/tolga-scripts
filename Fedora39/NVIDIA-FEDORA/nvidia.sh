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
YELLOW='\e[1;33m'
NC='\e[0m'

# Update Time (Enable Network Time)
sudo timedatectl set-ntp true

# Update User Dirs
[ -f /usr/bin/xdg-user-dirs-update ] && xdg-user-dirs-update

# Set to performance
[ -f /usr/bin/powerprofilesctl ] && powerprofilesctl list | grep -q performance && powerprofilesctl set performance

clear

# none [mq-deadline] kyber bfq
# Super tweak I/O scheduler
echo -e "\n${BLUE}Configuring I/O Scheduler to: ${NC}\n"
echo "mq-deadline" | sudo tee /sys/block/sda/queue/scheduler
printf "\n${YELLOW}I/O Scheduler has been set to ==>  ${NC}"
cat /sys/block/sda/queue/scheduler
echo ""

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

install_gpu_drivers() {
    display_message "[${GREEN}✔${NC}]  Checking GPU and installing drivers..."
    sudo dnf install -y mesa-vdpau-drivers zenity

    # Check for NVIDIA GPU
    if lspci | grep -i nvidia &>/dev/null; then
        display_message "[${GREEN}✔${NC}]  NVIDIA GPU detected. Installing NVIDIA drivers..."

        sudo dnf update
        sudo dnf upgrade --refresh
        sudo dnf install dnf-plugins-core -y
        sudo dnf install fedora-workstation-repositories
        sudo dnf config-manager --set-enabled rpmfusion-nonfree-nvidia-driver

        # Install the tools required for auto signing to work
        # sudo dnf -y install kmodtool akmods mokutil openssl
        sudo dnf -y install akmods openssl

        # Generate a signing key
        # sudo kmodgenca -a

        # nitiate the key enrollment
        # sudo mokutil --import /etc/pki/akmods/certs/public_key.der

        sudo dnf copr enable t0xic0der/nvidia-auto-installer-for-fedora -y
        sudo dnf install nvautoinstall -y

        # Install some dependencies
        sudo dnf install kernel-devel kernel-headers gcc make dkms acpid libglvnd-glx libglvnd-opengl libglvnd-devel pkgconfig

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

        # Install NVidia driver
        sudo dnf install -y akmod-nvidia
        sudo systemctl disable --now fwupd-refresh.timer
        sudo dnf repolist | grep 'rpmfusion-nonfree-updates'
        sudo dnf install -y https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm
        sudo dnf install -y https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
        sudo dnf config-manager --set-enabled rpmfusion-free rpmfusion-free-updates rpmfusion-nonfree rpmfusion-nonfree-updates

        #  sudo bash -c "dnf remove -y nvidia*; dnf remove -y akmod-nvidia; dnf remove -y dkms-nvidia; rm -rf /var/lib/dkms/nvidia*; dnf install -y akmod-nvidia nvidia-driver nvidia-driver-NVML nvidia-driver-NVML.i686 nvidia-driver-NvFBCOpenGL nvidia-driver-cuda nvidia-driver-cuda-libs nvidia-driver-cuda-libs.i686 nvidia-driver-libs nvidia-driver-libs.i686 nvidia-kmod-common nvidia-libXNVCtrl nvidia-modprobe nvidia-persistenced nvidia-settings nvidia-xconfig nvidia-vaapi-driver nvidia-gpu-firmware --refresh; systemctl enable --now akmods; dracut -f"

        sudo dnf install -y kernel-devel akmod-nvidia xorg-x11-drv-nvidia-cuda xorg-x11-drv-nvidia-cuda-libs gcc kernel-headers xorg-x11-drv-nvidia xorg-x11-drv-nvidia-libs
        sudo dnf install -y gcc kernel-headers kernel-devel akmod-nvidia xorg-x11-drv-nvidia xorg-x11-drv-nvidia-libs xorg-x11-drv-nvidia-libs.i686
        sudo dnf install -y vdpauinfo libva-vdpau-driver libva-utils vulkan akmods nvidia-vaapi-driver libva-utils vdpauinfo
        sudo dnf install -y nvidia-settings nvidia-persistenced xorg-x11-drv-nvidia-power

        sudo systemctl enable nvidia-{suspend,resume,hibernate}

        # sudo dnf install -y kernel-devel akmod-nvidia xorg-x11-drv-nvidia-cuda xorg-x11-drv-nvidia-cuda-libs gcc kernel-headers xorg-x11-drv-nvidia xorg-x11-drv-nvidia-libs.x86_64
        # sudo dnf install -y vdpauinfo libva-vdpau-driver libva-utils vulkan akmods
        # sudo dnf install -y nvidia-settings nvidia-persistenced

        # Make sure the kernel modules got compiled
        sudo akmods --force

        # Make sure the boot image got updated as well
        sudo dracut --force

        sudo dnf install xrandr
        sudo cp -p /usr/share/X11/xorg.conf.d/nvidia.conf /etc/X11/xorg.conf.d/nvidia.conf

        sudo sudo nvautoinstall rpmadd
        sudo nvautoinstall driver
        sudo nvautoinstall nvrepo
        sudo nvautoinstall plcuda
        sudo nvautoinstall ffmpeg
        sudo nvautoinstall vulkan
        sudo nvautoinstall vidacc
        sudo nvautoinstall compat
        sleep 1

        # Latest/Beta driver
        # Install the latest drivers from Rawhide
        # Make sure to replace 'uname -r' with the actual kernel version if needed
        # sudo dnf install "kernel-devel-uname-r >= $(uname -r)"
        # sudo dnf update -y
        # sudo dnf copr enable kwizart/nvidia-driver-rawhide -y
        # sudo dnf install rpmfusion-nonfree-release-rawhide -y
        # sudo dnf --enablerepo=rpmfusion-nonfree-rawhide install akmod-nvidia xorg-x11-drv-nvidia xorg-x11-drv-nvidia-cuda --nogpgcheck

        # Or if you want to grab it from the latest Fedora stable release
        # Make sure to replace 'uname -r' with the actual kernel version if needed
        # sudo dnf install "kernel-devel-uname-r == $(uname -r)"
        # sudo dnf update -y
        # sudo dnf --releasever=30 install akmod-nvidia xorg-x11-drv-nvidia --nogpgcheck

        # Uninstall the NVIDIA driver
        # dnf remove xorg-x11-drv-nvidia\*

        # Recover from NVIDIA installer
        # The NVIDIA binary driver installer overwrites some configuration and libraries.
        # If you want to recover to a clean state, either to use nouveau or the packaged driver, use:
        # rm -f /usr/lib{,64}/libGL.so.* /usr/lib{,64}/libEGL.so.*
        # rm -f /usr/lib{,64}/xorg/modules/extensions/libglx.so
        # dnf reinstall xorg-x11-server-Xorg mesa-libGL mesa-libEGL libglvnd\*
        # mv /etc/X11/xorg.conf /etc/X11/xorg.conf.saved

        # Version Lock
        # Sometime, there is a need to lock to a particular driver version for any reason (regression, compatibility with another application, vulkan beta branch or else).
        # Using dnf versionlock module is the appropriate way to deal with that.
        # Please remember that version lock will prevent any updates to the NVIDIA driver including fixes for kernel compatibilities if relevant.

        # dnf install python3-dnf-plugin-versionlock
        # rpm -qa xorg-x11-drv-nvidia* *kmod-nvidia* nvidia-{settings,xconfig,modprobe,persistenced}  >> /etc/dnf/plugins/versionlock.list

        ###### DOWNGRADE NVIDIA FROM 545x to 535x
        # sudo dnf remove \*nvidia\* --exclude nvidia-gpu-firmware
        # sudo dnf install akmod-nvidia-535.129.03\* xorg-x11-drv-nvidia-cuda-535.129.03\* nvidia\*535.129.03\*
        # sudo dnf install dnf-plugin-versionlock
        #sudo dnf versionlock add akmod-nvidia-3:535.129.03-1.fc39
        #sudo dnf versionlock add nvidia-modprobe-3:535.129.03-1.fc39
        #sudo dnf versionlock add nvidia-persistenced-3:535.129.03-1.fc39
        #sudo dnf versionlock add nvidia-settings-3:535.129.03-1.fc39
        #sudo dnf versionlock add nvidia-xconfig-3:535.129.03-1.fc39
        #sudo dnf versionlock add xorg-x11-drv-nvidia-3:535.129.03-1.fc39
        #sudo dnf versionlock add xorg-x11-drv-nvidia-cuda-3:535.129.03-1.fc39
        #sudo dnf versionlock add xorg-x11-drv-nvidia-cuda-libs-3:535.129.03-1.fc39
        #sudo dnf versionlock add xorg-x11-drv-nvidia-kmodsrc-3:535.129.03-1.fc39
        #sudo dnf versionlock add xorg-x11-drv-nvidia-libs-3:535.129.03-1.fc39
        #sudo dnf versionlock add xorg-x11-drv-nvidia-power-3:535.129.03-1.fc39
        #sudo rm /etc/yum.repos.d/nvidia-exclude.repo
        #sudo dnf versionlock list
        #sudo dnf update
        #cl
        #sudo dnf update
        #sudo dnf versionlock list
        ########################## DELETE LOCKS ###############################
        #sudo dnf versionlock delete akmod-nvidia-3:535.129.03-1.fc39
        #sudo dnf versionlock delete nvidia-modprobe-3:535.129.03-1.fc39
        #sudo dnf versionlock delete nvidia-persistenced-3:535.129.03-1.fc39
        #sudo dnf versionlock delete nvidia-settings-3:535.129.03-1.fc39
        #sudo dnf versionlock delete nvidia-xconfig-3:535.129.03-1.fc39

        ########################## Alternative block ##########################
        # sudo dnf update --exclude="akmod-nvidia*3:545.29.06-1.fc39*" \
        #          --exclude="nvidia-modprobe*3:545.29.06-1.fc39*" \
        #          --exclude="nvidia-persistenced*3:545.29.06-1.fc39*" \
        #          --exclude="nvidia-settings*3:545.29.06-1.fc39*" \
        #          --exclude="nvidia-xconfig*3:545.29.06-1.fc39*" \
        #          --exclude="xorg-x11-drv-nvidia-cuda-libs*3:545.29.06-1.fc39*" \
        #          --exclude="xorg-x11-drv-nvidia-cuda*3:545.29.06-1.fc39*" \
        #          --exclude="xorg-x11-drv-nvidia-kmodsrc*3:545.29.06-1.fc39*" \
        #          --exclude="xorg-x11-drv-nvidia-libs*3:545.29.06-1.fc39*" \
        #          --exclude="xorg-x11-drv-nvidia-power*3:545.29.06-1.fc39*" \
        #          --exclude="xorg-x11-drv-nvidia*3:545.29.06-1.fc39*"

        display_message "Enabling nvidia-modeset..."

        # Enable nvidia-modeset
        sudo grubby --update-kernel=ALL --args="nvidia-drm.modeset=1"

        display_message "[${GREEN}✔${NC}]  nvidia-modeset enabled successfully."

        SETTINGS_FILE="/etc/environment"
        BASHRC_FILE="$HOME/.bashrc"
        PAM_LOGIN_FILE="/etc/pam.d/login"

        # Add PAM module for environment variables to /etc/pam.d/login
        if ! grep -q "session    required     pam_env.so" "$PAM_LOGIN_FILE"; then
            echo "session    required     pam_env.so" | sudo tee -a "$PAM_LOGIN_FILE" >/dev/null
            display_message "[${GREEN}✔${NC}] PAM module for environment variables added to $PAM_LOGIN_FILE."
            sleep 2
        else
            display_message "[${RED}✘${NC}] PAM module for environment variables already exists in $PAM_LOGIN_FILE. No changes made."
            sleep 2
        fi

        # Check if the export statements already exist in /etc/environment
        if ! grep -q "__GL_THREADED_OPTIMIZATION=1" "$SETTINGS_FILE" &&
            ! grep -q "__GL_SHADER_CACHE=1" "$SETTINGS_FILE" &&
            ! grep -q "__GLX_VENDOR_LIBRARY_NAME=nvidia" "$SETTINGS_FILE" &&
            ! grep -q "LIBVA_DRIVER_NAME=nvidia" "$SETTINGS_FILE" &&
            ! grep -q "WLR_NO_HARDWARE_CURSORS=1" "$SETTINGS_FILE"; then

            # Add existing NVIDIA environment variables to /etc/environment
            echo "__GL_THREADED_OPTIMIZATION=1" | sudo tee -a "$SETTINGS_FILE" >/dev/null
            echo "__GL_SHADER_CACHE=1" | sudo tee -a "$SETTINGS_FILE" >/dev/null
            # Optionally, set a custom shader cache path
            # echo "export __GL_SHADER_DISK_CACHE_PATH=/path/to/shader/cache" | sudo tee -a "$SETTINGS_FILE" > /dev/null

            # Add new NVIDIA environment variables to /etc/environment
            echo "__GLX_VENDOR_LIBRARY_NAME=nvidia" | sudo tee -a "$SETTINGS_FILE" >/dev/null
            echo "LIBVA_DRIVER_NAME=nvidia" | sudo tee -a "$SETTINGS_FILE" >/dev/null
            echo "WLR_NO_HARDWARE_CURSORS=1" | sudo tee -a "$SETTINGS_FILE" >/dev/null

            # Notify user for /etc/environment
            display_message "[${GREEN}✔${NC}] NVIDIA environment settings have been added to $SETTINGS_FILE."
            gsleep 2

            display_message "[${GREEN}✔${NC}] Please reboot or log out/in for the changes to take effect."
            sleep 2

        else
            # Notify user that export statements already exist in /etc/environment
            display_message "[${RED}✘${NC}] NVIDIA environment settings (export statements) already exist in $SETTINGS_FILE. No changes made."
            sleep 2
        fi

        # Check if the export statements already exist in .bashrc
        if ! grep -q "export __GL_THREADED_OPTIMIZATION=1" "$BASHRC_FILE" &&
            ! grep -q "export __GL_SHADER_CACHE=1" "$BASHRC_FILE" &&
            ! grep -q "export __GLX_VENDOR_LIBRARY_NAME=nvidia" "$BASHRC_FILE" &&
            ! grep -q "export LIBVA_DRIVER_NAME=nvidia" "$BASHRC_FILE" &&
            ! grep -q "export WLR_NO_HARDWARE_CURSORS=1" "$BASHRC_FILE"; then

            # Add existing NVIDIA environment variables to .bashrc
            echo "export __GL_THREADED_OPTIMIZATION=1" >>"$BASHRC_FILE"
            echo "export __GL_SHADER_CACHE=1" >>"$BASHRC_FILE"

            # Optionally, set a custom shader cache path
            # echo "export __GL_SHADER_DISK_CACHE_PATH=/path/to/shader/cache" >> "$BASHRC_FILE"

            # Add new NVIDIA environment variables to .bashrc
            echo "export __GLX_VENDOR_LIBRARY_NAME=nvidia" >>"$BASHRC_FILE"
            echo "export LIBVA_DRIVER_NAME=nvidia" >>"$BASHRC_FILE"
            echo "export WLR_NO_HARDWARE_CURSORS=1" >>"$BASHRC_FILE"

            # Notify user for .bashrc
            display_message "[${GREEN}✔${NC}] NVIDIA environment settings have been added to $BASHRC_FILE."
            sleep 2

            display_message "[${GREEN}✔${NC}] Please restart your shell session for the changes to take effect."
            sleep 2

        else
            # Notify user that export statements already exist in .bashrc
            display_message "[${RED}✘${NC}] NVIDIA environment settings (export statements) already exist in $BASHRC_FILE. No changes made."
        fi

        driver_version=$(modinfo -F version nvidia 2>/dev/null)

        if [ -n "$driver_version" ]; then
            display_message "NVIDIA driver version: $driver_version"
            sleep 2
        else
            display_message "[${RED}✘${NC}] NVIDIA driver not found."
        fi

        sleep 2

        check_error "Failed to install NVIDIA drivers."
        display_message "[${GREEN}✔${NC}]  NVIDIA drivers installed successfully."

        # Make sure the kernel modules got compiled
        sudo akmods --force

        # Make sure the boot image got updated as well
        sudo dracut --force

        # Once more and enable akmods
        sudo systemctl enable --now akmods --force && sudo dracut --force

        source ~/.bashrc
        uname -m && cat /etc/*release
        gcc --version
        uname -r
        sudo systemctl enable nvidia-persistenced.service
        sudo systemctl status nvidia-persistenced.service
        nvidia-smi
        sleep 3.5
    fi

    # Check for AMD GPU
    if lspci | grep -i amd &>/dev/null; then
        display_message "AMD GPU detected. Installing AMD drivers..."

        sudo dnf install -y mesa-dri-drivers
        sudo dnf swap -y mesa-va-drivers mesa-va-drivers-freeworld
        sudo dnf swap -y mesa-vdpau-drivers mesa-vdpau-drivers-freeworld

        check_error "Failed to install AMD drivers."
        display_message "AMD drivers installed successfully."
        sleep 2
    fi

    glxinfo | egrep "OpenGL vendor|OpenGL renderer"

    REBOOT_REQUIRED="yes"
    if [ "$REBOOT_REQUIRED" == "yes" ]; then

        zenity --question \
            --title="Reboot Required." \
            --width=600 \
            --text="$(printf "The system requires a reboot before changes can take effect. Would you like to reboot now?\n\n")"

        if [ $? = 0 ]; then
            shutdown -r now &>>/tmp/nvcheck.log || {
                zenity --error --text="Failed to issue reboot:\n\n $(cat /tmp/nvcheck.log)\n\n Please reboot the system manually."
                exit 1
            }
        else
            exit 0
        fi

    fi

    # Prompt user for reboot or continue
    read -p "Do you want to reboot now? (y/n): " choice
    case "$choice" in
    y | Y)
        # Reboot the system after 3 minutes
        display_message "Rebooting in 3 minutes. Press Ctrl+C to cancel."
        sleep 180
        sudo reboot
        ;;
    n | N)
        display_message "Reboot skipped. Continuing with the script."
        ;;
    *)
        display_message "Invalid choice. Continuing with the script."
        ;;
    esac
}
