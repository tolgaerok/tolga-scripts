#!/bin/bash
# Tolga Erok
# 9/5/2023

# Check if running in root
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root"
   exit 1
fi

# Install samba and create user/group
    read -r -p "Install samba and create user/group" -t 2 -n 1 -s && clear

        sudo dnf -y install samba
        sudo groupadd samba
        sudo useradd -m tolga
        sudo smbpasswd -a tolga
        sudo usermod -aG samba tolga

    read -r -p "  ..... Continuing" -t 1 -n 1 -s && clear
    clear

# Configure custom samba folder
    read -r -p "Create and configure custom samba folder" -t 2 -n 1 -s && clear

        sudo  mkdir /home/F38-KDE
        sudo  chgrp samba /home/F38-KDE
        sudo  chmod 770 /home/F38-KDE
        sudo  restorecon -R /home/F38-KDE

    read -r -p "  ..... Continuing" -t 1 -n 1 -s && clear
    clear

# Configure samba permissions and firewall
    read -r -p "Configure samba permissions and firewall" -t 2 -n 1 -s && clear

        sudo setsebool -P samba_enable_home_dirs on
        sudo firewall-cmd --add-service=samba --permanent
        sudo firewall-cmd --reload

    read -r -p "  ..... Continuing" -t 1 -n 1 -s && clear
    clear

# Configure user shares
    read -r -p "Create and configure user shares" -t 2 -n 1 -s && clear

        sudo mkdir /var/lib/samba/usershares
        sudo groupadd -r sambashare
        sudo chown root:sambashare /var/lib/samba/usershares
        sudo chmod 1770 /var/lib/samba/usershares
        sudo restorecon -R /var/lib/samba/usershares
        sudo gpasswd sambashare -a tolga
        sudo usermod -aG sambashare tolga

    read -r -p "  ..... Continuing" -t 1 -n 1 -s && clear
    clear

# Configure fstab
    read -r -p "Configure fstab" -t 2 -n 1 -s && clear

        sudo cp /etc/fstab /etc/fstab.bak
        sudo sh -c 'echo "//192.168.0.3/LinuxData /mnt/linux-data cifs credentials=/etc/samba/credentials,uid=tolga,gid=samba,file_mode=0777,dir_mode=0777,x-systemd.idle-timeout=0 0 0" >> /etc/fstab'
        sudo sh -c 'echo "//192.168.0.3/WINDOWSDATA /mnt/windows-data cifs credentials=/etc/samba/credentials,uid=tolga,gid=samba,file_mode=0777,dir_mode=0777,x-systemd.idle-timeout=0 0 0" >> /etc/fstab'
        sudo systemctl daemon-reload

    read -r -p "  ..... Continuing" -t 1 -n 1 -s && clear
    clear

# Create mount points and set permissions
    read -r -p "Create mount points and set permissions" -t 2 -n 1 -s && clear && echo ""
        sudo mkdir /mnt/windows-data
        sudo chmod 777 /mnt/windows-data
        sudo mkdir /mnt/linux-data
        sudo chmod 777 /mnt/linux-data
        sudo mkdir /mnt/smb
        sudo chmod 777 /mnt/smb
        sudo mkdir /mnt/smb-rsync
        sudo chmod 777 /mnt/smb-rsync
        sudo mkdir /mnt/smb-budget
        sudo chmod 777 /mnt/smb-budget


    read -r -p "  ..... Continuing" -t 1 -n 1 -s && clear
    clear

# Mount the shares and start services
    read -r -p "Mount the shares and start services" -t 2 -n 1 -s && clear && echo ""

        sudo mount -a || { echo "Mount failed"; exit 1; }
        sudo systemctl enable smb nmb || { echo "Failed to enable services"; exit 1; }
        sudo systemctl restart smb.service nmb.service || { echo "Failed to restart services"; exit 1; }

    read -r -p "  ..... Continuing" -t 1 -n 1 -s && clear
    clear

# Test the fstab entries
    read -r -p "Test the fstab entries" -t 2 -n 1 -s && clear

        sudo ls /mnt/windows-data || { echo "Failed to list Windows data"; exit 1; }
        sudo ls /mnt/linux-data || { echo "Failed to list Linux data"; exit 1; }
        sudo ls /mnt/smb || { echo "Failed to list SMB share"; exit 1; }

    read -r -p "  ..... Continuing" -t 1 -n 1 -s && clear
    clear

echo "Done....close window"

exit 0

