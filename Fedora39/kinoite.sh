#!/bin/bash

# tolga erok
# 24/11/23

# sudo bash -c "$(curl -fsSL https://raw.githubusercontent.com/tolgaerok/tolga-scripts/main/Fedora39/kinoite.sh)"

#   ██ ▄█▀ ██▓ ███▄    █  ▒█████   ██▓▄▄▄█████▓▓█████    
#   ██▄█▒ ▓██▒ ██ ▀█   █ ▒██▒  ██▒▓██▒▓  ██▒ ▓▒▓█   ▀    
#  ▓███▄░ ▒██▒▓██  ▀█ ██▒▒██░  ██▒▒██▒▒ ▓██░ ▒░▒███      
#  ▓██ █▄ ░██░▓██▒  ▐▌██▒▒██   ██░░██░░ ▓██▓ ░ ▒▓█  ▄    
#  ▒██▒ █▄░██░▒██░   ▓██░░ ████▓▒░░██░  ▒██▒ ░ ░▒████▒   
#  ▒ ▒▒ ▓▒░▓  ░ ▒░   ▒ ▒ ░ ▒░▒░▒░ ░▓    ▒ ░░   ░░ ▒░ ░   
#  ░ ░▒ ▒░ ▒ ░░ ░░   ░ ▒░  ░ ▒ ▒░  ▒ ░    ░     ░ ░  ░   
#  ░ ░░ ░  ▒ ░   ░   ░ ░ ░ ░ ░ ▒   ▒ ░  ░         ░      
#  ░  ░    ░           ░     ░ ░   ░              ░  ░   

#  https://patorjk.com/software/taag/#p=testall&c=bash&f=Graffiti&t=Kinoite%2039    

ARG BASE_REPO=quay.io/aleskandrox/fedora
ARG BASE_TAG=kinoite-rawhide
FROM ${BASE_REPO}:${BASE_TAG}

ARG TOOLBOX_IMAGE=quay.io/aleskandrox/fedora:toolbox
ENTRYPOINT ["/bin/bash"]

# Update
sudo dnf update
rpm-ostree upgrade --check

rpm-ostree upgrade --preview
flatpak update
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

# Install rpm-fusion and other repos you need, codecs, and drivers
# Nonfree: 
rpm-ostree install https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
# Free: 
rpm-ostree install https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm

# Codecs
rpm-ostree install mozilla-openh264 gstreamer1-plugin-openh264

#GStreamer
# For intel (intel-media-driver) (use libva-intel-driver) for older versions of Intels) and then the codecs:
# rpm-ostree install ffmpeg gstreamer1-plugin-libav gstreamer1-plugins-bad-free-extras gstreamer1-plugins-bad-freeworld gstreamer1-plugins-ugly gstreamer1-vaapi intel-media-driver

# NVidia Drivers
rpm-ostree install akmod-nvidia

# RPMFusion reinstall
# When RPMFusion was installed, it was tied to a specific version of Fedora, thus rebasing for the next release would be a problem, 
# it can be fixed by uninstalling the currently installed and installing a "general" repo:
rpm-ostree update --uninstall rpmfusion-free-release --uninstall rpmfusion-nonfree-release --install rpmfusion-free-release --install rpmfusion-nonfree-release

# Flatpak modifications
# Flatpaks are sandboxed, it may not work as expected. These are some solutions to the errors that may arise or encountered.

# Theming
# Since flatpaks are sandboxed, you can either install the flatpak version of GTK theme you are using as flatpak, which you can find by using search:

flatpak search gtk3
# Or override the themes directory which depends on how the theme was installed:
# choose one, you can do all of them but I don't recommend doing it
# if install in home dir
# sudo flatpak override --system --filesystem=$HOME/.themes # if installed in home dir

# if layered in image
# sudo flatpak override --system --filesystem=/usr/share/themes 

# or whatever
# sudo flatpak override --system --filesystem=xdg-data/themes

# Permissions
# Other reddit users suggested, such as u/IceOleg, to override the home and host dir as well with:

flatpak override --user --nofilesystem=home
flatpak override --user --nofilesystem=host
flatpak install flathub com.github.tchx84.Flatseal

# The flatpak modifcations made can be undone by sudo flatpak override --system --reset

# System optimizations
# Disable NetworkManager-wait-online.service
# Disabling it can decrease the boot time of at least ~15s-20s:

sudo systemctl disable NetworkManager-wait-online.service

# Removing base image packages
# rpm-ostree override remove open-vm-tools-desktop open-vm-tools qemu-guest-agent spice-vdagent spice-webdavd virtualbox-guest-additions gnome-shell-extension-apps-menu gnome-classic-session gnome-shell-extension-window-list gnome-shell-extension-background-logo gnome-shell-extension-launch-new-instance gnome-shell-extension-places-menu

# Vscode
sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
sudo sh -c 'echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/yum.repos.d/vscode.repo'
sudo dnf check-update
sudo dnf install code
touch $HOME/.local/share/applications/code.desktop
# [Desktop Entry]
# Type=Application
# Version=1.0 # you can replace the version
# Name=Visual Studio Code
# Exec=toolbox run code
# Icon=com.visualstudio.code
# Terminal=false
# If you used a toolbox with different name, change Exec to toolbox --container <name-of-toolbox> run code.

# Layering
# Since the filesystem is immutable, you cannot import the GPG, unless you do specific changes which is not covered here. Thus, simply create a repository for code:

sudo sh -c 'echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/yum.repos.d/vscode.repo'
# Then refresh the metadata 
rpm-ostree refresh-md
rpm-ostree install code.

# Block telemetry
# VSCode contains telemetry, to block some of them block some of the domain in your /etc/hosts by setting it to loopback (127.0.0.1) by appending:

# 127.0.0.1	dc.services.visualstudio.com
# 127.0.0.1	dc.trafficmanager.net
# 127.0.0.1	vortex.data.microsoft.com
# 127.0.0.1	weu-breeziest-in.cloudapp.net
# 127.0.0.1	mobile.events.data.microsoft.com
# Then in $HOME/.config/Code/User/settings.json, include:

# "telemetry.telemetryLevel": "off"

sudo dnf clean all