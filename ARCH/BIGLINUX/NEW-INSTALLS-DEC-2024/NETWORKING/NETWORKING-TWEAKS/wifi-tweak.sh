#!/bin/bash
# Tolga Erok
# 27/12/24
# Wifi tweaker to suit my AX3000 ARCHER TX50E

clear

# Define color codes
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
NC='\033[0m' # No Color

# Check for root privileges
if [ "$(id -u)" != "0" ]; then
    echo -e "${YELLOW}This script must be run with root privileges.${NC}"
    exit 1
fi

# Detect any active network interface
interface=$(ip link show | awk -F: '$0 ~ "^[2-9]:|^[1-9][0-9]: " && $0 ~ "UP" && $0 !~ "LOOPBACK|NO-CARRIER" {gsub(/^[ \t]+|[ \t]+$/, "", $2); print $2; exit}')

# Make sure an interface is detected
if [ -z "$interface" ]; then
    echo "No active network interface found."
    exit 1
fi

# Define default and custom MTU values
default_mtu_value="1500"
custom_mtu_value="2304"

# Display current MTU
echo -e "Current active interface: ${YELLOW}$interface${NC}"
echo -e "Current MTU: ${BLUE}$(cat /sys/class/net/$interface/mtu)${NC}"

# Prompt user to choose MTU value
echo -e "Do you want to use the default MTU value (${BLUE}$default_mtu_value${NC}) or a custom MTU value (${BLUE}$custom_mtu_value${NC})?"
echo "1) Use default MTU ($default_mtu_value)"
echo "2) Use custom MTU ($custom_mtu_value)"
read -p "Enter choice (1 or 2): " choice

# Set MTU value based on user input
if [ "$choice" -eq 1 ]; then
    mtu_value="$default_mtu_value"
    echo -e "Using default MTU value: ${BLUE}$mtu_value${NC}"
elif [ "$choice" -eq 2 ]; then
    mtu_value="$custom_mtu_value"
    echo -e "Using custom MTU value: ${BLUE}$mtu_value${NC}"
else
    echo -e "Invalid choice, using default MTU value: ${BLUE}$default_mtu_value${NC}"
    mtu_value="$default_mtu_value"
fi

# Apply MTU setting
echo -e "Setting MTU for ${YELLOW}$interface${NC} to ${BLUE}$mtu_value${NC}..."
sudo ip link set $interface mtu $mtu_value

# Restart NetworkManager to apply changes
echo "Restarting NetworkManager to apply changes..."
sudo systemctl restart NetworkManager

# Configure iwlwifi for aggregation TX (11n_disable=8)
echo "Applying iwlwifi 11n_disable=8..."
iwlwifi_conf="/etc/modprobe.d/iwlwifi.conf" # Define the iwlwifi configuration file

# Ensure the configuration file exists and append the option if not present
echo "options iwlwifi 11n_disable=8" | sudo tee -a $iwlwifi_conf >/dev/null

# Reload the iwlwifi module by restarting the network interface
echo "Disabling Wi-Fi interface to reload iwlwifi module..."
sudo ip link set $interface down
sleep 2
sudo modprobe -r iwlwifi
sleep 2
sudo modprobe iwlwifi
sudo ip link set $interface up

# Apply NM Wi-Fi settings
echo "Configuring NetworkManager Wi-Fi settings..."
networkmanager_conf="/etc/NetworkManager/conf.d/wifi.conf"
sudo mkdir -p /etc/NetworkManager/conf.d
echo "[device]" | sudo tee $networkmanager_conf >/dev/null
echo "wifi.scan-rand-mac-address=no" | sudo tee -a $networkmanager_conf >/dev/null
echo "" | sudo tee -a $networkmanager_conf >/dev/null
echo "[connection]" | sudo tee -a $networkmanager_conf >/dev/null
echo "wifi.powersave=2" | sudo tee -a $networkmanager_conf >/dev/null

# Restart NM to apply settings
echo "Restarting NetworkManager to apply changes..."
sudo systemctl restart NetworkManager

# Verify the settings
echo "Verifying the applied settings..."
cat /sys/class/net/$interface/mtu # wlp4s0
cat /sys/module/iwlwifi/parameters/11n_disable

echo "Wi-Fi setup completed successfully."
echo ""
echo "Please reboot system"
