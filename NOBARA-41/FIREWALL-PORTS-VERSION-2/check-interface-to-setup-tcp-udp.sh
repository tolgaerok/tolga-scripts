#!/bin/bash
# Tolga Erok
# Version 3 : setup firewall and ports
# 6/1/25
# Detect any active network interface (uplink or wireless)

interface=$(ip link show | awk -F: '$0 ~ "^[2-9]:|^[1-9][0-9]: " && $0 ~ "UP" && $0 !~ "LOOPBACK|NO-CARRIER" {gsub(/^[ \t]+|[ \t]+$/, "", $2); print $2; exit}')

if [[ -z "$interface" ]]; then
    echo "Error: No active network interface detected."
    exit 1
fi

echo "Detected active network interface: $interface"

# Ddefine FW zone
FIREWALL_ZONE="hotspot"

# Ports for the hotspot
allowedTCPPorts=(21 53 80 443 143 389 139 445 25 22 5432 3306 3307 111 2049 2375 22000 9091 60450 8010 8888 5357 1714 1764 8200)
allowedUDPPorts=(53 137 138 3702 5353 21027 22000 8200 1714 1764)

# custom firewalld zone for the detected interface
if ! sudo firewall-cmd --get-zones | grep -q "$FIREWALL_ZONE"; then
    echo "Creating firewall zone: $FIREWALL_ZONE"
    sudo firewall-cmd --permanent --new-zone=$FIREWALL_ZONE || {
        echo "Error: Failed to create zone $FIREWALL_ZONE" >&2
        exit 1
    }
fi

echo "Assigning interface $interface to zone $FIREWALL_ZONE"
sudo firewall-cmd --permanent --zone=$FIREWALL_ZONE --add-interface=$interface || {
    echo "Error: Failed to assign interface $interface to zone $FIREWALL_ZONE" >&2
    exit 1
}

# configure ports
configure_ports() {
    local protocol=$1
    shift
    local ports=("$@")
    for port in "${ports[@]}"; do
        echo "Adding ${protocol^^} port $port to zone $FIREWALL_ZONE"
        sudo firewall-cmd --permanent --zone=$FIREWALL_ZONE --add-port=$port/$protocol || {
            echo "Error: Failed to add ${protocol^^} port $port to zone $FIREWALL_ZONE" >&2
        }
    done
}

# configure TCP and UDP ports for the hotspot zone thats selected
configure_ports tcp "${allowedTCPPorts[@]}"
configure_ports udp "${allowedUDPPorts[@]}"

# reload the firewall
echo "Reloading firewall settings..."
sudo firewall-cmd --reload && echo "[✔] Firewall reloaded successfully." || echo "Error: Firewall reload failed." >&2

echo "Firewall configured for hotspot on interface $interface."
