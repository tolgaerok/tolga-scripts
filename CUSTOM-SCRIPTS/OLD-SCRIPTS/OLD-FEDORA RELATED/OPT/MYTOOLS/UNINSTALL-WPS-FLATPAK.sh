#!/bin/bash

# List installed flatpaks
flatpak list

# Uninstall WPS Office flatpak
flatpak uninstall com.wps.Office

# Delete WPS Office flatpak remote
flatpak remote-delete flathub-wps-office

# Remove WPS Office user data
rm -rf ~/.var/app/com.wps.Office/
sudo rm -rf /opt/kingsoft
sudo rm -rf ~/.config/Kingsoft

# Uninstall unused flatpaks
flatpak uninstall --unused

