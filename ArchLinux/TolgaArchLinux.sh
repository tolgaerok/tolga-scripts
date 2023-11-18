#!/bin/bash
# Tolga Erok
# My personal Arch Linux tweaker
# 18/11/2023

# Run from remote location:
# sudo bash -c "$(curl -fsSL https://raw.githubusercontent.com/tolgaerok/tolga-scripts/main/ArchLinux/TolgaArchLinux.sh)"

#           ¯\_(ツ)_/¯
#   ▄▄▄       ██▀███   ▄████▄   ██░ ██
#  ▒████▄    ▓██ ▒ ██▒▒██▀ ▀█  ▓██░ ██▒
#  ▒██  ▀█▄  ▓██ ░▄█ ▒▒▓█    ▄ ▒██▀▀██░
#  ░██▄▄▄▄██ ▒██▀▀█▄  ▒▓▓▄ ▄██▒░▓█ ░██
#   ▓█   ▓██▒░██▓ ▒██▒▒ ▓███▀ ░░▓█▒░██▓
#   ▒▒   ▓▒█░░ ▒▓ ░▒▓░░ ░▒ ▒  ░ ▒ ░░▒░▒
#    ▒   ▒▒ ░  ░▒ ░ ▒░  ░  ▒    ▒ ░▒░ ░
#    ░   ▒     ░░   ░ ░         ░  ░░ ░
#        ░  ░   ░     ░ ░       ░  ░  ░
#                     ░


clear

# Check if the script is run as root
if [ "$EUID" -ne 0 ]; then
    echo "Please run this script as root or using sudo."
    exit 1
fi

# Function to display messages
display_message() {
    echo "----------------------------------------------------------------"
    echo "$1"
    echo "----------------------------------------------------------------"
}

# Function to check and display errors
check_error() {
    if [ $? -ne 0 ]; then
        display_message "Error occurred. Exiting."
        # Print the error details
        echo "Error details: $1"
        exit 1
    fi
}

# Function to configure faster updates in pacman
configure_pacman() {
    display_message "Configuring faster updates in pacman..."

    # Update the system and install reflector
    pacman -Syu --noconfirm
    pacman -S reflector --noconfirm

    # Backup the mirrorlist
    cp /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.bak

    # Use reflector to generate a new mirrorlist
    reflector --verbose --country 'United States' -l 200 -p http --sort rate --save /etc/pacman.d/mirrorlist

    # Update the system again to apply changes
    pacman -Syu --noconfirm

    display_message "Pacman configuration updated for faster updates."
}

# Function to install yay for AUR packages
install_yay() {
    display_message "Installing yay for AUR packages..."

    # Install yay from the Arch User Repository (AUR)
    pacman -S yay --noconfirm

    check_error "Failed to install yay."

    display_message "Yay installed successfully."
}

# Function to update the system
update_system() {
    display_message "Updating the system..."

    pacman -Syu --noconfirm

    check_error "Failed to update the system."

    display_message "System updated successfully."
}

# Function to install firmware updates
install_firmware() {
    display_message "Installing firmware updates..."

    # Attempt to install firmware updates
    fwupdmgr get-devices
    fwupdmgr refresh --force
    fwupdmgr get-updates
    fwupdmgr update

    # Check for errors during firmware updates
    if [ $? -ne 0 ]; then
        display_message "Error occurred during firmware updates. Continuing with the script after a 10-second countdown."

        # Countdown for 10 seconds on error
        for i in {10..1}; do
            echo -ne "Continuing in $i seconds... \r"
            sleep 1
        done
        echo -e "Continuing with the script."
    else
        display_message "Firmware updated successfully."
    fi
}

# Function to install GPU drivers with a reboot option on a 3 min timer, Nvidia && AMD
install_gpu_drivers() {
    display_message "Checking GPU and installing drivers..."

    # Check for NVIDIA GPU
    if lspci | grep -i nvidia &> /dev/null; then
        display_message "NVIDIA GPU detected. Installing NVIDIA drivers..."

        # Install NVIDIA drivers
        pacman -S nvidia nvidia-utils --noconfirm

        check_error "Failed to install NVIDIA drivers."

        display_message "NVIDIA drivers installed successfully."
    fi

    # Check for AMD GPU
    if lspci | grep -i amd &> /dev/null; then
        display_message "AMD GPU detected. Installing AMD drivers..."

        # Install AMD drivers
        pacman -S mesa --noconfirm

        check_error "Failed to install AMD drivers."

        display_message "AMD drivers installed successfully."
    fi

    # Prompt user for reboot or continue
    read -p "Do you want to reboot now? (y/n): " choice
    case "$choice" in
    y | Y)
        # Reboot the system after 3 minutes
        display_message "Rebooting in 3 minutes. Press Ctrl+C to cancel."
        sleep 180
        reboot
        ;;
    n | N)
        display_message "Reboot skipped. Continuing with the script."
        ;;
    *)
        display_message "Invalid choice. Continuing with the script."
        ;;
    esac
}

# Function to optimize battery life on laptop
optimize_battery() {
    display_message "Optimizing battery life..."

    # Install TLP for power management
    pacman -S tlp --noconfirm
    systemctl enable --now tlp

    display_message "Battery optimization completed."
}

# Function to install multimedia codecs
install_multimedia_codecs() {
    display_message "Installing multimedia codecs..."

    pacman -S --noconfirm --needed \
        ffmpeg \
        gstreamer \
        gstreamer-plugins \
        gstreamer-vaapi \
        gstreamer-plugins-base \
        gstreamer-plugins-good \
        gstreamer-plugins-bad \
        gstreamer-plugins-ugly \
        lame \
        libdvdcss \
        libmad \
        libmpeg2 \
        libtheora \
        libvorbis \
        x264 \
        x265 \
        xvidcore

    display_message "Multimedia codecs installed successfully."
}

# Function to install H/W Video Acceleration for Intel chipset
install_hw_video_acceleration_intel() {
    display_message "Installing H/W Video Acceleration for Intel chipset..."

    pacman -S --noconfirm --needed libva-intel-driver

    display_message "H/W Video Acceleration for Intel chipset installed successfully."
}

# Function to install H/W Video Acceleration for AMD chipset
install_hw_video_acceleration_amd() {
    display_message "Installing H/W Video Acceleration for AMD chipset..."

    pacman -S --noconfirm --needed mesa-vdpau libva-vdpau-driver

    display_message "H/W Video Acceleration for AMD chipset installed successfully."
}

# Function to clean up old or unused AUR packages
cleanup_aur_cruft() {
    display_message "Cleaning up old or unused AUR packages..."

    # Remove orphaned packages
    pacman -Rns $(pacman -Qtdq) --noconfirm

    display_message "AUR cleanup completed."
}

# Function to set UTC Time for dual boot issues
set_utc_time() {
    display_message "Setting UTC Time..."

    timedatectl set-local-rtc 0

    display_message "UTC Time set successfully."
}

# Function to disable mitigations
disable_mitigations() {
    display_message "Disabling Mitigations..."

    # Inform the user about the security risks
    display_message "Note: Disabling mitigations can present security risks. Only proceed if you understand the implications."

    # Ask for user confirmation
    read -p "Do you want to proceed? (y/n): " choice
    case "$choice" in
    y | Y)
        # Disable mitigations
        echo "mitigations=off" >> /etc/default/grub
        grub-mkconfig -o /boot/grub/grub.cfg

        display_message "Mitigations disabled successfully."
        ;;
    n | N)
        display_message "Mitigations not disabled. Exiting."
        exit 1
        ;;
    *)
        display_message "Invalid choice. Exiting."
        exit 1
        ;;
    esac
}

# Function to enable Modern Standby
enable_modern_standby() {
    display_message "Enabling Modern Standby..."

    # Enable Modern Standby
    sed -i 's/GRUB_CMDLINE_LINUX_DEFAULT="\(.*\)"/GRUB_CMDLINE_LINUX_DEFAULT="\1 mem_sleep_default=s2idle"/' /etc/default/grub
    grub-mkconfig -o /boot/grub/grub.cfg

    display_message "Modern Standby enabled successfully."
}

# Function to enable nvidia-modeset
enable_nvidia_modeset() {
    display_message "Enabling nvidia-modeset..."

    # Enable nvidia-modeset
    sed -i 's/GRUB_CMDLINE_LINUX="\(.*\)"/GRUB_CMDLINE_LINUX="\1 nvidia-drm.modeset=1"/' /etc/default/grub
    grub-mkconfig -o /boot/grub/grub.cfg

    display_message "nvidia-modeset enabled successfully."
}

# Function to disable Gnome Software from Startup Apps
disable_gnome_software_startup() {
    display_message "Disabling Gnome Software from Startup Apps..."

    # Remove Gnome Software from autostart
    rm /etc/xdg/autostart/org.gnome.Software.desktop

    display_message "Gnome Software disabled from Startup Apps successfully."
}

# Function to check if mitigations=off is present in GRUB configuration
check_mitigations_grub() {
    display_message "Checking if mitigations=off is present in GRUB configuration..."
    
    # Read the GRUB configuration
    grub_config=$(grep "GRUB_CMDLINE_LINUX=" /etc/default/grub)
    
    # Check if mitigations=off is present
    if echo "$grub_config" | grep -q "mitigations=off"; then
        display_message "Mitigations are currently disabled in GRUB configuration...Success!"
    else
        display_message "Warning: Mitigations are not currently disabled in GRUB configuration."
    fi
}

# Main script execution, kingtolga style LOL
configure_pacman
install_yay
update_system
install_firmware
install_gpu_drivers
optimize_battery
install_multimedia_codecs
install_hw_video_acceleration_intel
install_hw_video_acceleration_amd
cleanup_aur_cruft
set_utc_time
disable_mitigations
enable_modern_standby
enable_nvidia_modeset
disable_gnome_software_startup
check_mitigations_grub
