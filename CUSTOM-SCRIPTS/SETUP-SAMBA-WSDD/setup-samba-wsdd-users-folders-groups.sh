#!/bin/bash

# Tolga Erok
# My personal Fedora 39 KDE tweaker
# 18/11/2023

# Run from remote location:
# sudo bash -c "$(curl -fsSL https://raw.githubusercontent.com/tolgaerok/tolga-scripts/main/Fedora39/TolgaFedora39.sh)"

#  ¯\_(ツ)_/¯
#    █████▒▓█████ ▓█████▄  ▒█████   ██▀███   ▄▄▄
#  ▓██   ▒ ▓█   ▀ ▒██▀ ██▌▒██▒  ██▒▓██ ▒ ██▒▒████▄
#  ▒████ ░ ▒███   ░██   █▌▒██░  ██▒▓██ ░▄█ ▒▒██  ▀█▄
#  ░▓█▒  ░ ▒▓█  ▄ ░▓█▄   ▌▒██   ██░▒██▀▀█▄  ░██▄▄▄▄██
#  ░▒█░    ░▒████▒░▒████▓ ░ ████▓▒░░██▓ ▒██▒ ▓█   ▓██▒
#   ▒ ░    ░░ ▒░ ░ ▒▒▓  ▒ ░ ▒░▒░▒░ ░ ▒▓ ░▒▓░ ▒▒   ▓▒█░
#   ░       ░ ░  ░ ░ ▒  ▒   ░ ▒ ▒░   ░▒ ░ ▒░  ▒   ▒▒ ░
#   ░ ░       ░    ░ ░  ░ ░ ░ ░ ▒    ░░   ░   ░   ▒
#   ░  ░      ░    ░ ░     ░              ░  ░   ░

# https://github.com/massgravel/Microsoft-Activation-Scripts

clear

# Check if the script is run as root
if [ "$EUID" -ne 0 ]; then
    echo "Please run this script as root or using sudo."
    exit 1
fi

[ ${UID} -eq 0 ] && read -p "Username for this script: " user && export user || export user="$USER"

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

# Function to display messages
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

# Template
# display_message "[${GREEN}✔${NC}]
# display_message "[${RED}✘${NC}]

## Networking packages
sudo dnf -y install iptables iptables-services nftables
sudo dnf -y install wsdd


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
read -r -p "Create and configure custom samba folder located at /home/fedora39
" -t 2 -n 1 -s

sudo mkdir /home/fedora39
sudo chgrp samba /home/fedora39
sudo chmod 770 /home/fedora39
sudo restorecon -R /home/fedora39

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
echo "It also implements the client side of the discovery protocol which allows to search for Windows machines and other devices implementing WSD. This mode of operation is called discovery mode."
echo""

gum spin --spinner dot --title " Standby, traffic for the following ports, directions and addresses must be allowed" -- sleep 2

sudo firewall-cmd --add-rich-rule='rule family="ipv4" source address="239.255.255.250" port protocol="udp" port="3702" accept'
sudo firewall-cmd --add-rich-rule='rule family="ipv6" source address="ff02::c" port protocol="udp" port="3702" accept'
sudo firewall-cmd --add-rich-rule='rule family="ipv4" port protocol="udp" port="3702" accept'
sudo firewall-cmd --add-rich-rule='rule family="ipv6" port protocol="udp" port="3702" accept'
sudo firewall-cmd --add-rich-rule='rule family="ipv4" port protocol="tcp" port="5357" accept'
sudo firewall-cmd --add-rich-rule='rule family="ipv6" port protocol="tcp" port="5357" accept'
sudo iptables -t raw -A OUTPUT -p udp -m udp --dport 137 -j CT --helper netbios-ns

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

# Start Samba manually
sudo systemctl start smb

# Configure Samba to start automatically on each boot and immediately start the service
sudo systemctl enable --now smb

# Check whether Samba is running
sudo systemctl status smb

# Restart Samba manually
sudo systemctl restart smb

# Start wsdd manually (depends on the smb service)
sudo systemctl start wsdd

# Configure wsdd to start automatically on each boot and immediately start the service
sudo systemctl enable --now wsdd

# Check whether wsdd is running
sudo systemctl status wsdd

# Restart wsdd and Samba
sudo systemctl restart wsdd smb

# Apply sysctl changes
sudo udevadm control --reload-rules
sudo udevadm trigger
sudo sysctl --system
sudo sysctl -p