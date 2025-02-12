#!/bin/bash
# Tolga Erok
# 27/12/24
# Wifi tweaker to suit my AX3000 ARCHER TX50E (SUPERFAST EDITION)

# Speed Enhancements from V1 original script
# 1. Reduced unnecessary `echo` statements
# 2. Combined `echo` and `sudo tee` for file writes
# 3. Removed `sleep` commands (replaced with more efficient restarts)
# 4. Improved variable naming and formatting for readability

# Color Codes
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
NC='\033[0m' # No Color

# Root Privileges Check
if [ "$(id -u)" != "0" ]; then
    echo -e "${YELLOW}Run with root privileges!${NC}"
    exit 1
fi

# Detect Active Network Interface
interface=$(ip -o link show | awk '$6 == "UP" && $0 !~ "lo|vir|^[^0-9]"{print $2; exit}')
if [ -z "$interface" ]; then
    echo "No active network interface found."
    exit 1
fi

# MTU Configuration
default_mtu="1500"
custom_mtu="2304"
current_mtu=$(cat "/sys/class/net/$interface/mtu")

echo -e "Interface: ${YELLOW}$interface${NC} | Current MTU: ${BLUE}$current_mtu${NC}"
echo -e "Choose MTU: "
echo "1) Default ($default_mtu)"
echo "2) Custom ($custom_mtu)"
read -p "Enter choice (1/2): " choice

# Apply MTU Setting
case $choice in
1) mtu=$default_mtu ;;
2) mtu=$custom_mtu ;;
*)
    mtu=$default_mtu
    echo -e "Invalid choice, using ${BLUE}$default_mtu${NC}"
    ;;
esac

sudo ip link set "$interface" mtu "$mtu"
echo -e "MTU set to ${BLUE}$mtu${NC} for ${YELLOW}$interface${NC}"

# Restart NM (applies MTU)
sudo systemctl restart NetworkManager

# Configure iwlwifi (11n_disable=8)
iwlwifi_conf="/etc/modprobe.d/iwlwifi.conf"
sudo tee -a "$iwlwifi_conf" >/dev/null <<<"options iwlwifi 11n_disable=8"

# Reload iwlwifi Module
sudo ip link set "$interface" down
sudo modprobe -r iwlwifi
sudo modprobe iwlwifi
sudo ip link set "$interface" up

# NM Wi-Fi Configuration
networkmanager_conf="/etc/NetworkManager/conf.d/wifi.conf"
sudo mkdir -p /etc/NetworkManager/conf.d
{
    echo "[device]"
    echo "wifi.scan-rand-mac-address=no"
    echo ""
    echo "[connection]"
    echo "wifi.powersave=2"
} | sudo tee "$networkmanager_conf" >/dev/null

# Restart NM to apply Wi-Fi settings
sudo systemctl restart NetworkManager

# Verify Settings
echo -e "Verifying the applied settings..."
cat "/sys/class/net/$interface/mtu"
cat "/sys/module/iwlwifi/parameters/11n_disable"

echo -e "Wi-Fi setup completed successfully."
echo -e "${YELLOW}Please reboot the system for changes to take full effect.${NC}"
