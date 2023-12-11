#!/bin/bash

# Tolga Erok.
# My personal Fedora 39 flatpaks
# 23/11/2023

# Run from remote location:::.
# sudo bash -c "$(curl -fsSL https://raw.githubusercontent.com/tolgaerok/tolga-scripts/main/Fedora39/FlatPakApps.sh)"

#  ¯\_(ツ)_/¯
#    █████▒▓█████ ▓█████▄  ▒█████   ██▀███   ▄▄▄
#  ▓██   ▒ ▓█   ▀ ▒██▀ ██▌▒██▒  ██▒▓██ ▒ ██▒▒████▄
#  ▒████ ░ ▒███   ░██   █▌▒██░  ██▒▓██ ░▄█ ▒▒██  ▀█▄
#  ░▓█▒  ░ ▒▓█  ▄ ░▓█▄   ▌▒██   ██░▒██▀▀█▄  ░██▄▄▄▄██
#  ░▒█░    ░▒████▒░▒████▓ ░ ████▓▒░░██▓ ▒██▒ ▓█   ▓██▒
#   ▒ ░    ░░ ▒░ ░ ▒▒▓  ▒ ░ ▒░▒░▒░ ░ ▒▓ ░▒▓░ ▒▒   ▓▒█░
#   ░       ░ ░  ░ ░ ▒  ▒   ░ ▒ ▒░   ░▒ ░ ▒░  ▒   ▒▒ ░
#   ░ ░       ░    ░ ░  ░ ░ ░ ░ ▒    ░░   ░   ░   ▒
#   ░  ░      ░    ░ ░     ░              ░  ░   ░

# Check if Flatpak is installed
if ! command -v flatpak &>/dev/null; then
    echo "Flatpak is not installed. Please install Flatpak and run the script again."
    exit 1
fi

# Add Flathub repository if not already added
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

if lspci | grep VGA | grep "Intel" > /dev/null; then
  flatpak install -y flathub org.freedesktop.Platform.VAAPI.Intel/x86_64/22.08
  flatpak install -y flathub org.freedesktop.Platform.VAAPI.Intel/x86_64/23.08
fi

 echo "#####################################"
 echo
 echo "Enabling Flatpak Theming Overrides"
 echo
 sudo flatpak override --filesystem=$HOME/.themes
 sudo flatpak override --filesystem=xdg-config/gtk-4.0:ro
 sudo flatpak override --filesystem=xdg-config/gtk-3.0:ro

# Install Flatpak runtimes
flatpak install -y flathub org.freedesktop.Platform.ffmpeg-full/x86_64/22.08
flatpak install -y flathub org.freedesktop.Platform.ffmpeg-full/x86_64/23.08
flatpak install -y flathub org.freedesktop.Platform.GStreamer.gstreamer-vaapi/x86_64/22.08
flatpak install -y flathub org.freedesktop.Platform.GStreamer.gstreamer-vaapi/x86_64/23.08


# Install Bottles
flatpak install -y flathub com.usebottles.bottles

# Allow Bottles to create application shortcuts
flatpak override --user --filesystem=xdg-data/applications com.usebottles.bottles

# Allow Bottles to access Steam folder
flatpak override --user --filesystem=home/.var/app/com.valvesoftware.Steam/data/Steam com.usebottles.bottles

# Install Breeze-GTK flatpak theme
flatpak install -y flathub org.gtk.Gtk3theme.Breeze

# Install applications
flatpak install -y flathub org.videolan.VLC

# Install Firefox from Flathub
flatpak install -y flathub org.mozilla.firefox

# Enable wayland support
flatpak override --user --socket=wayland --env=MOZ_ENABLE_WAYLAND=1 org.mozilla.firefox

# Temporarily open Firefox to create profiles
timeout 5 flatpak run org.mozilla.firefox --headless

# Set Firefox profile path
FIREFOX_PROFILE_PATH=$(realpath ${HOME}/.var/app/org.mozilla.firefox/.mozilla/firefox/*.default-release)

# Import extensions
mkdir -p ${FIREFOX_PROFILE_PATH}/extensions
curl https://addons.mozilla.org/firefox/downloads/file/4003969/ublock_origin-latest.xpi -o ${FIREFOX_PROFILE_PATH}/extensions/uBlock0@raymondhill.net.xpi
curl https://addons.mozilla.org/firefox/downloads/file/4018008/bitwarden_password_manager-latest.xpi -o ${FIREFOX_PROFILE_PATH}/extensions/{446900e4-71c2-419f-a6a7-df9c091e268b}.xpi
curl https://addons.mozilla.org/firefox/downloads/file/3998783/floccus-latest.xpi -o ${FIREFOX_PROFILE_PATH}/extensions/floccus@handmadeideas.org.xpi
curl https://addons.mozilla.org/firefox/downloads/file/3932862/multi_account_containers-latest.xpi -o ${FIREFOX_PROFILE_PATH}/extensions/@testpilot-containers.xpi

# KDE specific configurations
tee -a ${FIREFOX_PROFILE_PATH}/user.js << 'EOF'

// KDE integration
// https://wiki.archlinux.org/title/firefox#KDE_integration
user_pref("widget.use-xdg-desktop-portal.mime-handler", 1);
user_pref("widget.use-xdg-desktop-portal.file-picker", 1);
EOF

# Define an array of Flatpak application IDs
flatpak_apps=(
    "com.sindresorhus.Caprine"
    "org.gnome.Shotwell"
    "com.transmissionbt.Transmission"
    "com.anydesk.Anydesk"
    "me.kozec.syncthingtk"
    "com.github.zocker_160.SyncThingy"
    "com.microsoft.EdgeDev"
)

# Install applications
for app in "${flatpak_apps[@]}"; do
    flatpak install flathub "$app"
done
echo -e "\e[1;32m[✔]\e[0m Checking updates for installed flatpak programs...\n"
flatpak update -y
sleep 1

echo -e "\e[1;32m[✔]\e[0m Removing Old Flatpak Cruft...\n"
flatpak uninstall --unused
flatpak uninstall --delete-data

export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
# Check if the directory exists before attempting to remove it
if [ -d "/var/tmp/flatpak-cache-*" ]; then
    echo -e "\e[1;32m[✔]\e[0m Removing Old Flatpak Cruft...\n"
    sudo rm -rfv /var/tmp/flatpak-cache-*
else
    echo -e "\e[1;32m[✔]\e[0m No old Flatpak cruft found.\n"
fi


sleep 1

# Display all platpaks installed on system
flatpak --columns=app,name,size,installation list
echo -e "\e[1;32m[✔]\e[0m List of flatpaks on system...\n"


echo "Installation completed. You can now run the installed applications."
sleep 10
