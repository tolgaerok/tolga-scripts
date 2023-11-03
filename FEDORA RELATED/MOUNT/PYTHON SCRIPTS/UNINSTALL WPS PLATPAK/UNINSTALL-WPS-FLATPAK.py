#!/usr/bin/env python3

# Tolga Erok    15/3/2023   Uninstall WPS flatpak

import os

# List installed flatpaks
os.system('flatpak list')

# Uninstall WPS Office flatpak
os.system('flatpak uninstall com.wps.Office')

# Delete WPS Office flatpak remote
os.system('flatpak remote-delete flathub-wps-office')

# Remove WPS Office user data
os.system('rm -rf ~/.var/app/com.wps.Office/')
os.system('sudo rm -rf /opt/kingsoft')
os.system('rm -rf ~/.config/Kingsoft')

# Uninstall unused flatpaks
os.system('flatpak uninstall --unused')

