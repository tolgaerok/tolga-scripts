#!/bin/bash

# Tolga Erok
# 13/1/2024

clear
sudo dnf install avahi
sudo systemctl enable --now avahi-daemon
sudo dnf install system-config-printer
system-config-printer
sudo systemctl restart cups

GREEN='\e[1;32m'
NC='\e[0m'

display_message() {
    echo -e "$1"
}

if [ "$EUID" -ne 0 ]; then
    display_message "[ERROR] Please run the script as root or using sudo."
    exit 1
fi

sudo firewall-cmd --permanent --zone=public --add-port=631/tcp
sudo firewall-cmd --permanent --zone=public --add-port=631/udp
sudo firewall-cmd --permanent --zone=public --add-port=9100/tcp
sudo firewall-cmd --permanent --zone=public --add-port=9100/udp

sudo firewall-cmd --add-rich-rule='rule family="ipv4" source address="239.255.255.250" port protocol="udp" port="3702" accept'
sudo firewall-cmd --add-rich-rule='rule family="ipv6" source address="ff02::c" port protocol="udp" port="3702" accept'
sudo firewall-cmd --add-rich-rule='rule family="ipv4" port protocol="udp" port="3702" accept'
sudo firewall-cmd --add-rich-rule='rule family="ipv6" port protocol="udp" port="3702" accept'
sudo firewall-cmd --add-rich-rule='rule family="ipv4" port protocol="tcp" port="5357" accept'
sudo firewall-cmd --add-rich-rule='rule family="ipv6" port protocol="tcp" port="5357" accept'

sudo iptables -t raw -A OUTPUT -p udp -m udp --dport 137 -j CT --helper netbios-ns

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

echo "Installing Avahi daemon"
sudo dnf install avahi

echo "Enabling and starting Avahi daemon"
sudo systemctl enable --now avahi-daemon

echo "Installing system-config-printer"
sudo dnf install system-config-printer

echo "Restarting firewall"
sudo systemctl restart firewalld

display_message "Script execution completed. Please try setting up your printer again."

firewall_state=$(sudo firewall-cmd --state)

prompt_user() {
    read -p "$1 (y/n): " response
    echo "$response"
}

if [[ "$firewall_state" == "running" ]]; then
    display_message "The firewall is currently running."

    response=$(prompt_user "Do you want to stop the firewall temporarily?")

    if [[ "$response" == "y" || "$response" == "Y" ]]; then
        sudo systemctl stop firewalld
        display_message "The firewall has been stopped temporarily."
    else
        display_message "No changes were made to the firewall."
    fi

else
    display_message "The firewall is currently not running."

    response=$(prompt_user "Do you want to enable the firewall?")

    if [[ "$response" == "y" || "$response" == "Y" ]]; then
        sudo systemctl start firewalld
        display_message "The firewall has been started."
    else
        display_message "No changes were made to the firewall."
    fi
fi
