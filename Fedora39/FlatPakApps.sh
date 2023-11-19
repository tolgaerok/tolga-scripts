#!/bin/bash

# Check if Flatpak is installed
if ! command -v flatpak &> /dev/null; then
    echo "Flatpak is not installed. Please install Flatpak and run the script again."
    exit 1
fi

# Install Caprine
flatpak install flathub com.github.desdelinux.caprine

# Install Shotwell
flatpak install flathub org.gnome.Shotwell

# Install Transmission
flatpak install flathub com.transmissionbt.Transmission

# Install Pidgin
flatpak install flathub im.pidgin.Pidgin

echo "Installation completed. You can now run the installed applications."
