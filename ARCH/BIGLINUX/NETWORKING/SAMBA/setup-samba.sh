#!/bin/bash
# Tolga Erok

# Colours
GREEN="\e[32m"
YELLOW="\e[33m"
BLUE="\e[34m"
RED="\e[31m"
RESET="\e[0m"

# Icons
CHECK="✅"
WARN="⚠️"
INFO="ℹ️"
ERROR="❌"

# Variables
SHARED_FOLDER="/srv/samba/shared"
SAMBAGROUP="users"
SAMBAUSER="tolga"

echo -e "${INFO} ${BLUE}Checking if the shared folder exists...${RESET}"
if [ ! -d "$SHARED_FOLDER" ]; then
    echo -e "${WARN} ${YELLOW}Creating shared folder at $SHARED_FOLDER...${RESET}"
    sudo mkdir -p "$SHARED_FOLDER"
fi

echo -e "${INFO} ${BLUE}Setting ownership and permissions for the shared folder...${RESET}"
sudo chown -R root:"$SAMBAGROUP" "$SHARED_FOLDER"
sudo chmod -R 0775 "$SHARED_FOLDER"

echo -e "${INFO} ${BLUE}Configuring firewall for Samba...${RESET}"
sudo firewall-cmd --permanent --zone=public --add-service=samba
sudo firewall-cmd --reload

echo -e "${INFO} ${BLUE}Configuring SELinux for Samba...${RESET}"
sudo setsebool -P samba_enable_home_dirs on

echo -e "${INFO} ${BLUE}Restoring SELinux contexts for shared folder...${RESET}"
sudo chcon -t samba_share_t "$SHARED_FOLDER" -R  # Fixing the SELinux context

echo -e "${INFO} ${BLUE}Checking if user $SAMBAUSER exists in Samba...${RESET}"
if ! sudo pdbedit -L | grep -q "^$SAMBAUSER:"; then
    echo -e "${WARN} ${YELLOW}Adding $SAMBAUSER to Samba...${RESET}"
    sudo smbpasswd -a "$SAMBAUSER"
    sudo smbpasswd -e "$SAMBAUSER" # Enable the user
else
    echo -e "${CHECK} ${GREEN}User $SAMBAUSER already exists in Samba.${RESET}"
fi

echo -e "${INFO} ${BLUE}Ensuring $SAMBAUSER is a member of the $SAMBAGROUP group...${RESET}"
if ! id -nG "$SAMBAUSER" | grep -wq "$SAMBAGROUP"; then
    echo -e "${WARN} ${YELLOW}Adding $SAMBAUSER to the $SAMBAGROUP group...${RESET}"
    sudo usermod -aG "$SAMBAGROUP" "$SAMBAUSER"
else
    echo -e "${CHECK} ${GREEN}$SAMBAUSER is already a member of the $SAMBAGROUP group.${RESET}"
fi

echo -e "${INFO} ${BLUE}Restarting Samba service...${RESET}"
sudo systemctl restart smb

echo -e "${INFO} ${BLUE}Confirming access to the shared folder for $SAMBAUSER...${RESET}"

if smbclient //localhost/shared -U "$SAMBAUSER" -N; then
    echo -e "${CHECK} ${GREEN}Access test successful${RESET}"
else
    echo -e "${ERROR} ${RED}Access test failed. Check logs.${RESET}"
fi

echo -e "${CHECK} ${GREEN}Samba share setup for $SAMBAUSER is complete! 🎉${RESET}"
