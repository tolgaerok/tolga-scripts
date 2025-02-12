#!/bin/bash
# Tolga Erok
# 6/1/2024

# Function to display messages and wait for user input
function display_message {
    read -r -p "$1" -t $2 -n 1 -s
}

# Set-up Samba user/group
display_message "Setting up Samba user & group..." 2

# Prompt for the desired username for Samba
read -p $'\nEnter the USERNAME to add to Samba: ' sambausername

# Prompt for the desired name for the Samba group
read -p $'\nEnter the GROUP name to add the username to Samba: ' sambagroup

sudo groupadd $sambagroup
sudo useradd -m $sambausername
sudo smbpasswd -a $sambausername
sudo usermod -aG $sambagroup $sambausername

display_message "\nContinuing..." 1

# Create and configure custom Samba folder
read -p "Enter the desired name for the Samba folder: " sambafoldername

display_message "Creating and configuring the custom Samba folder \"$sambafoldername\"..." 2

sudo mkdir /home/$sambausername/$sambafoldername
sudo chgrp samba /home/$sambausername/$sambafoldername
sudo chmod 770 /home/$sambausername/$sambafoldername

display_message "\nContinuing..." 1

# Create and configure Samba Filesharing Plugin
display_message "Creating and configuring Samba Filesharing Plugin..." 3

# Prompt for the username to configure Samba Filesharing Plugin for
read -p $'\nEnter the username to configure Samba Filesharing Plugin for: ' username

# Set umask value
umask 0002

# Set the shared folder path
shared_folder="/home/$username"

# Set permissions for the shared folder and parent directories (excluding hidden files and .cache directory)
find "$shared_folder" -type d ! -path '/.' ! -path '/.cache' -exec chmod 0757 {} \; 2>/dev/null

# Create the sambashares group if it doesn't exist
sudo groupadd -r sambashares

# Create the usershares directory and set permissions
sudo mkdir -p /var/lib/samba/usershares
sudo chown $username:sambashares /var/lib/samba/usershares
sudo chmod 1770 /var/lib/samba/usershares

# Restore SELinux context for the usershares directory
sudo restorecon -R /var/lib/samba/usershares

# Add the user to the sambashares group
sudo gpasswd sambashares -a $username

# Set permissions for the user's home directory
sudo chmod 0757 /home/$username

# Prompt to open the default web browser to the Samba Filesharing Plugin website
display_message $'\nPress Enter to open the Samba Filesharing Plugin website. Please select [ install ] when ready...  ' 

# Open the default web browser
xdg-open "https://apps.kde.org/kdenetwork_filesharing/" || echo "Error: Unable to open the default web browser."

display_message "\nContinuing..." 1

# Restart SMB and NMB services (optional)
display_message "Restarting SMB and NMB services..." 2
sudo systemctl restart smb.service nmb.service

display_message "\nContinuing..." 1

# Checking smb.conf file
display_message "Checking smb.conf file..." 2
sudo testparm -s

display_message "\nContinuing..." 1

# Enable Usershares
display_message "Enabling Usershares..." 2

# Step 1: Create a directory for usershares
mkdir /var/lib/samba/usershares

# Step 2: Create a user group
groupadd -r sambashare

# Step 3: Change the owner of the directory to root and the group to sambashare
chown root:sambashare /var/lib/samba/usershares

# Step 4: Change the permissions of the usershares directory
chmod 1770 /var/lib/samba/usershares

# Step 5: Set parameters in the smb.conf configuration file
echo -e "\n[global]\n  usershare path = /var/lib/samba/usershares\n  usershare max shares = 100\n  usershare allow guests = yes\n  usershare owner only = yes" >> /etc/samba/smb.conf

# Step 6: Add the user to the sambashare group
read -p "Enter your username: " your_username
gpasswd sambashare -a $your_username

# Step 7: Restart smb.service and nmb.service services
systemctl restart smb.service nmb.service

echo "Usershares enabled. Please log out and log back in for the changes to take effect."
