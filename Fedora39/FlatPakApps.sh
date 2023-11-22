#!/bin/bash

# Tolga Erok
# 19/11/23

# Check if Flatpak is installed
if ! command -v flatpak &>/dev/null; then
    echo "Flatpak is not installed. Please install Flatpak and run the script again."
    exit 1
fi

# Add Flathub repository if not already added
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

# Define an array of Flatpak application IDs
flatpak_apps=(
    "com.sindresorhus.Caprine"
    "org.gnome.Shotwell"
    "com.transmissionbt.Transmission"
    "com.anydesk.Anydesk"
    "me.kozec.syncthingtk"
    "com.github.zocker_160.SyncThingy"
)

# Install applications
for app in "${flatpak_apps[@]}"; do
    flatpak install flathub "$app"
done
echo -e "\e[1;32m[✔]\e[0m Checking updates for installed flatpak programs...\n"
sudo flatpak update -y
sleep 1

echo -e "\e[1;32m[✔]\e[0m Removing Old Flatpak Cruft...\n"
flatpak uninstall --unused
flatpak uninstall --delete-data
sudo rm -rfv /var/tmp/flatpak-cache-*
sleep 1

echo "Installation completed. You can now run the installed applications."
