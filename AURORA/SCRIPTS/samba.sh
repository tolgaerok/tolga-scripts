#!/bin/bash

# Variables for the Samba Share
SHARE_DIR="/var/home/tolga/Aurora41"
USER="tolga"
GROUP="tolga"
SHARE_NAME="Aurora41"
SMB_CONF="/etc/samba/smb.conf"

# Ensure Samba is installed
if ! command -v smbd &> /dev/null; then
    echo "Samba is not installed. Installing..."
    sudo dnf install -y samba
fi

# Enable home directories for Samba
echo "Enabling home directories for Samba..."
sudo setsebool -P samba_enable_home_dirs on

# Configure permissions for the share
echo "Setting up permissions for $SHARE_DIR..."
sudo chown -R "$USER:$GROUP" "$SHARE_DIR"
sudo chmod -R 0775 "$SHARE_DIR"
sudo chcon -t samba_share_t "$SHARE_DIR"

# Add Samba share configuration to smb.conf
echo "Adding $SHARE_NAME share configuration to Samba..."
if ! grep -q "$SHARE_NAME" "$SMB_CONF"; then
    echo "[$SHARE_NAME]
    comment = Personal Drive(s)
    path = $SHARE_DIR
    read only = No
    browseable = Yes
    valid users = $USER
    create mask = 0775
    directory mask = 0775" | sudo tee -a "$SMB_CONF"
else
    echo "$SHARE_NAME already exists in $SMB_CONF"
fi

# Restart Samba services
echo "Restarting Samba service..."
sudo systemctl restart smbd

# Open necessary ports in the firewall
if command -v firewall-cmd &> /dev/null; then
    echo "Opening Samba ports in the firewall..."
    sudo firewall-cmd --add-service=samba --permanent
    sudo firewall-cmd --reload
else
    echo "Firewall not detected. Skipping port configuration."
fi

# Verify Samba service
echo "Verifying Samba service status..."
sudo systemctl status smbd

# Feedback
echo "Samba share '$SHARE_NAME' setup completed successfully."
