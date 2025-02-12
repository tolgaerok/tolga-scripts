#!/bin/bash
# Script by Tolga Erok
# My personal Kubuntu setup script
# 11/2/2025

set -e  # Exit immediately if a command exits with a non-zero status

# Ensure script is run as root
if [[ $EUID -ne 0 ]]; then
    echo "This script must be run as root. Use sudo."
    exit 1
fi

echo "Starting system setup..."

# ----------------- SPEED UP PACKAGE INSTALLATION -----------------
if ! command -v apt-fast &>/dev/null; then
    echo "Installing apt-fast..."
    add-apt-repository -y ppa:apt-fast/stable
    apt update && apt install -y apt-fast
fi

# ----------------- REMOVE SNAP RELATED STUFF -----------------
echo "Removing Snap and its components..."
apt purge -y plasma-discover-backend-snap snapd
apt-mark hold snapd
rm -rf /var/snap /var/lib/snapd /snap /usr/lib/snapd
find /home/* -maxdepth 1 -type d -name "snap" -exec rm -rf {} + || true
systemctl disable --now snapd.service snapd.socket snapd.seeded.service || true

echo "Snap removal completed."

# ----------------- INSTALL FIREFOX FROM MOZILLA PPA -----------------
echo "Installing Firefox from Mozilla PPA..."
add-apt-repository -y ppa:mozillateam/ppa
apt update
apt-fast install -y firefox

echo "Pinning PPA version of Firefox..."
echo 'Package: firefox*\nPin: release o=LP-PPA-mozillateam\nPin-Priority: 1001' | tee /etc/apt/preferences.d/mozilla-firefox

# ----------------- INSTALL ADDITIONAL PACKAGES -----------------
echo "Installing essential packages..."
apt-fast install -y breeze-icon-theme breeze-gtk-theme fwupd preload flatpak ubuntu-restricted-extras kubuntu-restricted-extras synaptic gdebi unzip p7zip-full unrar transmission gparted audacity git make schedtool
apt-fast install -y fortune cowsay lolcat 
fortune | cowsay | lolcat
wget -O vscode.deb "https://code.visualstudio.com/sha/download?build=stable&os=linux-deb-x64"
apt install ./vscode.deb -y

systemctl enable --now preload

# ----------------- GOOGLE CHROME INSTALLATION -----------------
echo "Installing Google Chrome..."
wget -q https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
apt-fast install -y ./google-chrome-stable_current_amd64.deb
rm -f google-chrome-stable_current_amd64.deb

# ----------------- CONFIGURE FLATPAK -----------------
echo "Configuring Flatpak..."
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
# flatpak install -y flathub com.visualstudio.code

# ----------------- CONFIGURE DVD SUPPORT -----------------
echo "Configuring DVD playback..."
apt-fast install -y libdvd-pkg
sudo dpkg-reconfigure libdvd-pkg

# ----------------- INSTALL ANANICY -----------------
echo "Installing Ananicy..."
git clone https://github.com/Nefelim4ag/Ananicy.git
cd Ananicy && ./package.sh debian
apt-fast install -y ./ananicy-*.deb
cd .. && rm -rf Ananicy

# ----------------- TIME CONFIGURATION -----------------
echo "Setting hardware clock to local time..."
timedatectl set-local-rtc 1

# ----------------- I/O SCHEDULER CONFIGURATION -----------------
echo "Setting I/O scheduler..."
echo '[Unit]\nDescription=Set I/O Scheduler\nAfter=multi-user.target\n[Service]\nType=oneshot\nExecStart=/bin/bash -c "echo none > /sys/block/sda/queue/scheduler"\nRemainAfterExit=true\n[Install]\nWantedBy=multi-user.target' | tee /etc/systemd/system/io-scheduler.service
systemctl daemon-reload
systemctl enable --now io-scheduler.service

# ----------------- DNS CONFIGURATION -----------------
echo "Configuring DNS settings..."
CONFIG_FILE="/etc/systemd/resolved.conf"
cp "$CONFIG_FILE" "${CONFIG_FILE}.bak"
sed -i '/^#\?DNS=/c\DNS=1.1.1.1 9.9.9.9 8.8.8.8' "$CONFIG_FILE"
sed -i '/^#\?FallbackDNS=/c\FallbackDNS=8.8.4.4' "$CONFIG_FILE"
sed -i '/^#\?DNSStubListener=/c\DNSStubListener=no' "$CONFIG_FILE"
systemctl restart systemd-resolved && resolvectl flush-caches

ACTIVE_CONNECTION=$(nmcli -t -f NAME connection show --active | head -n 1)
if [ -n "$ACTIVE_CONNECTION" ]; then
    nmcli connection modify "$ACTIVE_CONNECTION" ipv4.dns "1.1.1.1 9.9.9.9 8.8.8.8"
    nmcli connection modify "$ACTIVE_CONNECTION" ipv4.ignore-auto-dns yes
    nmcli connection down "$ACTIVE_CONNECTION"
    nmcli connection up "$ACTIVE_CONNECTION"
fi

# ----------------- NVIDIA DRIVER INSTALLATION -----------------
echo "Installing NVIDIA drivers..."
add-apt-repository -y ppa:graphics-drivers/ppa
apt-fast update && apt-fast install -y nvidia-driver-570

echo "Configuring NVIDIA settings..."
echo 'options nvidia NVreg_EnableMSI=1\noptions nvidia NVreg_EnablePCIeGen3=1\noptions nvidia NVreg_UsePageAttributeTable=1\noptions nvidia NVreg_RegistryDwords="RMUseSwI2c=0x01;RMI2cSpeed=100"\noptions nvidia NVreg_PreserveVideoMemoryAllocations=1\noptions nvidia NVreg_TemporaryFilePath="/var/tmp"\noptions nvidia-drm modeset=1' | tee /etc/modprobe.d/nvidia.conf

echo "Updating GRUB for NVIDIA..."
sed -i '/^GRUB_CMDLINE_LINUX_DEFAULT=/s/"\(.*\)"/"\1 quiet splash rw nvidia-drm.modeset=1 nvidia-drm.fbdev=1 rd.driver.blacklist=nouveau modprobe.blacklist=nouveau io_delay=none rootdelay=0 iomem=relaxed mitigations=off"/' /etc/default/grub
update-initramfs -u && update-grub

echo "Installation complete. Rebooting in 5 seconds..."
sleep 5
reboot
