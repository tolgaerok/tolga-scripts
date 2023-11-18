#!/bin/bash
# Tolga Erok
# My personal Fedora 39 KDE tweaker
# 18/11/2023
# Run from remote location:   
# sudo bash -c "$(curl -fsSL https://raw.githubusercontent.com/tolgaerok/tolga-scripts/main/Fedora39/TolgaFedora39.sh)"

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

# Function to configure faster updates in DNF
configure_dnf() {
    # Define the path to the DNF configuration file
    DNF_CONF_PATH="/etc/dnf/dnf.conf"

    display_message "Configuring faster updates in DNF..."

    # Check if the file exists before attempting to edit it
    if [ -e "$DNF_CONF_PATH" ]; then
        # Backup the original configuration file
        sudo cp "$DNF_CONF_PATH" "$DNF_CONF_PATH.bak"

        # Use sudo to edit the DNF configuration file with nano
        sudo nano "$DNF_CONF_PATH" <<EOL
[main]
gpgcheck=1
installonly_limit=3
clean_requirements_on_remove=True
best=False
skip_if_unavailable=True
fastestmirror=1
max_parallel_downloads=10
deltarpm=true
EOL

        # Inform the user that the update is complete
        display_message "DNF configuration updated for faster updates."
    else
        # Inform the user that the configuration file doesn't exist
        display_message "Error: DNF configuration file not found at $DNF_CONF_PATH."
    fi
}

# Function to install RPM Fusion
install_rpmfusion() {
    display_message "Installing RPM Fusion repositories..."

    sudo dnf install -y https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm \
        https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm

    check_error

    display_message "RPM Fusion installed successfully."
}

# Function to update the system
update_system() {
    display_message "Updating the system..."

    sudo dnf -y update
    sudo dnf -y upgrade --refresh

    check_error

    display_message "System updated successfully."
}

# Function to install firmware updates with a countdown on error
install_firmware() {
    display_message "Installing firmware updates..."

    # Attempt to install firmware updates
    sudo fwupdmgr get-devices
    sudo fwupdmgr refresh --force
    sudo fwupdmgr get-updates
    sudo fwupdmgr update

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

        # Disable Secure Boot, old fedora hacks of mine
        sudo dnf update
        sudo systemctl disable --now fwupd-refresh.timer
        sudo dnf install -y kernel-devel akmod-nvidia xorg-x11-drv-nvidia-cuda

        check_error "Failed to install NVIDIA drivers."
        display_message "NVIDIA drivers installed successfully."
    fi

    # Check for AMD GPU
    if lspci | grep -i amd &> /dev/null; then
        display_message "AMD GPU detected. Installing AMD drivers..."

        sudo dnf install -y mesa-dri-drivers

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

# Function to optimize battery life on lappy, in theory.... LOL
optimize_battery() {
    display_message "Optimizing battery life..."

    # Check if the battery exists
    if [ -e "/sys/class/power_supply/BAT0" ]; then
        # Install TLP and mask power-profiles-daemon
        sudo dnf install -y tlp tlp-rdw
        sudo systemctl mask power-profiles-daemon

        # Install powertop and apply auto-tune
        sudo dnf install -y powertop
        sudo powertop --auto-tune

        display_message "Battery optimization completed."
    else
        display_message "No battery found. Skipping battery optimization."
    fi
}

# Function to install multimedia codecs, old fedora hacks to meet new standards (F39)
install_multimedia_codecs() {
    display_message "Installing multimedia codecs..."

    sudo dnf groupupdate 'core' 'multimedia' 'sound-and-video' --setopt='install_weak_deps=False' --exclude='PackageKit-gstreamer-plugin' --allowerasing && sync
    sudo dnf swap 'ffmpeg-free' 'ffmpeg' --allowerasing
    sudo dnf install -y gstreamer1-plugins-{bad-\*,good-\*,base} gstreamer1-plugin-openh264 gstreamer1-libav --exclude=gstreamer1-plugins-bad-free-devel ffmpeg gstreamer-ffmpeg
    sudo dnf install -y lame\* --exclude=lame-devel
    sudo dnf group upgrade --with-optional Multimedia

    display_message "Multimedia codecs installed successfully."
}

# Function to install H/W Video Acceleration for Intel chipset
install_hw_video_acceleration_intel() {
    display_message "Installing H/W Video Acceleration for Intel chipset..."

    sudo dnf install -y intel-media-driver

    display_message "H/W Video Acceleration for Intel chipset installed successfully."
}

# Function to install H/W Video Acceleration for AMD or Intel chipset
install_hw_video_acceleration_amd_or_intel() {
    display_message "Checking for AMD chipset..."

    # Check for AMD chipset
    if lspci | grep -i amd &>/dev/null; then
        display_message "AMD chipset detected. Installing AMD video acceleration..."

        sudo dnf swap -y mesa-va-drivers mesa-va-drivers-freeworld
        sudo dnf config-manager --set-enabled fedora-cisco-openh264
        sudo dnf install -y openh264 gstreamer1-plugin-openh264 mozilla-openh264

        display_message "H/W Video Acceleration for AMD chipset installed successfully."
    else
        display_message "No AMD chipset found. Pausing for user confirmation..."

        # Pause for user confirmation
        read -p "Press Enter to check for Intel chipset..."

        display_message "Checking for Intel chipset..."

        # Check for Intel chipset
        if lspci | grep -i intel &>/dev/null; then
            display_message "Intel chipset detected. Installing Intel video acceleration..."

            sudo dnf install -y intel-media-driver

            display_message "H/W Video Acceleration for Intel chipset installed successfully."
        else
            display_message "No Intel chipset found. Skipping H/W Video Acceleration installation."
        fi
    fi
}

# Function to clean up old or unused Flatpak packages
cleanup_flatpak_cruft() {
    display_message "Cleaning up old or unused Flatpak packages..."

    # Remove uninstalled runtimes
    flatpak uninstall --unused -y

    # Remove uninstalled applications
    flatpak uninstall --unused -y --delete-data

    display_message "Flatpak cleanup completed."
}

# Function to update Flatpak
update_flatpak() {
    display_message "Updating Flatpak..."

    flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
    flatpak update

    display_message "Flatpak updated successfully."

    # Call the cleanup function
    cleanup_flatpak_cruft
}

# Function to set UTC Time for dual boot issues, old hack of mine
set_utc_time() {
    display_message "Setting UTC Time..."

    sudo timedatectl set-local-rtc '0'

    display_message "UTC Time set successfully."
}

# Function to disable mitigations, old fedora hack and used on nixos also, thanks chris titus!
disable_mitigations() {
    display_message "Disabling Mitigations..."

    # Inform the user about the security risks
    display_message "Note: Disabling mitigations can present security risks. Only proceed if you understand the implications."

    # Ask for user confirmation
    read -p "Do you want to proceed? (y/n): " choice
    case "$choice" in
    y | Y)
        # Disable mitigations
        sudo grubby --update-kernel=ALL --args="mitigations=off"
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

# Function to enable Modern Standby. Can result in better battery life when your laptop goes to sleep.... in theory LOL
enable_modern_standby() {
    display_message "Enabling Modern Standby..."

    # Enable Modern Standby
    sudo grubby --update-kernel=ALL --args="mem_sleep_default=s2idle"

    display_message "Modern Standby enabled successfully."
}

# Function to enable nvidia-modeset
enable_nvidia_modeset() {
    display_message "Enabling nvidia-modeset..."

    # Enable nvidia-modeset
    sudo grubby --update-kernel=ALL --args="nvidia-drm.modeset=1"

    display_message "nvidia-modeset enabled successfully."
}

# Function to disable NetworkManager-wait-online.service
disable_network_manager_wait_online() {
    display_message "Disabling NetworkManager-wait-online.service..."

    # Disable NetworkManager-wait-online.service
    sudo systemctl disable NetworkManager-wait-online.service

    display_message "NetworkManager-wait-online.service disabled successfully."
}

# Function to disable Gnome Software from Startup Apps, if gnome is used... in theory will save heaps of RAM on startup
disable_gnome_software_startup() {
    display_message "Disabling Gnome Software from Startup Apps..."

    # Remove Gnome Software from autostart
    sudo rm /etc/xdg/autostart/org.gnome.Software.desktop

    display_message "Gnome Software disabled from Startup Apps successfully."
}

# Function to use themes in Flatpaks, learned from nixos and trials and errors...
use_flatpak_themes() {
    display_message "Using themes in Flatpaks..."

    # Override themes for Flatpaks
    sudo flatpak override --filesystem=$HOME/.themes
    sudo flatpak override --env=GTK_THEME=my-theme

    display_message "Themes applied to Flatpaks successfully."
}

# Main script execution, kingtolga style LOL
configure_dnf
install_rpmfusion
update_system
install_firmware
# install_nvidia_drivers
install_gpu_drivers   # Updated
optimize_battery
install_multimedia_codecs
install_hw_video_acceleration_intel
install_hw_video_acceleration_amd
update_flatpak
set_utc_time
disable_mitigations
enable_modern_standby
enable_nvidia_modeset
disable_network_manager_wait_online
disable_gnome_software_startup
use_flatpak_themes
