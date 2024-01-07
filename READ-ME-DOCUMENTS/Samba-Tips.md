# Start Samba manually
sudo systemctl start smb

# Configure Samba to start automatically on each boot and immediately start the service
sudo systemctl enable --now smb

# Check whether Samba is running
sudo systemctl status smb

# Restart Samba manually
sudo systemctl restart smb

# Stop Samba manually
sudo systemctl stop smb

# Configure Samba to not start automatically on each boot and immediately stop the service
sudo systemctl disable --now smb

# Start wsdd manually (depends on the smb service)
sudo systemctl start wsdd

# Configure wsdd to start automatically on each boot and immediately start the service
sudo systemctl enable --now wsdd

# Check whether wsdd is running
sudo systemctl status wsdd

# Restart wsdd and Samba
sudo systemctl restart wsdd smb

# Stop wsdd manually
sudo systemctl stop wsdd

# Configure wsdd to not start automatically on each boot and immediately stop the service
sudo systemctl disable --now wsdd

net usershare add sharename path [comment] [acl] [guest_ok=[y|n]]
#    To create or modify (overwrite) a user defined share.

net usershare delete sharename
#    To delete a user defined share.

net usershare list wildcard-sharename
 #   To list user defined shares.

net usershare info wildcard-sharename
 #   To print information about user defined shares.

 # Add the some_user account to the Samba login db
sudo smbpasswd -a some_user

# Enable the some_user account in the Samba login db
sudo smbpasswd -e some_user

# Try to log in to a running Samba instance as some_user and list shares
smbclient -U some_user -L localhost

# Disable the some_user account in the Samba login db
sudo smbpasswd -d some_user

# Remove the some_user account from the Samba login db
sudo smbpasswd -x some_user

windows11-nord
breeze
windiws11OS-nord
windows11nord
utterly-round-dark-solid
beautyfolders
sweet-cursos
