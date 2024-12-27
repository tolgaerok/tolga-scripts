#!/bin/bash
# Tolga Erok
# 27/12/24
# Wifi tweaker to suit my AX3000 ARCHER TX50E

# Detect any active network interface
interface=$(ip link show | awk -F: '$0 ~ "^[2-9]:|^[1-9][0-9]: " && $0 ~ "UP" && $0 !~ "LOOPBACK|NO-CARRIER" {gsub(/^[ \t]+|[ \t]+$/, "", $2); print $2; exit}')

# Make sure an interface is detected
if [ -z "$interface" ]; then
    echo "No active network interface found."
    exit 1
fi

# my MTU value to suit AX3000 ARCHER TX50E
mtu_value="${1:-2304}" 

# iwlwifi and NetworkManager configurations
iwlwifi_conf="/etc/modprobe.d/iwlwifi.conf"
networkmanager_conf="/etc/NetworkManager/conf.d/99-wifi-settings.conf"

# Apply MTU setting
echo "Setting MTU for $interface to $mtu_value..."
sudo ip link set $interface mtu $mtu_value

# Configure iwlwifi for aggregation TX (11n_disable=8): WIKI
echo "Applying iwlwifi 11n_disable=8..."
echo "options iwlwifi 11n_disable=8" | sudo tee $iwlwifi_conf >/dev/null

# Reload the iwlwifi module
echo "Reloading iwlwifi module..."
sudo modprobe -r iwlwifi
sleep 2
sudo modprobe iwlwifi

# Apply NM Wi-Fi settings
echo "Configuring NetworkManager Wi-Fi settings..."
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
cat /sys/class/net/$interface/mtu
cat /sys/module/iwlwifi/parameters/11n_disable

echo "Wi-Fi setup completed successfully."
echo ""
echo "Please reboot system"
