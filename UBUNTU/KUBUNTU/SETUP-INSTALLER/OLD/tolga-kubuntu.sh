#!/bin/bash
# Script by Tolga Erok
# My personal Kubuntu script
# 11/2/2025

# set -e  # Exit immediately if a error occurs

sudo usermod -aG sudo $(whoami)

# run as root
if [[ $EUID -ne 0 ]]; then
    echo "This script must be run as root. Use sudo."
    exit 1
fi

echo "Starting system setup..."

#!/bin/bash

# ----------------- SPEED UP PACKAGE INSTALLATION --------------------------------- #

echo "Ensuring apt-fast is installed..."
if ! command -v apt-fast &>/dev/null; then
    echo "apt-fast not found. Installing it now..."
    sudo add-apt-repository -y ppa:apt-fast/stable
    sudo apt update
    sudo apt install -y apt-fast
fi

# ----------------- REMOVE SNAP RELATED STUFF --------------------------------- #

echo "Removing Plasma Discover Snap backend..."
sudo apt purge -y plasma-discover-backend-snap

echo "Listing installed Snap packages..."
snap list

echo "Removing all installed Snap packages..."
for snap in $(snap list | awk 'NR>1 {print $1}'); do
    echo "Removing Snap package: $snap"
    snap remove --purge "$snap" || true
done

echo "Stopping and disabling Snap services..."
sudo systemctl stop snapd.service snapd.socket snapd.seeded.service || true
sudo systemctl disable snapd.service snapd.socket snapd.seeded.service || true
sudo systemctl mask snapd.service || true

echo "Purging snapd..."
sudo apt remove --purge -y snapd || true

echo "Blocking snapd from reinstalling..."
sudo apt-mark hold snapd || true

echo "Removing Snap directories from user home directories..."
sudo find /home/* -maxdepth 1 -type d -name "snap" -exec rm -rf {} + || true

echo "Removing Snap system directories..."
sudo rm -rf /var/snap /var/lib/snapd /snap /usr/lib/snapd

echo "Finding and removing other Snap directories across the system..."
sudo find / -type d -name "snap" -not -path "/boot/*" -not -path "/proc/*" -not -path "/sys/*" -exec rm -rf {} + 2>/dev/null || true

echo "Snap removal completed."

# ----------------- INSTALL FIREFOX FROM MOZILLA PPA --------------------------------- #

echo "Adding Mozilla Team PPA for Firefox..."
sudo add-apt-repository -y ppa:mozillateam/ppa
sudo apt update

echo "Prioritizing PPA version of Firefox..."
echo 'Package: firefox*
Pin: release o=LP-PPA-mozillateam
Pin-Priority: 1001' | sudo tee /etc/apt/preferences.d/mozilla-firefox

echo "Installing Firefox..."
sudo apt-fast install -y firefox

# ----------------- INSTALL ADDITIONAL PACKAGES --------------------------------- #

echo "Installing necessary packages..."
sudo apt-fast install -y breeze-icon-theme breeze-gtk-theme fwupd

# ----------------- CLEANUP AND FINAL UPDATE --------------------------------- #

echo "Performing system cleanup..."
sudo apt autoremove -y

echo "Updating and upgrading system packages..."
sudo apt update && sudo apt upgrade -y

echo "All tasks completed successfully!"

# -----------------  SYSTEM OPTIMIZATION --------------------------------- #
echo "Installing apt-fast and preload..."
sudo add-apt-repository -y ppa:apt-fast/stable
sudo apt-get update
sudo apt-get install -y apt-fast
sudo apt-fast install -y preload
sudo systemctl enable --now preload
sudo systemctl status preload --no-pager

# -----------------  GOOGLE CHROME INSTALLATION --------------------------------- #
echo "Installing Google Chrome..."
wget -q https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
sudo apt-fast install -y ./google-chrome-stable_current_amd64.deb
rm -f google-chrome-stable_current_amd64.deb

# -----------------  FLATPAK & APPLICATIONS --------------------------------- #
echo "Installing Flatpak and essential applications..."
sudo apt-fast install -y flatpak
sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
flatpak install -y flathub com.visualstudio.code

sudo apt-fast update && sudo apt-fast install -y \
    ubuntu-restricted-extras \
    kubuntu-restricted-extras \
    synaptic \
    gdebi \
    unzip p7zip-full unrar \
    transmission \
    gparted \
    audacity \
    git make schedtool

# -----------------  DVD SUPPORT --------------------------------- #
echo "Configuring DVD playback support..."
sudo apt-fast install -y libdvd-pkg
sudo dpkg-reconfigure libdvd-pkg

# -----------------  ANANICY INSTALLATION --------------------------------- #
echo "Installing Ananicy for process management..."
git clone https://github.com/Nefelim4ag/Ananicy.git
cd Ananicy
./package.sh debian
sudo dpkg -i ./ananicy-*.deb
cd ..
rm -rf Ananicy

# -----------------  TIME CONFIGURATION --------------------------------- #
echo "Setting hardware clock to local time..."
sudo timedatectl set-local-rtc 1

# -----------------  I/O SCHEDULER SETUP --------------------------------- #
echo "Configuring I/O scheduler..."
IO_SCHEDULER_SERVICE="/etc/systemd/system/io-scheduler.service"

echo "[Unit]
Description=Set I/O Scheduler on boot for SSD/NVMe - Tolga Erok
After=multi-user.target

[Service]
Type=oneshot
ExecStart=/bin/bash -c 'echo none | tee /sys/block/sda/queue/scheduler'
RemainAfterExit=true

[Install]
WantedBy=multi-user.target" | sudo tee "$IO_SCHEDULER_SERVICE" >/dev/null

# Enable and start the service
sudo systemctl daemon-reload
sudo systemctl enable --now io-scheduler.service
sudo systemctl status io-scheduler.service --no-pager

# -----------------  DNS CONFIGURATION --------------------------------- #
echo "Updating systemd-resolved and NetworkManager DNS settings..."

# Configuration Files
CONFIG_FILE="/etc/systemd/resolved.conf"
BACKUP_FILE="/etc/systemd/resolved.conf.bak"
DNS_VALUES="DNS=1.1.1.1 9.9.9.9 8.8.8.8"
FALLBACK_DNS_VALUES="FallbackDNS=8.8.4.4"

# Backup original config
sudo cp "$CONFIG_FILE" "$BACKUP_FILE"

# Ensure settings are uncommented and updated
sudo sed -i "s/^#\?DNS=.*/$DNS_VALUES/" "$CONFIG_FILE"
sudo sed -i "s/^#\?FallbackDNS=.*/$FALLBACK_DNS_VALUES/" "$CONFIG_FILE"

# If DNS settings don't exist, add them
grep -q "^DNS=" "$CONFIG_FILE" || echo "$DNS_VALUES" | sudo tee -a "$CONFIG_FILE" >/dev/null
grep -q "^FallbackDNS=" "$CONFIG_FILE" || echo "$FALLBACK_DNS_VALUES" | sudo tee -a "$CONFIG_FILE" >/dev/null

# Ensure DNSStubListener=no is set
if grep -q "^#\?DNSStubListener=" "$CONFIG_FILE"; then
    sudo sed -i "s/^#\?DNSStubListener=.*/DNSStubListener=no/" "$CONFIG_FILE"
else
    echo "DNSStubListener=no" | sudo tee -a "$CONFIG_FILE" >/dev/null
fi

# Apply changes to systemd-resolved
sudo systemctl restart systemd-resolved
sudo resolvectl flush-caches

# --- Configure NetworkManager to prevent router DNS (DHCP) ---
ACTIVE_CONNECTION=$(nmcli -t -f NAME connection show --active | head -n 1)

if [ -n "$ACTIVE_CONNECTION" ]; then
    echo "Setting custom DNS for NetworkManager on '$ACTIVE_CONNECTION'..."
    sudo nmcli connection modify "$ACTIVE_CONNECTION" ipv4.dns "1.1.1.1 9.9.9.9 8.8.8.8"
    sudo nmcli connection modify "$ACTIVE_CONNECTION" ipv4.ignore-auto-dns yes
    sudo nmcli connection down "$ACTIVE_CONNECTION"
    sudo nmcli connection up "$ACTIVE_CONNECTION"
fi

# Display new DNS settings
sleep 2
resolvectl status

# -----------------  NVIDIA DRIVER INSTALLATION --------------------------------- #
echo "Installing NVIDIA drivers..."
sudo apt-fast install -y pkg-config libglvnd-dev dkms build-essential libegl-dev libgl-dev libgles-dev libglx-dev libopengl-dev gcc make

BLACKLIST_FILE="/etc/modprobe.d/blacklist-nouveau.conf"
NVIDIA_CONF="/etc/modprobe.d/nvidia.conf"
GRUB_FILE="/etc/default/grub"

# Configure NVIDIA settings
echo "options nvidia NVreg_EnableMSI=1
options nvidia NVreg_EnablePCIeGen3=1
options nvidia NVreg_UsePageAttributeTable=1
options nvidia NVreg_RegistryDwords=\"RMUseSwI2c=0x01;RMI2cSpeed=100\"
options nvidia NVreg_PreserveVideoMemoryAllocations=1
options nvidia NVreg_TemporaryFilePath=\"/var/tmp\"
options nvidia-drm modeset=1" | sudo tee "$NVIDIA_CONF" >/dev/null

echo "NVIDIA configuration applied."

# Update GRUB configuration
NEW_OPTIONS="quiet splash rw nvidia-drm.modeset=1 nvidia-drm.fbdev=1 rd.driver.blacklist=nouveau modprobe.blacklist=nouveau io_delay=none rootdelay=0 iomem=relaxed mitigations=off"

if grep -q "^GRUB_CMDLINE_LINUX_DEFAULT=" "$GRUB_FILE"; then
    sudo sed -i "/^GRUB_CMDLINE_LINUX_DEFAULT=/s/\"\(.*\)\"/\"\1 $NEW_OPTIONS\"/" "$GRUB_FILE"
else
    echo "GRUB_CMDLINE_LINUX_DEFAULT=\"$NEW_OPTIONS\"" | sudo tee -a "$GRUB_FILE"
fi

echo "GRUB configuration updated."

# Blacklist Nouveau driver
echo -e "blacklist nouveau\noptions nouveau modeset=0" | sudo tee "$BLACKLIST_FILE" >/dev/null

# Install NVIDIA driver
sudo add-apt-repository -y ppa:graphics-drivers/ppa
sudo apt-fast update
sudo apt-fast install -y nvidia-driver-570

nvidia-smi -q | grep "GSP Firmware"

# Final updates and reboot
sudo update-initramfs -u
sudo update-grub

sudo apt update && sudo apt full-upgrade -y

echo "Installation complete. Rebooting system in 5 seconds..."
sleep 5
sudo reboot
