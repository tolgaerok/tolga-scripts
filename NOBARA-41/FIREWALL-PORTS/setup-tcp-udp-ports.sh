#!/bin/bash
# Tolga Erok
# Version 2 : setup firewall and ports
# 6/1/25

# Port configurations
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
    8010  # Gnomecast server
    8888  # Gnomecast server
    5357  # wsdd: Samba
    1714  # KDE Connect
    1764  # KDE Connect
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
    1714  # KDE Connect
    1764  # KDE Connect
)

# configure ports
configure_ports() {
    local protocol=$1
    shift
    local ports=("$@")
    for port in "${ports[@]}"; do
        if ! sudo firewall-cmd --list-ports | grep -q "$port/$protocol"; then
            echo "Setting up ${protocol^^} port: $port"
            sudo firewall-cmd --permanent --add-port=$port/$protocol || {
                echo "Error: Failed to add ${protocol^^} port: $port" >&2
            }
        else
            echo "Port $port/$protocol is already configured."
        fi
    done
}

# Configure TCP and UDP ports
configure_ports tcp "${allowedTCPPorts[@]}"
configure_ports udp "${allowedUDPPorts[@]}"

# Add NetBIOS name resolution traffic on UDP port 137
echo "[✔] Adding NetBIOS name resolution traffic on UDP port 137"
sudo iptables -t raw -A OUTPUT -p udp -m udp --dport 137 -j CT --helper netbios-ns || {
    echo "Error: Failed to add iptables rule for NetBIOS traffic." >&2
}

# Reload the firewall
echo "Reloading firewall settings..."
sudo firewall-cmd --reload && echo "[✔] Firewall reloaded successfully." || echo "Error: Firewall reload failed." >&2

# check if gum installed (needs gum to be installed)
if command -v gum &>/dev/null; then
    gum spin --spinner dot --title "Reloading firewall" -- sleep 1.5
else
    echo "Note: 'gum' is not installed. Skipping visual spinner."
fi

echo "Done."
