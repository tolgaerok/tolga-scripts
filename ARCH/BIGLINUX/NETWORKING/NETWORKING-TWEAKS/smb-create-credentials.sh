#!/bin/bash
# tolga erok
# 13/3/25

# my credentials file path
CREDENTIALS_FILE="/etc/samba/credentials"

read -p "Enter your Samba username: " smb_username
read -sp "Enter your Samba password: " smb_password
echo

echo "Creating Samba credentials file at $CREDENTIALS_FILE..."

# Write to my credentials file
echo "username=$smb_username" | sudo tee $CREDENTIALS_FILE > /dev/null
echo "password=$smb_password" | sudo tee -a $CREDENTIALS_FILE > /dev/null
sudo chmod 600 $CREDENTIALS_FILE
echo "Samba credentials file created successfully with restricted permissions."
