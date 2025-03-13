#!/bin/bash
# Tolga Erok

# variables
SHARED_FOLDER="/srv/samba/shared"
SAMBAGROUP="users"
SAMBAUSER="tolga"

echo "Checking if the shared folder exists..."
if [ ! -d "$SHARED_FOLDER" ]; then
    echo "Creating shared folder at $SHARED_FOLDER..."
    sudo mkdir -p "$SHARED_FOLDER"
fi

echo "Setting ownership and permissions for the shared folder..."
sudo chown -R root:"$SAMBAGROUP" "$SHARED_FOLDER"
sudo chmod -R 0775 "$SHARED_FOLDER"

echo "Checking if user $SAMBAUSER exists in Samba..."
if ! sudo pdbedit -L | grep -q "$SAMBAUSER"; then
    echo "Adding $SAMBAUSER to Samba..."
    sudo smbpasswd -a "$SAMBAUSER"
    sudo smbpasswd -e "$SAMBAUSER" # Enable the user
else
    echo "User $SAMBAUSER already exists in Samba."
fi

echo "Ensuring $SAMBAUSER is a member of the $SAMBAGROUP group..."
if ! groups "$SAMBAUSER" | grep -q "$SAMBAGROUP"; then
    echo "Adding $SAMBAUSER to the $SAMBAGROUP group..."
    sudo usermod -aG "$SAMBAGROUP" "$SAMBAUSER"
else
    echo "$SAMBAUSER is already a member of the $SAMBAGROUP group."
fi

echo "Restarting Samba service..."
sudo systemctl restart smb

echo "Confirming access to the shared folder for $SAMBAUSER..."
smbclient //localhost/shared -U "$SAMBAUSER"

echo "Samba share setup for $SAMBAUSER is complete!"
