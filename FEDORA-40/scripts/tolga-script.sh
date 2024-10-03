#!/bin/bash
# Tolga Erok
# Aug 5 2024

PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/snap/bin

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

echo '[charm]
name=Charm
baseurl=https://repo.charm.sh/yum/
enabled=1
gpgcheck=1
gpgkey=https://repo.charm.sh/yum/gpg.key' | sudo tee /etc/yum.repos.d/charm.repo

sudo yum install gum -y
clear

display_message() {
    clear
    echo -e "\n                  Tolga's online fedora updater\n"
    echo -e "\e[34m|--------------------\e[33m Currently configuring:\e[34m-------------------|"
    echo -e "|${YELLOW}==>${NC}  $1"
    echo -e "\e[34m|--------------------------------------------------------------|\e[0m"
    echo ""
    gum spin --spinner dot --title "Stand-by..." -- sleep 1
}

# Function to check and display errors
check_error() {
    if [ $? -ne 0 ]; then
        display_message "[${RED}✘${NC}] Error occurred !!"
        # Print the error details
        echo "Error details: $1"
        gum spin --spinner dot --title "Stand-by..." -- sleep 8
    fi
}

# Function to download and install a package
download_and_install() {
    url="$1"
    location="$2"
    package_name="$3"

    # Check if the package is already installed
    if sudo dnf list installed "$package_name" &>/dev/null; then
        display_message "[${RED}✘${NC}] $package_name is already installed. Skipping installation."
        sleep 1
        return
    fi

    # Download the package
    wget "$url" -O "$location"

    # Install the package
    sudo dnf install -y "$location"
}

display_message "Updating the system...."

sudo dnf update -y

# Install necessary dependencies if not already installed
display_message "Checking for extra dependencies..."
sudo dnf install -y rpmconf

display_message "Extra fonts for VSCODE terminal..."
mkdir -p ~/.local/share/fonts
ln -s ~/.local/share/fonts/ ~/.fonts
cd ~/.fonts 
curl -OL https://github.com/ryanoasis/nerd-fonts/releases/latest/download/Hack.tar.xz
tar -xvf Hack.tar.xz

# 'Cascadia Code', 'Droid Sans Mono', 'monospace','Hack Nerd Font',monospace

# Install DNF plugins core (if not already installed)
sudo dnf install -y dnf-plugins-core

# Install required dependencies
# sudo dnf install -y epel-release
sudo dnf install -y dnf-plugins-core

# Update the package manager
sudo dnf makecache -y
sudo dnf upgrade -y --refresh

check_error

display_message "System updated successfully."
gum spin --spinner dot --title "Stand-by..." -- sleep 2

sudo dnf install dnf5 -y
sudo dnf5 install dnf5 dnf5-plugins
sudo dnf5 update && sudo dnf5 makecache

# List of personal packages to install by category
# --------------------------------------------------

# Utilities
utilities=(
    "brasero"
    "cowsay"
    "curl"
    "dconf-editor"
    "direnv"
    "dnfdragora"
    "duf"
    "earlyoom"
    "easyeffects"
    "fd-find"
    "ffmpeg"
    "ffmpegthumbnailer"
    "figlet"
    "fortune-mod"
    "fzf"
    "git"
    "gparted"
    "htop"
    "lsd"
    "mpg123"
    "nano"
    "neofetch"
    "p7zip"
    "p7zip-plugins"
    "pip"
    "pulseeffects"
    "python-dnf-plugin-snapper"
    "python3"
    "python3-pip"
    "rsync"
    "sassc"
    "snapper"
    "tar"
    "tmux"
    "tumbler"
    "unrar"
    "unzip"
    "variety"
    "wget"
    "wget"
    "xclip"
    "xprop"
    "zip"
    "zstd"
)

# Networking
networking=(
    "cockpit-networkmanager"
    "firewall-config"
    "libvirt"
    "lxc"
    "openssh"
    "openssh-clients"
    "openssh-server"
    "samba"
    "samba-dcerpc"
    "samba-ldb-ldap-modules"
    "samba-winbind-clients"
    "samba-winbind-modules"
    "sshpass"
    "tailscale"
    "virt-manager"
    "virt-viewer"
    "wireguard-tools"
    "wsdd"
)

# Fonts
fonts=(
    "google-noto-cjk-fonts"
    "google-noto-emoji-color-fonts"
    "adobe-source-code-pro-fonts"
    "cascadia-code-fonts"
    "google-droid-sans-mono-fonts"
    "google-go-mono-fonts"
    "ibm-plex-mono-fonts"
    "jetbrains-mono-fonts-all"
    "mozilla-fira-mono-fonts"
    "nerd-fonts"
    "opendyslexic-fonts"
    "powerline-fonts"
)

# Development Tools
dev_tools=(
    "git"
    "gcc"
    "make"
    "libffi-devel"
    "openssl-devel"
    "libxcrypt-compat"
    "libimobiledevice"
    "python3-pip"
)

# Virtualization
virtualization=(
    "incus"
    "libvirt"
    "lxd"
    "lxd-agent"
    "qemu"
    "qemu-char-spice"
    "qemu-device-display-virtio-gpu"
    "qemu-device-display-virtio-vga"
    "qemu-device-usb-redirect"
    "qemu-img"
    "qemu-system-x86-core"
    "qemu-user-binfmt"
    "qemu-user-static"
    "virt-manager"
    "virt-viewer"
)

# System Tools
system_tools=(
    "AcetoneISO"
    "bchunk"
    "ccd2iso"
    "clementine"
    "dbus-x11"
    "dnf5"
    "dnf5-plugins"
    "dnfdragora"
    "fd-find"
    "flatpak"
    "flatpak-builder"
    "fuse-encfs"
    "fzf"
    "grub-customizer"
    "gtk-murrine-engine"
    "gtk2-engines"
    "hplip"
    "input-leap"
    "input-remapper"
    "intel-media-driver"
    "k3b"
    "kate"
    "krb5-workstation"
    "krfb"
    "krfb-libs"
    "libva-intel-driver"
    "libyui-mga-qt"
    "libyui-qt"
    "liveusb-creator"
    "lm_sensors"
    "mesa-filesystem"
    "mesa-libEGL"
    "mesa-libGL"
    "mesa-libGL-devel"
    "mesa-libGLU"
    "mesa-libGLU"
    "mesa-libGLU-devel"
    "mesa-libGLw"
    "mesa-libglapi"
    "mesa-va-drivers"
    "mozilla-ublock-origin"
    "mplayer"
    "ntfs-3g"
    "powertop"
    "printer-driver-brlaser"
    "pulseaudio-utils"
    "python-dnf-plugin-snapper"
    "qt5ct"
    "snapper"
    "solaar"
    "stress-ng"
    "stress-ng"
    "tlp"
    "tlp-rdw"
    "tmux"
    "usbmuxd"
    "vlc"
    "vlc-core"
    "wireguard-tools"
    "wl-clipboard"
    "xine-lib"
    "xprop"
    "zsh"
)

# Printer & Scanner
printer_scanner=(
    "epson-inkjet-printer-escpr"
    "epson-inkjet-printer-escpr2"
    "foo2zjs"
    "hplip"
    "printer-driver-brlaser"
)

# Multi-media
multimedia=(
    "clementine"
    "easyeffects"
    "ffmpeg-libs"
    "mplayer"
    "pulseeffects"
    "rhythmbox"
    "shotwell"
    "vlc"
    "vlc-core"
    "xine-lib"
)

# Graphics
graphics_design=(
    "digikam"
    "gimp"
    "gimp-devel"
    "gnome-font-viewer"
    "sxiv"
    "variety"
)

# Package Installation
install_packages() {
    local category="$1"
    shift
    local packages=("$@")

    # Define color codes
    local yellow='\033[1;33m'
    local green='\033[1;32m'
    local reset='\033[0m'

    # Print a separator line for clarity
    echo -e "${yellow}========================================${reset}"
    echo -e "${yellow}Installing $category packages...${reset}"
    echo -e "${yellow}========================================${reset}"
    echo ""
    # Install packages
    sudo dnf install --assumeyes "${packages[@]}"
    
    # Print a completion message
    echo ""
    echo -e "${green}Finished installing $category packages.${reset}"
    echo
    sleep 1
}

# Update package list
sudo dnf update -y

# Install packages by category
install_packages "Utilities" "${utilities[@]}"
install_packages "Networking" "${networking[@]}"
install_packages "Fonts" "${fonts[@]}"
install_packages "Development Tools" "${dev_tools[@]}"
install_packages "Virtualization" "${virtualization[@]}"
install_packages "System Tools" "${system_tools[@]}"
install_packages "Printer & Scanner" "${printer_scanner[@]}"
install_packages "MultiMedia" "${multimedia[@]}"
install_packages "Graphics" "${graphics_design[@]}"


wget https://mega.nz/linux/repo/Fedora_40/x86_64/megasync-Fedora_40.x86_64.rpm && sudo dnf install "$PWD/megasync-Fedora_40.x86_64.rpm"

sudo dnf copr enable atim/ubuntu-fonts -y && sudo dnf install ubuntu-family-fonts -y

sudo dnf install --assumeyes --best --allowerasing \
    flatpak neofetch nano htop zip un{zip,rar} tar ffmpeg ffmpegthumbnailer tumbler sassc \
    google-noto-{cjk,emoji-color}-fonts gtk-murrine-engine gtk2-engines ntfs-3g wget curl git openssh \
    libva-intel-driver intel-media-driver mozilla-ublock-origin easyeffects pulseeffects

#sudo dnf install -y PackageKit dconf-editor digikam direnv duf earlyoom espeak ffmpeg-libs figlet gedit gimp gimp-devel git gnome-font-viewer vlc vlc-core clementine
#sudo dnf install -y grub-customizer kate libdvdcss libffi-devel lsd mpg123 neofetch openssl-devel p7zip p7zip-plugins pip python3 python3-pip gparted brasero
#sudo dnf install -y mesa-libGL mesa-libGLw mesa-libGLU mesa-libGLU-devel mesa-filesystem mesa-va-drivers mesa-libEGL mesa-libglapi mesa-libGL-devel
#sudo dnf install -y rhythmbox rygel shotwell sshpass sxiv timeshift unrar unzip cowsay fortune-mod

#sudo dnf install -y rsync openssh-server openssh-clients wsdd variety virt-manager wget xclip zstd fd-find fzf gtk3 rygel dnf5 dnf5-plugins dnfdragora tlp tlp-rdw
#sudo dnf install -y libyui-mga-qt libyui-qt
#sudo dnf install -y liveusb-creator         #to create a disk image
#sudo dnf install -y k3b                     #(install .md5 and .mdf)
#sudo dnf install -y AcetoneISO              #(best program to mount *.bin *.mdf *.nrg *.img *.daa *.cdi *.xbx *.b5i *.bwi)
#sudo dnf install -y ccd2iso                 #(convert *.img to *.iso)//from terminal: ccd2iso image.img image.iso
#sudo dnf install -y bchunk                  #(convert *.bin, *.cue to *iso) // terminal: bchunk image.cue image.bin image.iso
#sudo dnf install -y mplayer                 #(play videos and sounds on browser)
#sudo dnf install -y xine xine-lib libdvdcss # quicktime video and AVI
#sudo dnf install -y qt5ct

sudo dnf install -y snapper python-dnf-plugin-snapper
sudo snapper -c root create-config /
sudo btrfs subvolume list /

sudo dnf install -y 'google-roboto*' 'mozilla-fira*' fira-code-fonts

echo ""

# Check whether if the windowing system is Xorg or Wayland windowing system and set environment variables accordingly
if [[ ${XDG_SESSION_TYPE} == "wayland" ]]; then
    export MOZ_ENABLE_WAYLAND=1
    export OBS_USE_EGL=1
    echo "Running on Wayland: Enabled Wayland-specific settings."
    echo "" && sleep 1

elif [[ ${XDG_SESSION_TYPE} == "x11" ]]; then
    export MOZ_ENABLE_WAYLAND=0
    export OBS_USE_EGL=0
    echo "Running on Xorg: Disabled Wayland-specific settings."
    echo "" && sleep 1
else
    echo "Unknown windowing system: ${XDG_SESSION_TYPE}. No changes made."
    echo "" && sleep 1
fi

# Check if qt5ct is installed and set QT/Kvantum theme settings
if command -v qt5ct &>/dev/null; then
    export QT_QPA_PLATFORM="xcb"
    export QT_QPA_PLATFORMTHEME="qt5ct"
    echo "qt5ct is installed: QT settings applied."
    echo "" && sleep 1
else
    echo "qt5ct is not installed: QT settings not applied."
    echo "You can install qt5ct with: sudo dnf install qt5ct"
    echo "" && sleep 1
fi

## Networking packages
sudo dnf -y install iptables iptables-services nftables

## System utilities
sudo dnf -y install bash-completion busybox crontabs ca-certificates curl dnf-plugins-core dnf-utils gnupg2 nano screen ufw unzip vim wget zip

## Programming and development tools
sudo dnf -y install autoconf automake bash-completion git libtool make pkg-config python3 python3-pip

## Additional libraries and dependencies
sudo dnf -y install bc binutils haveged jq libsodium libsodium-devel PackageKit qrencode socat

## Miscellaneous
sudo dnf -y install dialog htop net-tools

echo ""
echo "wsdd implements a Web Service Discovery host daemon. This enables (Samba) hosts, like your local NAS device, to be found by Web Service Discovery Clients like Windows."
echo "It also implements the client side of the discovery protocol which allows to search for Windows machines and other devices implementing WSD. This mode of operation is called discovery mode."
echo""

gum spin --spinner dot --title " Standby, traffic for the following ports, directions and addresses must be allowed" -- sleep 2

sudo firewall-cmd --add-rich-rule='rule family="ipv4" source address="239.255.255.250" port protocol="udp" port="3702" accept'
sudo firewall-cmd --add-rich-rule='rule family="ipv6" source address="ff02::c" port protocol="udp" port="3702" accept'
sudo firewall-cmd --add-rich-rule='rule family="ipv4" port protocol="udp" port="3702" accept'
sudo firewall-cmd --add-rich-rule='rule family="ipv6" port protocol="udp" port="3702" accept'
sudo firewall-cmd --add-rich-rule='rule family="ipv4" port protocol="tcp" port="5357" accept'
sudo firewall-cmd --add-rich-rule='rule family="ipv6" port protocol="tcp" port="5357" accept'

# Define the path to the wsdd service file
SERVICE_FILE="/usr/lib/systemd/system/wsdd.service"

# Define the path to the old sysconfig file
OLD_SYSCONFIG_FILE="/etc/default/wsdd"

# Define the path to the new sysconfig file
NEW_SYSCONFIG_FILE="/etc/sysconfig/wsdd"

# Check if EnvironmentFile line with old path exists in the service file
if grep -q "EnvironmentFile=$OLD_SYSCONFIG_FILE" "$SERVICE_FILE"; then
    # Comment out the old EnvironmentFile line
    sudo sed -i "s|EnvironmentFile=$OLD_SYSCONFIG_FILE|#&|" "$SERVICE_FILE"

    # Add the new EnvironmentFile line directly under the commented old line
    sudo sed -i "\|#EnvironmentFile=$OLD_SYSCONFIG_FILE|a EnvironmentFile=$NEW_SYSCONFIG_FILE" "$SERVICE_FILE"
    gum spin --spinner dot --title " Standby, editind WSDD config" -- sleep 2

    # Reload systemd to apply changes
    sudo systemctl daemon-reload

    # Restart the wsdd service

    gum spin --spinner dot --title " Standby, restarting , reloading and getting wsdd status" -- sleep 2
    sudo systemctl enable wsdd.service
    sudo systemctl restart wsdd.service
    display_message "[${GREEN}✔${NC}]  WSDD setup complete"
    # systemctl status wsdd.service

    sleep 1

    echo "EnvironmentFile updated to $NEW_SYSCONFIG_FILE and service restarted."
    sleep 2
else
    # Check if EnvironmentFile line with new path exists
    if grep -q "EnvironmentFile=$NEW_SYSCONFIG_FILE" "$SERVICE_FILE"; then
        echo "No changes needed. EnvironmentFile is already updated."
    else
        # Add the new EnvironmentFile line at the end of the [Service] section
        echo -e "\nEnvironmentFile=$NEW_SYSCONFIG_FILE" | sudo tee -a "$SERVICE_FILE" >/dev/null
        gum spin --spinner dot --title " Standby, editind WSDD config" -- sleep 2

        # Reload systemd to apply changes
        sudo systemctl daemon-reload

        # Restart the wsdd service
        gum spin --spinner dot --title " Standby, restarting , reloading and getting wsdd status" -- sleep 2
        sudo systemctl enable wsdd.service
        sudo systemctl restart wsdd.service
        display_message "[${GREEN}✔${NC}]  WSDD setup complete"
        # systemctl status wsdd.service

        sleep 1

        echo "EnvironmentFile added with path $NEW_SYSCONFIG_FILE and service restarted."
        sleep 2
    fi
fi

# Install virtualization group
sudo dnf install -y @virtualization

# Enable libvirtd service
sudo systemctl enable libvirtd

# Add user to libvirt group
sudo usermod -a -G libvirt ${USER}

# Install fedora preload
display_message "[${GREEN}✔${NC}]  Install fedora preload"
sudo dnf copr enable atim/preload -y && sudo dnf install preload -y
display_message "[${GREEN}✔${NC}]  Enable fedora preload service"
sudo systemctl enable --now preload.service
gum spin --spinner dot --title "Standby.." -- sleep 1.5

# Install some fonts
display_message "[${GREEN}✔${NC}]  Installing some fonts"
sudo dnf install -y fontawesome-fonts powerline-fonts
sudo mkdir -p ~/.local/share/fonts
cd ~/.local/share/fonts && curl -fLO https://github.com/ryanoasis/nerd-fonts/raw/HEAD/patched-fonts/DroidSansMono/DroidSansMNerdFont-Regular.otf
wget https://github.com/tolgaerok/fonts-tolga/raw/main/WPS-FONTS.zip
unzip WPS-FONTS.zip -d /usr/share/fonts

zip_file="Apple-Fonts-San-Francisco-New-York-master.zip"

# Check if the ZIP file exists
if [ -f "$zip_file" ]; then
    # Remove existing ZIP file
    sudo rm -f "$zip_file"
    echo "Existing ZIP file removed."
fi

# Download the ZIP file
curl -LJO https://github.com/tolgaerok/Apple-Fonts-San-Francisco-New-York/archive/refs/heads/master.zip

# Check if the download was successful
if [ -f "$zip_file" ]; then
    # Unzip the contents to the system-wide fonts directory
    sudo unzip -o "$zip_file" -d /usr/share/fonts/

    # Update font cache
    sudo fc-cache -f -v

    # Remove the ZIP file
    rm "$zip_file"

    display_message "[${GREEN}✔${NC}] Apple fonts installed successfully."
    echo ""
    gum spin --spinner dot --title "Re-thinking... 1 sec" -- sleep 2
else
    display_message "[${RED}✘${NC}] Download failed. Please check the URL and try again."
    gum spin --spinner dot --title "Stand-by..." -- sleep 2
fi

# Reloading Font
sudo fc-cache -vf

# Removing zip Files
rm ./WPS-FONTS.zip
sudo fc-cache -f -v

sudo dnf install fontconfig-font-replacements -y --skip-broken && sudo dnf install fontconfig-enhanced-defaults -y --skip-broken

sudo bash -c "$(curl -fsSL https://raw.githubusercontent.com/tolgaerok/tolga-scripts/main/Fedora39/San-Francisco-family/San-Francisco-family.sh)"

sudo dnf install ibm-plex-mono-fonts ibm-plex-sans-fonts ibm-plex-serif-fonts \
    redhat-display-fonts redhat-text-fonts \
    lato-fonts \
    jetbrains-mono-fonts \
    fira-code-fonts mozilla-fira-mono-fonts mozilla-fira-sans-fonts mozilla-zilla-slab-fonts \
    adobe-source-serif-pro-fonts adobe-source-sans-pro-fonts \
    intel-clear-sans-fonts intel-one-mono-fonts

sudo dnf install curl cabextract xorg-x11-font-utils fontconfig
sudo rpm -i https://downloads.sourceforge.net/project/mscorefonts2/rpms/msttcore-fonts-installer-2.6-1.noarch.rpm

package_url="https://kojipkgs.fedoraproject.org//packages/btrfs-assistant/1.8/2.fc39/x86_64/btrfs-assistant-1.8-2.fc39.x86_64.rpm"
package_name=$(echo "$package_url" | awk -F'/' '{print $NF}')

# Check if the package is installed
if rpm -q "$package_name" >/dev/null; then
    display_message "[${RED}✘${NC}] $package_name is already installed."
    gum spin --spinner dot --title "Standby.." -- sleep 1
else
    # Package is not installed, so proceed with the installation
    display_message "[${GREEN}✔${NC}]  $package_name is not installed. Installing..."
    sudo dnf install -y "$package_url"
    if [ $? -eq 0 ]; then
        display_message "[${GREEN}✔${NC}]  $package_name has been successfully installed."
        gum spin --spinner dot --title "Standby.." -- sleep 1
    else
        display_message "[${RED}✘${NC}] Failed to install $package_name."
        gum spin --spinner dot --title "Standby.." -- sleep 1
    fi
fi

# Install google
display_message "[${GREEN}✔${NC}]  Installing Google chrome"
if command -v google-chrome &>/dev/null; then
    display_message "[${RED}✘${NC}] Google Chrome is already installed. Skipping installation."
    gum spin --spinner dot --title "Standby.." -- sleep 1
else
    # Install Google Chrome
    display_message "[${GREEN}✔${NC}]  Installing Google Chrome browser..."
    wget https://dl.google.com/linux/direct/google-chrome-stable_current_x86_64.rpm
    sudo dnf install -y ./google-chrome-stable_current_x86_64.rpm
    rm -f google-chrome-stable_current_x86_64.rpm
fi

# Download and install TeamViewer
display_message "[${GREEN}✔${NC}]  Downloading && install TeamViewer"
teamviewer_url="https://download.teamviewer.com/download/linux/teamviewer.x86_64.rpm?utm_source=google&utm_medium=cpc&utm_campaign=au%7Cb%7Cpr%7C22%7Cjun%7Ctv-core-download-sn%7Cfree%7Ct0%7C0&utm_content=Download&utm_term=teamviewer+download"
teamviewer_location="/tmp/teamviewer.x86_64.rpm"
download_and_install "$teamviewer_url" "$teamviewer_location" "teamviewer"

# Download and install Visual Studio Code
display_message "[${GREEN}✔${NC}]  Downloading && install Vscode"
vscode_url="https://code.visualstudio.com/sha/download?build=stable&os=linux-rpm-x64"
vscode_location="/tmp/vscode.rpm"
download_and_install "$vscode_url" "$vscode_location" "code"

if test "$(id -u)" -gt "0" && test -d "$HOME"; then
    # Add default settings when there are no settings
    if test ! -e "$HOME"/.config/Code/User/settings.json; then
        mkdir -p "$HOME"/.config/Code/User
        cp -f /etc/skel/.config/Code/User/settings.json "$HOME"/.config/Code/User/settings.json
    fi
fi

# Install extra package
display_message "[${GREEN}✔${NC}]  Installing Extra RPM packages"
sudo dnf groupupdate -y sound-and-video
sudo dnf group upgrade -y --with-optional Multimedia
sudo dnf groupupdate -y sound-and-video --allowerasing --skip-broken
sudo dnf groupupdate multimedia sound-and-video

# Update GRUB configuration
sudo grub2-mkconfig -o /boot/grub2/grub.cfg
sudo grub2-mkconfig -o /boot/efi/EFI/fedora/grub.cfg
display_message "[${GREEN}✔${NC}]  Create extra needed directories"

# Get the username of the invoking user
user=$(logname)

# Directories to create
directories=(
    "/home/$user/.config/autostart"
    "/home/$user/.config/environment.d"
    "/home/$user/.config/systemd/user"
    "/home/$user/.local/bin"
    "/home/$user/.local/share/applications"
    "/home/$user/.local/share/fonts"
    "/home/$user/.local/share/icons"
    "/home/$user/.local/share/themes"
    "/home/$user/.ssh"
    "/home/$user/.zshrc.d"
    "/home/$user/Applications"
    "/home/$user/src"
)

# Create directories for the invoking user
for dir in "${directories[@]}"; do
    mkdir -p "$dir"
    gum spin --spinner dot --title "[✔]  Creating: $dir" -- sleep 1
    sleep 0.5
    chown "$user:$user" "$dir"
done

# Set SSH folder permissions
chmod 700 "/home/$user/.ssh"

display_message "[${GREEN}✔${NC}]  Extra hidden dirs created"
gum spin --spinner dot --title "Stand-by..." -- sleep 2

display_message "${YELLOW}[*]${NC} Configure shutdown of units and services to 10s .."
sleep 1

# Configure default timeout to stop user units
sudo mkdir -p /etc/systemd/user.conf.d
sudo tee /etc/systemd/user.conf.d/default-timeout.conf <<EOF
[Manager]
DefaultTimeoutStopSec=3s
EOF

sudo udevadm control --reload-rules && sudo udevadm trigger && sudo sysctl --system && sudo sysctl -p
sudo mount -a && sudo systemctl daemon-reload

display_message "${GREEN}[✔]${NC} Shutdown speed configured"
gum spin --spinner dot --title "Stand-by..." -- sleep 2

allowedTCPPorts=(
    21    # FTP
    53    # DNS
    80    # HTTP
    443   # HTTPS
    143   # IMAP
    389   # LDAP
    139   # Samba
    445   # Samba
    25    # SMTP
    22    # SSH
    5432  # PostgreSQL
    3306  # MySQL/MariaDB
    3307  # MySQL/MariaDB
    111   # NFS
    2049  # NFS
    2375  # Docker
    22000 # Syncthing
    9091  # Transmission
    60450 # Transmission
    80    # Gnomecast server
    8010  # Gnomecast server
    8888  # Gnomecast server
    5357  # wsdd: Samba
    1714  # Open KDE Connect
    1764  # Open KDE Connect
    8200  # Teamviewer
)

# Define allowed UDP ports
allowedUDPPorts=(
    53    # DNS
    137   # NetBIOS Name Service
    138   # NetBIOS Datagram Service
    3702  # wsdd: Samba
    5353  # Device discovery
    21027 # Syncthing
    22000 # Syncthing
    8200  # Teamviewer
    1714  # Open KDE Connect
    1764  # Open KDE Connect
)
display_message "[${GREEN}✔${NC}] Setting up firewall ports (OLD NixOs settings)"
gum spin --spinner dot --title "Stand-by..." -- sleep 2

# Add allowed TCP ports
for port in "${allowedTCPPorts[@]}"; do
    sudo firewall-cmd --permanent --add-port="$port/tcp"
    gum spin --spinner dot --title "Setting up TCPorts:  $port" -- sleep 0.5
done

# Add allowed UDP ports
for port in "${allowedUDPPorts[@]}"; do
    sudo firewall-cmd --permanent --add-port="$port/udp"
    gum spin --spinner dot --title "Setting up UDPPorts:  $port" -- sleep 0.5
done

# Add extra command for NetBIOS name resolution traffic on UDP port 137
display_message "[${GREEN}✔${NC}] Adding NetBIOS name resolution traffic on UDP port 137"
gum spin --spinner dot --title "Add extra command for NetBIOS name resolution traffic on UDP port 137" -- sleep 1.5
sudo iptables -t raw -A OUTPUT -p udp -m udp --dport 137 -j CT --helper netbios-ns

# Reload the firewall for changes to take effect
sudo firewall-cmd --reload
gum spin --spinner dot --title "Reloading firewall" -- sleep 0.5

display_message "[${GREEN}✔${NC}] Firewall rules applied successfully."
gum spin --spinner dot --title "Reloading MainMenu" -- sleep 1.5

# Check for Intel chipset
if lspci | grep -i intel &>/dev/null; then
    display_message "Intel chipset detected. Installing Intel video acceleration..."

    sudo dnf install -y intel-media-driver

    # Install video acceleration packages
    sudo dnf install libva libva-utils xorg-x11-drv-intel -y

    display_message "[${GREEN}✔${NC}]  H/W Video Acceleration for Intel chipset installed successfully."
    gum spin --spinner dot --title "Stand-by..." -- sleep 2
else
    display_message "No Intel chipset found. Skipping H/W Video Acceleration installation."
    gum spin --spinner dot --title "Stand-by..." -- sleep 2
fi

# Colors for output
YELLOW="\033[1;33m"
BLUE="\033[0;34m"
RED="\033[0;31m"
NC="\033[0m" # No Color

# Function to apply CAKE qdisc to an interface
apply_cake_qdisc() {
    local interface=$1
    echo -e "${BLUE}Configuring interface ${interface}...${NC}"
    if sudo tc qdisc replace dev "$interface" root cake bandwidth 1Gbit; then
        echo -e "${YELLOW}Successfully configured CAKE qdisc on ${interface}.${NC}"
    else
        echo -e "${RED}Failed to configure CAKE qdisc on ${interface}.${NC}"
    fi
}

# Get a list of all network interfaces (excluding irrelevant ones)
interfaces=$(ip link show | awk -F: '$0 !~ "lo|virbr|docker|^[^0-9]"{print $2;getline}')

# Apply CAKE qdisc to each interface
for interface in $interfaces; do
    apply_cake_qdisc "$interface"
done

# Display the configured qdiscs
for interface in $interfaces; do
    echo -e "${BLUE}Qdisc configuration for ${interface}:${NC}"
    sudo tc qdisc show dev "$interface"
done

# Add net.core.default_qdisc = cake to /etc/sysctl.conf if it doesn't exist
sysctl_conf="/etc/sysctl.conf"
if grep -qxF 'net.core.default_qdisc = cake' "$sysctl_conf"; then
    echo -e "${YELLOW}net.core.default_qdisc is already set to cake in ${sysctl_conf}.${NC}"
else
    echo 'net.core.default_qdisc = cake' | sudo tee -a "$sysctl_conf"
    echo -e "${YELLOW}Added net.core.default_qdisc = cake to ${sysctl_conf}.${NC}"
fi

# Apply the sysctl settings
if sudo sysctl -p; then
    echo -e "${YELLOW}sysctl settings applied successfully.${NC}"
else
    echo -e "${RED}Failed to apply sysctl settings.${NC}"
fi

echo -e "${YELLOW}Traffic control settings applied successfully.${NC}"
echo -e "${YELLOW}net.core.default_qdisc set to cake in /etc/sysctl.conf.${NC}"

# Verification Step
for interface in $interfaces; do
    echo -e "${BLUE}Verifying qdisc configuration for ${interface}:${NC}"
    qdisc_output=$(sudo tc qdisc show dev "$interface")
    if echo "$qdisc_output" | grep -q 'cake'; then
        echo -e "${YELLOW}CAKE qdisc is active on ${interface}.${NC}"
    else
        echo -e "${RED}CAKE qdisc is NOT active on ${interface}.${NC}"
    fi
    echo "$qdisc_output"
done

# Function to detect USB version of a port
detect_usb_version() {
    local usb_version=$(lsusb -v -d "$1" 2>/dev/null | grep "bcdUSB" | awk '{print $2}')
    if [[ "$usb_version" == "3.00" ]]; then
        echo "USB 3.0"
    elif [[ "$usb_version" == "2.00" ]]; then
        echo "USB 2.0"
    elif [[ "$usb_version" == "1.10" || "$usb_version" == "1.00" ]]; then
        echo "USB 1.x"
    else
        echo "Unknown USB version"
    fi
}

# Main function
main-usb() {
    echo "Detecting USB versions:"
    echo "-----------------------"
    lsusb | while read -r line; do
        usb_vendor=$(echo "$line" | awk '{print $6}')
        usb_product=$(echo "$line" | awk '{print $7}')
        usb_version=$(detect_usb_version "$usb_vendor:$usb_product")
        echo "USB device: $usb_vendor:$usb_product, Version: $usb_version"
    done
}

# Run the main function
main-usb

# Function to detect the package manager
detect_package_manager() {
    for _PM in apt-get dnf eopkg pacman pkgtool ppm swupd yum xbps-install zypper unknown; do
        if command -v "$_PM" &>/dev/null; then
            if [ "$_PM" = "apt-get" ] && ! command -v dpkg &>/dev/null && command -v rpm &>/dev/null; then
                _PM=apt-rpm
            fi
            echo "$_PM"
            break
        fi
    done
}

# Main function
main() {
    package_manager=$(detect_package_manager)
    echo "Package manager is: $package_manager"
}

# Run the main function
main

# Define the template directory
TEMPLATE_DIR="$HOME/Templates"
# Create the template directory if it doesn't exist
mkdir -p "$TEMPLATE_DIR"
# Create blank text document
touch "$TEMPLATE_DIR/Document.txt"
# Create blank Word document
touch "$TEMPLATE_DIR/Document.docx"
# Create blank Excel spreadsheet
touch "$TEMPLATE_DIR/Spreadsheet.xlsx"
# Create blank configuration file
touch "$TEMPLATE_DIR/Config.conf"
# Create blank markdown file
touch "$TEMPLATE_DIR/Document.md"
# Create blank shell script
touch "$TEMPLATE_DIR/Script.sh"
# Create blank Python script
touch "$TEMPLATE_DIR/Script.py"
# Create blank JSON file
touch "$TEMPLATE_DIR/Document.json"
# Create blank YAML file
touch "$TEMPLATE_DIR/Document.yaml"
# Create blank HTML file
touch "$TEMPLATE_DIR/Document.html"
# Create blank CSS file
touch "$TEMPLATE_DIR/Document.css"
# Create blank JavaScript file
touch "$TEMPLATE_DIR/Document.js"
# Print a message indicating completion
echo "Template documents created in $TEMPLATE_DIR"
echo "" && sleep 1

# Get a list of all mounted Btrfs volumes without headers and special characters
btrfs_mounts=$(findmnt -nt btrfs -o TARGET --noheadings | sed 's/└─//g')

# Iterate through each Btrfs mount point and defragment it
for mount_point in $btrfs_mounts; do
    echo "Defragmenting $mount_point"
    sudo btrfs filesystem defragment -r "$mount_point"
done

echo "Defragmentation complete for all Btrfs volumes."
sleep 2

sudo sysctl -p && sudo mount -a && sudo systemctl daemon-reload && sudo udevadm control --reload-rules && sudo udevadm trigger && sudo sysctl --system

sudo dnf install https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
sudo dnf config-manager --enable fedora-cisco-openh264
sudo dnf update @core
sudo dnf install akmod-nvidia             # rhel/centos users can use kmod-nvidia instead
sudo dnf install xorg-x11-drv-nvidia-cuda #optional for cuda/nvdec/nvenc support
sudo systemctl enable --now akmods --force && sudo dracut --force && echo && echo "Force akmods and Dracut on NVIDIA done" && echo ""

# Check if the Nvidia is loaded
if lsmod | grep -wq "nvidia"; then
    echo -e "\e[1;32m[✔]\e[0m Nvidia module is loaded."

    # Check if Firefox Flatpak is installed
    if flatpak list | grep -q org.mozilla.firefox; then
        echo -e "\e[1;32m[✔]\e[0m Enabling VAAPI in Firefox Flatpak..."
        flatpak override \
            --user \
            --filesystem=host-os \
            --env=LIBVA_DRIVER_NAME=nvidia \
            --env=LIBVA_DRIVERS_PATH=/run/host/usr/lib64/dri \
            --env=LIBVA_MESSAGING_LEVEL=1 \
            --env=MOZ_DISABLE_RDD_SANDBOX=1 \
            --env=NVD_BACKEND=direct \
            --env=MOZ_ENABLE_WAYLAND=1 \
            org.mozilla.firefox
        echo -e "\e[1;32m[✔]\e[0m VAAPI has been enabled in Firefox Flatpak."
    else
        echo -e "\e[1;33m[!]\e[0m Firefox Flatpak is not installed. Enabling VAAPI in local Firefox installation..."

        # environment variables for VAAPI
        export LIBVA_DRIVER_NAME=nvidia
        export LIBVA_DRIVERS_PATH=/usr/lib64/dri
        export LIBVA_MESSAGING_LEVEL=1
        export MOZ_DISABLE_RDD_SANDBOX=1
        export NVD_BACKEND=direct
        export MOZ_ENABLE_WAYLAND=1

        # Launch Firefox with the environment variables
        echo -e "\e[1;32m[✔]\e[0m Launching local Firefox with VAAPI enabled..."
        firefox &
    fi
else
    echo -e "\e[1;31m[✘]\e[0m Nvidia module is not loaded. Please ensure you have Nvidia drivers installed."
fi

# Check if Nvidia GPU
if lspci | grep -i nvidia >/dev/null; then
    echo "Nvidia GPU detected."
    sudo chmod 1777 /var/tmp
    sudo dnf install libva-nvidia-driver nvidia-persistenced
    systemctl enable nvidia-persistenced.service

    # Check if Nvidia driver is installed
    if lsmod | grep -wq nvidia; then
        echo "Nvidia driver is installed."

        # Append Nvidia options to /etc/modprobe.d/nvidia.conf
        echo "Appending Nvidia options to /etc/modprobe.d/nvidia.conf..."
        echo "options nvidia NVreg_UsePageAttributeTable=1
options nvidia NVreg_EnablePCIeGen3=1
options nvidia NVreg_RegistryDwords=RMI2cSpeed=100
options nvidia NVreg_PreserveVideoMemoryAllocations=1
options nvidia NVreg_TemporaryFilePath=/var/tmp
options nvidia NVreg_InitializeSystemMemoryAllocations=0
options nvidia NVreg_EnableStreamMemOPs=1
options nvidia NVreg_DynamicPowerManagement=0x02
options nvidia NVreg_RegistryDwords=__REGISTRYDWORDS
options nvidia_drm modeset=1 fbdev=1" | sudo tee -a /etc/modprobe.d/nvidia.conf

        # Update initramfs
        echo "Updating initramfs..."
        sudo dracut --force

        echo "Changes applied. Please reboot your system to take effect."
    else
        echo "Nvidia driver is not installed. Please install the Nvidia driver first."
    fi
else
    echo "No Nvidia GPU detected."
fi

# Add Flathub remote repository if it doesn't already exist
flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo

# Install specified Flatpak applications from Flathub
# flatpak install flathub com.wps.Office -y
flatpak install -y flathub com.mattjakeman.ExtensionManager com.sindresorhus.Caprine com.github.tchx84.Flatseal io.github.flattool.Warehouse org.flameshot.Flameshot

sudo journalctl --rotate
sudo journalctl --vacuum-time=1s

sleep 2
clear

echo '
#!/bin/bash
# Tolga Erok
# Aug 6 2024

# Handle X11 display settings
handle_x11() {
  export DISPLAY=:0
  if [ "$XDG_CURRENT_DESKTOP" = "GNOME" ]; then
    # X11 on GNOME
    xrandr --output HDMI-0 --auto --primary
    xrandr --output DP-0 --auto --right-of HDMI-0

  elif [ "$XDG_CURRENT_DESKTOP" = "KDE" ]; then
    # X11 on KDE
    xrandr --output HDMI-0 --auto --primary
    xrandr --output DP-0 --auto --right-of HDMI-0
  fi
}

# Handle Wayland display settings
handle_wayland() {
  if [ "$XDG_CURRENT_DESKTOP" = "GNOME" ]; then
    # GNOME on Wayland
    gsettings set org.gnome.desktop.interface enable-animations false
    sleep 0.1
    gsettings set org.gnome.desktop.interface enable-animations true
    # Restart GNOME Shell
    gnome-shell --replace &

  elif [ "$XDG_CURRENT_DESKTOP" = "KDE" ]; then
    # KDE on Wayland
    kscreen-doctor output.HDMI-0.enable
    kscreen-doctor output.HDMI-0.position.0,0
    kscreen-doctor output.HDMI-0.primary
    kscreen-doctor output.DP-0.enable
    kscreen-doctor output.DP-0.position.1920,0
  fi
}   

# Main execution
if [ "$XDG_SESSION_TYPE" = "x11" ]; then
  handle_x11
elif [ "$XDG_SESSION_TYPE" = "wayland" ]; then
  handle_wayland
fi
' | sudo tee /usr/local/bin/wake_monitors.sh >/dev/null && sudo chmod +x /usr/local/bin/wake_monitors.sh

# get the username
user=$(logname)

# Use the captured username in the service file
echo "[Unit]
Description=Wake monitor(s) after login or suspend
After=graphical.target suspend.target

[Service]
Type=oneshot
ExecStart=/usr/local/bin/wake_monitors.sh
User=$user
Environment=\"DISPLAY=:0\"
Environment=\"XDG_SESSION_TYPE=wayland\"
Environment=\"XDG_CURRENT_DESKTOP=GNOME\"

[Install]
WantedBy=graphical.target suspend.target
" | sudo tee /etc/systemd/system/wake_monitors.service >/dev/null

sudo systemctl daemon-reload
sudo systemctl enable wake_monitors.service
sudo systemctl start wake_monitors.service

sudo journalctl --rotate
sudo journalctl --vacuum-time=1s

gsettings set org.gnome.mutter experimental-features "['scale-monitor-framebuffer']"
sudo dnf update gnome-shell mutter

# Remove unnecessary dependencies
sudo dnf clean all
sudo dnf autoremove -y

# Sort the lists of installed packages and packages to keep
display_message "[${GREEN}✔${NC}]  Sorting out list of installed packages and packages to keep..."
comm -23 <(sudo dnf repoquery --installonly --latest-limit=-1 -q | sort) <(sudo dnf list installed | awk '{print $1}' | sort) >/tmp/orphaned-pkgs

if [ -s /tmp/orphaned-pkgs ]; then
    sudo dnf remove $(cat /tmp/orphaned-pkgs) -y --skip-broken
else
    display_message "[${GREEN}✔${NC}]  Congratulations, no orphaned packages found."
fi

# Clean up temporary files
display_message "[${GREEN}✔${NC}]  Clean up temporary files ..."
sudo rm -rf /tmp/orphaned-pkgs

display_message "[${GREEN}✔${NC}]  Trimming all mount points on SSD"
sudo fstrim -av

echo -e "\e[1;32m[✔]\e[0m Restarting kernel tweaks...\n"
gum spin --spinner dot --title "Stand-by..." -- sleep 2
sudo sysctl -p

# Cleanup
display_message "[${GREEN}✔${NC}]  Cleaning up downloaded /tmp folder"
rm "$download_location"
gum spin --spinner dot --title "Stand-by..." -- sleep 1

display_message "[${GREEN}✔${NC}]  Cleanup complete, ENJOY!"
gum spin --spinner dot --title "Stand-by..." -- sleep 1

export CHROME_ENABLE_WAYLAND=1
export MOZ_ENABLE_WAYLAND=1

sudo sh -c 'echo 176 > /proc/sys/kernel/sysrq'

echo "All specified Flatpak applications have been installed successfully."
echo "All packages installed successfully."

nmcli -t -f NAME connection show
nmcli -t -f NAME,UUID,TYPE connection show

display_message "[${GREEN}✔${NC}]  Standby, loading main script"
gum spin --spinner dot --title "Stand-by..." -- sleep 1
sudo bash -c "$(curl -fsSL https://raw.githubusercontent.com/tolgaerok/tolga-scripts/main/Fedora39/TolgaFedora39.sh)"
