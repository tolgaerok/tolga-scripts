#!/bin/bash

# Tolga Erok.
# My personal Fedora 39 KDE tweaker
# 18/11/2023

# Run from remote location:::.
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
    clear
    echo -e "\n                  Tolga's online fedora updater\n"
    echo -e "\e[34m|--------------------\e[33m Currently configuring:\e[34m-------------------|"
    echo -e "|      ===>    $1"
    echo -e "\e[34m|--------------------------------------------------------------|\e[0m"
    echo ""
    sleep 1
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
metadata_timer_sync=0
metadata_expire=6h
metadata_expire_filter=repo:base:2h
metadata_expire_filter=repo:updates:12h
EOL

        # Inform the user that the update is complete
        display_message "DNF configuration updated for faster updates."
        sudo dnf update && sudo dnf makecache
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
    display_message "Updating the system...."

    sudo dnf update -y  

    # Install necessary dependencies if not already installed
    display_message "Checking for extra dependencies..."
    sudo dnf install -y rpmconf 
    sudo dnf makecache -y
    sudo dnf upgrade -y --refresh

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
    if lspci | grep -i nvidia &>/dev/null; then
        display_message "NVIDIA GPU detected. Installing NVIDIA drivers..."

        sudo dnf update
        echo "blacklist nouveau" >> /etc/modprobe.d/blacklist.conf
        
        sudo dnf install -y akmod-nvidia
        echo "blacklist nouveau" | sudo tee -a /etc/modprobe.d/blacklist.conf
        sudo dnf remove -y xorg-x11-drv-nouveau

        sudo dracut -f
        sudo systemctl disable --now fwupd-refresh.timer
        sudo dnf repolist | grep 'rpmfusion-nonfree-updates'
        sudo dnf install -y https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm
        sudo dnf install -y https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
        sudo dnf config-manager --set-enabled rpmfusion-free rpmfusion-free-updates rpmfusion-nonfree rpmfusion-nonfree-updates
        sudo dnf install -y fedora-workstation-repositories kernel-devel kernel-headers gcc make dkms acpid libglvnd-glx libglvnd-opengl libglvnd-devel pkgconfig
        sudo dnf install -y kernel-devel akmod-nvidia xorg-x11-drv-nvidia-cuda xorg-x11-drv-nvidia-cuda-libs gcc kernel-headers xorg-x11-drv-nvidia xorg-x11-drv-nvidia-libs
        sudo dnf install -y vdpauinfo libva-vdpau-driver libva-utils vulkan akmods
        sudo dnf install -y nvidia-settings nvidia-persistenced
        sudo akmods --force
        sudo dracut --force

        # sudo dnf remove xorg-x11-drv-nvidia\*
        # sudo dnf install xrandr
        # sudo systemctl start nvidia-powerd.service
        # sudo systemctl status nvidia-powerd.service

         display_message "Enabling nvidia-modeset..."

        # Enable nvidia-modeset
        sudo grubby --update-kernel=ALL --args="nvidia-drm.modeset=1"

        display_message "nvidia-modeset enabled successfully."

        driver_version=$(modinfo -F version nvidia 2>/dev/null)

        if [ -n "$driver_version" ]; then
            display_message "NVIDIA driver version: $driver_version"
            sleep 1
        else
            display_message "NVIDIA driver not found."
        fi

        sleep 2

        check_error "Failed to install NVIDIA drivers."
        display_message "NVIDIA drivers installed successfully."
    fi

    # Check for AMD GPU
    if lspci | grep -i amd &>/dev/null; then
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
    # flatpak update
    flatpak update --refresh

    display_message "Executing Tolga's Flatpak's..."
    # Execute the Flatpak Apps installation script from the given URL
    sudo bash -c "$(curl -fsSL https://raw.githubusercontent.com/tolgaerok/tolga-scripts/main/Fedora39/FlatPakApps.sh)"

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
    sudo flatpak override --filesystem="$HOME/.themes"

    # Select your theme from inside of ./themes
    sudo flatpak override --env=GTK_THEME=Nordic

    display_message "Themes applied to Flatpaks successfully."
}

# Function to check if mitigations=off is present in GRUB configuration
check_mitigations_grub() {
    display_message "Checking if mitigations=off is present in GRUB configuration..."

    # Read the GRUB configuration
    grub_config=$(cat /etc/default/grub)

    # Check if mitigations=off is present
    if echo "$grub_config" | grep -q "mitigations=off"; then
        display_message "Mitigations are currently disabled in GRUB configuration: ==>  ( Success! )"
        sleep 1
    else
        display_message "Warning: Mitigations are not currently disabled in GRUB configuration."
    fi
}

install_apps() {
    display_message "Installing afew personal apps..."

    # Install Kate
    sudo dnf install -y kate git digikam rygel

    # Check for errors during installation
    if [ $? -eq 0 ]; then
        display_message "Apps installed successfully."
    else
        display_message "Error: Unable to install Apps."
    fi
}

customize_kde_nordic() {
    display_message "Install Nordic Theme..."

    # Install the Kvantum theme engine
    sudo dnf install -y kvantum

    # Download and install Nordic KDE theme
    git clone https://github.com/EliverLara/Nordic.git /tmp/Nordic

    # Check if the Nordic directory exists
    if [ ! -d "/tmp/Nordic" ]; then
        display_message "Error: Nordic directory not found."
        return 1
    fi

    # Navigate to the Nordic directory
    cd /tmp/Nordic || {
        display_message "Error: Unable to change to the Nordic directory."
        return 1
    }

    # Look for the installation scripts and execute the first one found
    for script in install.sh setup.sh; do
        if [ -f "$script" ]; then
            ./$script
            break
        fi
    done

    # Check if the installation was successful before proceeding with configuration
    if [ $? -ne 0 ]; then
        display_message "Error: Installation script failed. Unable to customize KDE."
        return 1
    fi

    # Set the Nordic theme for Plasma style
    kwriteconfig5 --file "$HOME/.config/kdedefaults/kdeglobals" --group General --key widgetStyle "kvantum"

    # Set the Nordic theme for Window decorations
    kwriteconfig5 --file "$HOME/.config/kdedefaults/kwinrc" --group org.kde.kdecoration2 --key theme "nordic"

    # Set sub-pixel rendering to RGB
    kwriteconfig5 --file "$HOME/.config/kdedefaults/kdeglobals" --group General --key UseOpenGL "True"

    # Force font DPI to 98
    kwriteconfig5 --file "$HOME/.config/kdedefaults/kdeglobals" --group General --key forceFontDPI "98"

    # Set the Icons to Nordic-bluish
    kwriteconfig5 --file "$HOME/.config/kdedefaults/kdeglobals" --group General --key iconTheme "Nordic-bluish"

    # Set the splash screen to none
    # kwriteconfig5 --file "$HOME/.config/kdedefaults/ksplashrc" --group KSplash --key Theme "none"

    # Clean up temporary files
    display_message "Clean up tmp files.."
    rm -rf /tmp/Nordic

    display_message "KDE customization completed successfully."
}

cleanup_fedora() {
    # Clean package cache
    display_message " Time to clean up system..."
    sudo dnf clean all

    # Remove unnecessary dependencies
    sudo dnf autoremove -y

    # Sort the lists of installed packages and packages to keep
    display_message "Sorting out list of installed packages and packages to keep..."
    comm -23 <(sudo dnf repoquery --installonly --latest-limit=-1 -q | sort) <(sudo dnf list installed | awk '{print $1}' | sort) >/tmp/orphaned-pkgs

    if [ -s /tmp/orphaned-pkgs ]; then
        sudo dnf remove $(cat /tmp/orphaned-pkgs) -y --skip-broken
    else
        display_message "No orphaned packages found."
    fi

    # Clean up temporary files
    display_message "Clean up temporary files ..."
    sudo rm -rf /tmp/orphaned-pkgs

    display_message "Trimming all mount points on SSD"
    sudo fstrim -av

    echo -e "\e[1;32m[✔]\e[0m Restarting kernel tweaks...\n"
    sleep 1
    sudo sysctl --system

    display_message "Cleanup complete, ENJOY!"
}

fix_chrome() {   
    display_message "Applying chrome HW accelerations issue for now"
    # Prompt user for reboot or continue
    read -p "Do you want to down grade mesa dlibs now? (y/n): " choice
    case "$choice" in
    y | Y)
        # Apply fix
        display_message "Applied"        
        sudo sudo dnf downgrade mesa-libGL
        # sudo rm -rf ./config/google-chrome
        sleep 2
        display_message "Bug @ https://bugzilla.redhat.com/show_bug.cgi?id=2193335"
        ;;
    n | N)
        display_message "Fix skipped. Continuing with the script."
        ;;
    *)
        display_message "Invalid choice. Continuing with the script."
        ;;
    esac
        
    echo "If problems persist, copy and pate the following into chrome address bar and disable HW acceleration"
    echo ""
    echo "chrome://settings/?search=hardware+acceleration"
    sleep 3
}

# Main script execution, kingtolga style LOL
# --------------------------------------------------------------------------------------
configure_dnf
install_rpmfusion
update_system
install_firmware
install_gpu_drivers                                   # Updated
# optimize_battery                                    # Casuing issues, disabled
install_multimedia_codecs
# install_hw_video_acceleration_intel                 # Casuing issues, disabled
# install_hw_video_acceleration_amd                   # Casuing issues, disabled
update_flatpak
set_utc_time                                          # for dual boot systems
disable_mitigations                                   # speed up system
# enable_modern_standby                               # Casuing issues, disabled
# enable_nvidia_modeset                               # moved into nvidia install
disable_network_manager_wait_online
disable_gnome_software_startup
# use_flatpak_themes                                  # needs revisiting
check_mitigations_grub
install_apps
# customize_kde_nordic                                # To Do and fix
cleanup_fedora
configure_dnf
fix_chrome
