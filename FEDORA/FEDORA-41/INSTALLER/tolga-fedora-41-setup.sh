#!/bin/bash

# Tolga Erok
# My personal Fedora 41 KDE tweaker
# 18/2/2025

clear

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

# Check if the script is run as root
if [ "$EUID" -ne 0 ]; then
    echo "Please run this script as root or using sudo."
    exit 1
fi

# Function to display messages
display_message() {
    clear
    echo -e "\n                Tolga's Personal Fedora 41 setup script\n"
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

RPMFUSION_URLS=(
    "https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm"
    "https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm"
)
sudo dnf install -y "${RPMFUSION_URLS[@]}"

sudo dnf install gstreamer1-plugins-bad-freeworld gstreamer1-libav

# Install DNF5 and its plugins
sudo dnf install -y dnf5
sudo dnf5 install -y dnf5 dnf5-plugins

# Update the system with DNF5 and refresh the cache
sudo dnf5 update -y && sudo dnf5 makecache

# Install DNF5 and its plugins
sudo dnf install -y dnf5
sudo dnf5 install -y dnf5 dnf5-plugins

# Update the system with DNF5 and refresh the cache
sudo dnf5 update -y && sudo dnf5 makecache
sudo dnf update
sudo dnf upgrade --refresh
sudo dnf install dnf-plugins-core -y
sudo dnf install -y fedora-workstation-repositories

sudo dnf config-manager --set-enabled rpmfusion-nonfree-nvidia-driver

sudo dnf install akmod-nvidia \
    akmods \
    openssl \
    xorg-x11-drv-nvidia-cuda xorg-x11-drv-nvidia-cuda-libs \
    xorg-x11-drv-nvidia-power \
    nvidia-settings \
    nvidia-vaapi-driver libva-utils vdpauinfo

sudo grubby --update-kernel=ALL --args='nvidia-drm.modeset=1'

cat <<EOF | sudo tee /etc/dracut.conf.d/nvidia.conf
add_drivers+=" nvidia nvidia_modeset nvidia_uvm nvidia_drm "
install_items+=" /etc/modprobe.d/nvidia.conf "
EOF

cat <<EOF | sudo tee /etc/modprobe.d/nvidia.conf
options nvidia_drm modeset=1
EOF

# Blacklist some modules
echo "blacklist nouveau" >>/etc/modprobe.d/blacklist.conf
echo "blacklist iTCO_wdt" >>/etc/modprobe.d/blacklist.conf

# KMS stands for "Kernel Mode Setting" which is the opposite of "Userland Mode Setting". This feature allows to set the screen resolution
# on the kernel side once (at boot), instead of after login from the display manager.
sudo sed -i '/GRUB_CMDLINE_LINUX/ s/"$/ rd.driver.blacklist=nouveau modprobe.blacklist=nouveau nvidia-drm.modeset=1"/' /etc/default/grub

while pgrep akmod; do
    sleep 5
done

sudo dracut --regenerate-all --force

[ ${UID} -eq 0 ] && read -p "Username for this script: " user && export user || export user="$USER"

echo '[charm]
name=Charm
baseurl=https://repo.charm.sh/yum/
enabled=1
gpgcheck=1
gpgkey=https://repo.charm.sh/yum/gpg.key' | sudo tee /etc/yum.repos.d/charm.repo

sudo yum install gum -y

# Function to display messages
display_message() {
    clear
    echo -e "\n                  Tolga's SAMBA & WSDD setup script\n"
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

# Template
# display_message "[${GREEN}✔${NC}]
# display_message "[${RED}✘${NC}]

## System utilities
sudo dnf -y install bash-completion busybox crontabs ca-certificates curl dnf-plugins-core dnf-utils gnupg2 nano screen ufw unzip vim wget zip

display_message "[${GREEN}✔${NC}]  Installing SAMBA and dependencies"

# Install Samba and its dependencies
sudo dnf install samba samba-client samba-common cifs-utils samba-usershares -y

# Enable and start SMB and NMB services
display_message "[${GREEN}✔${NC}]  SMB && NMB services started"
sudo systemctl enable smb.service nmb.service
sudo systemctl start smb.service nmb.service

# Restart SMB and NMB services (optional)
sudo systemctl restart smb.service nmb.service

# Configure the firewall
display_message "[${GREEN}✔${NC}]  Firewall Configured"
sudo firewall-cmd --add-service=samba --permanent
sudo firewall-cmd --add-service=samba
sudo firewall-cmd --runtime-to-permanent
sudo firewall-cmd --reload

# Set SELinux booleans
display_message "[${GREEN}✔${NC}]  SELINUX parameters set "
sudo setsebool -P samba_enable_home_dirs on
sudo setsebool -P samba_export_all_rw on
sudo setsebool -P smbd_anon_write 1

# Create samba user/group
display_message "[${GREEN}✔${NC}]  Create smb user and group"
read -r -p "Set-up samba user & group's
" -t 2 -n 1 -s

# Prompt for the desired username for samba
read -p $'\n'"Enter the USERNAME to add to Samba: " sambausername

# Prompt for the desired name for samba
read -p $'\n'"Enter the GROUP name to add username to Samba: " sambagroup

# Add the custom group
sudo groupadd $sambagroup

# ensures that a home directory is created for the user
sudo useradd -m $sambausername

# Add the user to the Samba user database
sudo smbpasswd -a $sambausername

# enable or activate the Samba user account for login
sudo smbpasswd -e $sambausername

# Add the user to the specified group
sudo usermod -aG $sambagroup $sambausername

read -r -p "
Continuing..." -t 1 -n 1 -s

# Configure custom samba folder
read -r -p "Create and configure custom samba folder located at /home/Fedora41
" -t 2 -n 1 -s

sudo mkdir /home/Fedora41
sudo chgrp samba /home/Fedora41
sudo chmod 770 /home/Fedora41
sudo restorecon -R /home/Fedora41

# Create the sambashares group if it doesn't exist
sudo groupadd -r sambashares

# Create the usershares directory and set permissions
sudo mkdir -p /var/lib/samba/usershares
sudo chown $username:sambashares /var/lib/samba/usershares
sudo chmod 1770 /var/lib/samba/usershares

# Restore SELinux context for the usershares directory
display_message "[${GREEN}✔${NC}]  Restore SELinux for usershares folder"
sudo restorecon -R /var/lib/samba/usershares

# Add the user to the sambashares group
display_message "[${GREEN}✔${NC}]  Adding user to usershares"
sudo gpasswd sambashares -a $username

# Add the user to the sambashares group (alternative method)
sudo usermod -aG sambashares $username

# Restart SMB and NMB services (optional)
display_message "[${GREEN}✔${NC}]  Restart SMB && NMB (samba) services"
sudo systemctl restart smb.service nmb.service

# Set up SSH Server on Host
display_message "[${GREEN}✔${NC}]  Setup SSH and start service.."
sudo systemctl enable sshd && sudo systemctl start sshd

display_message "[${GREEN}✔${NC}]  Installation completed."
gum spin --spinner dot --title "Standby.." -- sleep 3

# Check for errors during installation
if [ $? -eq 0 ]; then
    display_message "Apps installed successfully."
    gum spin --spinner dot --title "Standby.." -- sleep 2
else
    display_message "[${RED}✘${NC}] Error: Unable to install Apps."
    gum spin --spinner dot --title "Standby.." -- sleep 2
fi

display_message "[${GREEN}✔${NC}]  Setup Web Service Discovery host daemon"

echo ""
echo "wsdd implements a Web Service Discovery host daemon. This enables (Samba) hosts, like your local NAS device, to be found by Web Service Discovery Clients like Windows."
echo "It also implements the client side of the discovery protocol which allows searching for Windows machines and other devices implementing WSD. This mode of operation is called discovery mode."
echo ""

## IPTABLE && WSDD packages
sudo dnf -y install iptables iptables-services nftables
sudo dnf -y install wsdd

gum spin --spinner dot --title " Standby, traffic for the following ports, directions, and addresses must be allowed" -- sleep 2

# Configure firewall rules (make them persistent)
sudo firewall-cmd --permanent --add-rich-rule='rule family="ipv4" source address="239.255.255.250" port protocol="udp" port="3702" accept'
sudo firewall-cmd --permanent --add-rich-rule='rule family="ipv6" source address="ff02::c" port protocol="udp" port="3702" accept'
sudo firewall-cmd --permanent --add-rich-rule='rule family="ipv4" port protocol="udp" port="3702" accept'
sudo firewall-cmd --permanent --add-rich-rule='rule family="ipv6" port protocol="udp" port="3702" accept'
sudo firewall-cmd --permanent --add-rich-rule='rule family="ipv4" port protocol="tcp" port="5357" accept'
sudo firewall-cmd --permanent --add-rich-rule='rule family="ipv6" port protocol="tcp" port="5357" accept'

# Apply firewall changes
sudo firewall-cmd --reload

# Define the wsdd service file path
WSDD_SERVICE_PATH="/usr/lib/systemd/system/wsdd.service"
BACKUP_PATH="${WSDD_SERVICE_PATH}.bak"

# Backup existing wsdd.service if it exists
if [ -f "$WSDD_SERVICE_PATH" ]; then
    sudo cp "$WSDD_SERVICE_PATH" "$BACKUP_PATH"
    echo "Backup created: $BACKUP_PATH"
fi

# Create new wsdd.service
sudo tee "$WSDD_SERVICE_PATH" >/dev/null <<EOF
[Unit]
Description=Tolgas Custom (WSDD) - Web Services Dynamic Discovery host daemon
Documentation=man:wsdd(8)
After=network-online.target
Wants=network-online.target
BindsTo=smb.service

[Service]
Type=simple
ExecStart=/bin/bash -c 'iface=\$(iw dev | awk "/Interface/ {print \$2; exit}"); [ -n "\$iface" ] && exec /usr/bin/wsdd --interface "\$iface" || exit 1'
DynamicUser=yes
User=wsdd
Group=wsdd
RuntimeDirectory=wsdd
AmbientCapabilities=CAP_SYS_CHROOT
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

# Reload and enable the service
sudo systemctl daemon-reload
sudo systemctl enable --now wsdd
sudo systemctl restart wsdd
systemctl status wsdd.service --no-pager

# Old NixOS TCP & UDP port settings
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

for port in "${allowedTCPPorts[@]}"; do
    echo "Setting up TCPorts: $port"
    sudo firewall-cmd --permanent --add-port=$port/tcp
done

for port in "${allowedUDPPorts[@]}"; do
    echo "Setting up UDPPorts: $port"
    sudo firewall-cmd --permanent --add-port=$port/udp
done

echo "[${GREEN}✔${NC}] Adding NetBIOS name resolution traffic on UDP port 137"
sudo iptables -t raw -A OUTPUT -p udp -m udp --dport 137 -j CT --helper netbios-ns

# Reload the firewall for changes to take effect
sudo firewall-cmd --reload
gum spin --spinner dot --title "Reloading firewall" -- sleep 1.5

display_message "[${GREEN}✔${NC}] Firewall rules applied successfully, reloading system services."
gum spin --spinner dot --title "Reloading all services" -- sleep 1.5

# Start Samba manually
sudo systemctl start smb nmb wsdd

# Configure Samba to start automatically on each boot and immediately start the service
sudo systemctl enable --now smb nmb wsdd

# Check whether Samba is running
sudo systemctl --no-pager status smb nmb wsdd

# Restart wsdd and Samba
sudo systemctl restart wsdd smb nmb

# Enable and start the services
sudo systemctl enable smb.service nmb.service wsdd.service
sudo systemctl start smb.service nmb.service wsdd.service

# Apply sysctl changes
sudo udevadm control --reload-rules
sudo udevadm trigger
sudo sysctl --system
sudo sysctl -p

sleep 1.5

display_message "[${GREEN}✔${NC}] Seek NETWORKED netbios names"
gum spin --spinner dot --title "Stand-by ..." -- sleep 1.5

workgroup="WORKGROUP"

BRIGHT_BLUE='\033[1;34m'
BRIGHT_GREEN='\033[1;32m'
BRIGHT_YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${BRIGHT_BLUE}Querying NetBIOS names for:${NC} ${BRIGHT_GREEN}$workgroup${NC}"

# Perform NetBIOS name lookup for the specified workgroup and variations of case's
for name in "$workgroup" "samba" "Samba" "SAMBA" "WORKGROUP" "workgroup"; do
    echo -e "${BRIGHT_YELLOW}NetBIOS Name:${NC} ${BRIGHT_GREEN}$name${NC}"
    nmblookup -S "$name"
    echo "----------------------------------------"
done

echo -e "${BRIGHT_BLUE}Script completed.${NC}"
echo ""

sleep 2

display_message "[${GREEN}✔${NC}] Seek which pc's are acting as SERVERS"
gum spin --spinner dot --title "Stand-by ..." -- sleep 1.5

nmblookup -S '*'

sudo systemctl enable smb.service nmb.service && sudo systemctl start smb.service nmb.service
flatpak install flathub org.gimp.GIMP
sudo dnf install variety lolcat fortune-m*

# Metadata
# ----------------------------------------------------------------------------
AUTHOR="Tolga Erok"
VERSION="1"
DATE_CREATED="22/12/2024"
# Configuration to tweak overall system performance for wine/proton or workstation
# ----------------------------------------------------------------------------------
# limits
SOFT_LIMIT=1024
HARD_LIMIT=1048576
# Check and create files if they not exist
ensure_file_exists() {
    local file_path="$1"
    if [[ ! -f "$file_path" ]]; then
        echo "$file_path does not exist. Creating..."
        sudo touch "$file_path"
    fi
}
# Update systemd configuration
update_systemd_config() {
    local config_file="$1"
    local pattern="DefaultLimitNOFILE=${SOFT_LIMIT}:${HARD_LIMIT}"
    if grep -q "^DefaultLimitNOFILE=" "$config_file"; then
        echo "Found existing DefaultLimitNOFILE entry in $config_file. Updating..."
        sudo sed -i "s/^DefaultLimitNOFILE=.*/$pattern/" "$config_file"
    else
        echo "Adding DefaultLimitNOFILE entry to $config_file..."
        echo "$pattern" | sudo tee -a "$config_file" >/dev/null
    fi
}
# Ensure configuration files exist
echo "Ensuring systemd configuration files exist..."
ensure_file_exists /etc/systemd/system.conf
ensure_file_exists /etc/systemd/user.conf

# System-wide configuration
echo "Updating system-wide limits..."
update_systemd_config /etc/systemd/system.conf
update_systemd_config /etc/systemd/user.conf

# Reload systemd
echo "Reloading systemd configuration..."
sudo systemctl daemon-reexec

# Apply limits
echo "Applying session limits..."
ulimit -Sn $SOFT_LIMIT
ulimit -Hn $HARD_LIMIT

# Verify in a clean environment
echo "Verifying configuration in a clean environment..."
env -i bash --norc --noprofile -c "
    echo -n 'Soft limit (clean env): '; ulimit -Sn
    echo -n 'Hard limit (clean env): '; ulimit -Hn
"
sudo systemctl daemon-reexec

# Display final configuration
echo "Final configuration:"
grep DefaultLimitNOFILE /etc/systemd/system.conf /etc/systemd/user.conf
echo "Tweak completed successfully!"

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

sudo systemctl enable fstrim.timer
sudo systemctl start fstrim.timer
systemctl status fstrim.timer
sudo fstrim -v /

mkdir -p ~/.local/share/fonts
ln -s ~/.local/share/fonts/ ~/.fonts
cd ~/.fonts
curl -OL https://github.com/ryanoasis/nerd-fonts/releases/latest/download/Hack.tar.xz
tar -xvf Hack.tar.xz

# Install DNF plugins core (if not already installed)
sudo dnf install -y dnf-plugins-core

# Install required dependencies
# sudo dnf install -y epel-release
sudo dnf install -y dnf-plugins-core

# Update the package manager
sudo dnf makecache -y
sudo dnf upgrade -y --refresh

sudo journalctl --rotate
sudo journalctl --vacuum-time=1s

export CHROME_ENABLE_WAYLAND=1
export MOZ_ENABLE_WAYLAND=1

# Create the systemd service file for setting the I/O scheduler
echo "[Unit]
Description=Set I/O Scheduler on boot

[Service]
Type=simple
ExecStart=/bin/bash -c 'echo mq-deadline | sudo tee /sys/block/sda/queue/scheduler; printf \"I/O Scheduler set to: \"; cat /sys/block/sda/queue/scheduler'

[Install]
WantedBy=default.target" | sudo tee /etc/systemd/system/io-scheduler.service

# Reload systemd, enable, and start the service
sudo systemctl daemon-reload
sudo systemctl enable io-scheduler.service
sudo systemctl start io-scheduler.service
sudo systemctl status io-scheduler.service

flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo

flatpak install flathub com.wps.Office
flatpak install flathub io.github.aandrew_me.ytdn
flatpak install flathub com.rtosta.zapzap

# Script to install KOrganizer, KDE PIM suite, and related packages on Fedora
echo "Starting installation of KDE PIM suite and related addons..."
echo "Updating system..."
sudo dnf update -y
echo "Installing KOrganizer and Akonadi components..."
sudo dnf install -y korganizer akonadi akonadi-server akonadi-calendar akonadi-mime akonadi-notes
echo "Installing KDE PIM suite (Kontact, KMail, KAddressBook, etc.)..."
sudo dnf install -y kontact kmail kaddressbook kalarm kjots kdepim-runtime kdepim-common kdepim-addons
echo "Installing additional KDE PIM tools and addons..."
sudo dnf install -y akonadi-import-wizard akonadi-contacts kde-telepathy
echo "Starting Akonadi server..."
akonadictl start
echo "Verifying Akonadi server status..."
akonadictl status
echo "Cleaning up..."
sudo dnf autoremove -y
echo "KDE PIM suite and related tools have been successfully installed!"
wget https://mega.nz/linux/repo/Fedora_41/x86_64/megasync-Fedora_41.x86_64.rpm && sudo dnf install "$PWD/megasync-Fedora_41.x86_64.rpm"

figlet

# Setup Git Repository and GitHub SSH Authentication

### Configuration
GITHUB_USERNAME="tolgaerok"
GIT_USER_EMAIL="kingtolga@gmail.com"
GIT_USER_NAME="Tolga Erok"
LOCAL_REPO_DIR="$HOME/MyGit"
REPO_NAME="tolga-scripts"
SSH_KEY_COMMENT="$GIT_USER_EMAIL"
SSH_KEY_PATH="$HOME/.ssh/id_rsa"

### Create Directory and Clone Repository
echo "Creating directory for Git repository..."
mkdir -p "$LOCAL_REPO_DIR"
cd "$LOCAL_REPO_DIR" || exit 1
if [ -d ".git" ]; then echo "Repository already initialized. Skipping clone..."; else
    echo "Cloning repository..."
    git clone "git@github.com:${GITHUB_USERNAME}/${REPO_NAME}.git" .
fi

### Set Global Git Configuration
echo "Configuring global Git settings..."
git config --global user.email "$GIT_USER_EMAIL"
git config --global user.name "$GIT_USER_NAME"
git config --global init.defaultBranch main
git config --global credential.helper cache
git config --global credential.helper 'cache --timeout=25000'
git config --global push.default simple

### Initialize Repository
if [ ! -d ".git" ]; then
    echo "Initializing new Git repository..."
    git init
    git branch -m main
fi

### Setup SSH Key for GitHub Authentication
if [ ! -f "$SSH_KEY_PATH" ]; then
    echo "Generating SSH key for GitHub authentication..."
    ssh-keygen -t rsa -b 4096 -C "$SSH_KEY_COMMENT" -f "$SSH_KEY_PATH" -N ""
    echo "New SSH key generated. Make sure to add it to your GitHub account."
else echo "SSH key already exists. Skipping generation."; fi

### Ensure SSH Agent is Running and Add Key
eval "$(ssh-agent -s)"
ssh-add "$SSH_KEY_PATH"

### Display SSH Key for GitHub Addition
echo "Copy the following SSH key and add it to GitHub (Settings > SSH Keys):"
cat "$SSH_KEY_PATH.pub"

### Configure Local Repository for SSH
if git remote | grep -q "origin"; then
    echo "Updating existing remote repository URL..."
    git remote set-url origin "git@github.com:${GITHUB_USERNAME}/${REPO_NAME}.git"
else
    echo "Adding new remote repository..."
    git remote add origin "git@github.com:${GITHUB_USERNAME}/${REPO_NAME}.git"
fi
git remote -v

### Test SSH Connection
echo "Testing SSH connection with GitHub..."
ssh -T git@github.com || {
    echo "SSH authentication failed. Ensure you added the key to GitHub."
    exit 1
}

# sudo smbstatus && sudo systemctl enable smb.service nmb.service && sudo systemctl start smb.service nmb.service && sudo systemctl restart smb nmb
sudo systemctl enable smb.service nmb.service && sudo systemctl start smb.service nmb.service && sudo systemctl restart smb nmb && sudo smbstatus
