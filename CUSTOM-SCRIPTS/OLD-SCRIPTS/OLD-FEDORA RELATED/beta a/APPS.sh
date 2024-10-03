#!/bin/bash



## Enable Flatpak
if ! sudo flatpak remote-list | grep -q "flathub"; then
    sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
fi

## Update Flatpak
sudo flatpak update

## Install flatpak apps
packages=(
    app.drey.Dialect
    com.bitwarden.desktop
    com.calibre_ebook.calibre
    com.github.unrud.VideoDownloader
    com.sindresorhus.Caprine
    com.sublimetext.three
    com.transmissionbt.Transmission
    com.wps.Office
    io.github.aandrew_me.ytdn
    io.github.ltiber.Pwall
    io.github.eneshecan.WhatsAppForLinux
    org.audacityteam.Audacity
    org.gimp.GIMP
    org.gnome.Shotwell
    org.gnome.gitlab.YaLTeR.VideoTrimmer
    org.kde.krita
    org.kde.kweather
)

# Install each package if not already installed
for package in "${packages[@]}"; do
    if ! sudo flatpak list | grep -q "$package"; then
        echo "Installing $package..."
        sudo flatpak install -y flathub "$package"
    else
        echo "$package is already installed. Skipping..."
    fi
done

## End
echo -e "\nInstall complete..."

driver_version=$(modinfo -F version nvidia 2>/dev/null)
if [ -n "$driver_version" ]; then
    echo -e "\e[33mNVIDIA driver version: $driver_version\e[0m"
else
    echo -e "\e[33mNVIDIA driver not found.\e[0m"
fi

sleep 2
clear
