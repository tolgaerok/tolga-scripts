#!/bin/bash

# Tolga Erok.
# My personal Fedora 39 flatpaks
# 23/11/2023

# Run from remote location:::.
# bash -c "$(curl -fsSL https://raw.githubusercontent.com/tolgaerok/tolga-scripts/main/Fedora39/FlatPakApps.sh)"

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

# Check if script is run as root
#if [ "$(id -u)" -ne 0 ]; then
#    echo "This script must be run as root. Please use sudo."
#    exit 0
#fi

# Prompt user for confirmation
read -p ")==> This script will install Flatpak applications and make system modifications. Do you want to continue? (y/n): " choice
if [[ ! "$choice" =~ ^[Yy]$ ]]; then
    echo "Installation aborted."
    exit 0
fi

[ ${UID} -eq 0 ] && read -p "Username: " user && export user || export user="$USER"

# Check whether if the windowing system is Xorg or Wayland
if [[ ${XDG_SESSION_TYPE} == "wayland" ]]; then
    export MOZ_ENABLE_WAYLAND=1
    export OBS_USE_EGL=1
fi

# QT/Kvantum theme
if [ -f /usr/bin/qt5ct ]; then
    export QT_QPA_PLATFORM="xcb"
    export QT_QPA_PLATFORMTHEME="qt5ct"
fi

# Check if Flatpak is installed
if ! command -v flatpak &>/dev/null; then
    echo "Flatpak is not installed. Please install Flatpak and run the script again."
    sleep 10
fi

# Add Flathub repository if not already added
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

# if lspci | grep VGA | grep "Intel" >/dev/null; then
flatpak install -y flathub org.freedesktop.Platform.VAAPI.Intel/x86_64/22.08
flatpak install -y flathub org.freedesktop.Platform.VAAPI.Intel/x86_64/23.08
# fi

# Install Flatpak runtimes
flatpak install -y flathub org.freedesktop.Platform.ffmpeg-full/x86_64/22.08
flatpak install -y flathub org.freedesktop.Platform.ffmpeg-full/x86_64/23.08
flatpak install -y flathub org.freedesktop.Platform.GStreamer.gstreamer-vaapi/x86_64/22.08
flatpak install -y flathub org.freedesktop.Platform.GStreamer.gstreamer-vaapi/x86_64/23.08

# Install Bottles
# flatpak install -y flathub com.usebottles.bottles

# Allow Bottles to create application shortcuts
# flatpak override --user --filesystem=xdg-data/applications com.usebottles.bottles

# Allow Bottles to access Steam folder
# flatpak override --user --filesystem=home/.var/app/com.valvesoftware.Steam/data/Steam com.usebottles.bottles

# Install Breeze-GTK flatpak theme
flatpak install -y flathub org.gtk.Gtk3theme.Breeze

# Install applications
flatpak install -y flathub org.videolan.VLC

# Install Firefox from Flathub
flatpak install -y flathub org.mozilla.firefox
# If flatpak, although it may not apply to your issue, but if you have Nvidia, set all varibles to true in about:config:
# gfx.webrender.all
# media.ffmpeg.vaapi.enabled
# widget.dmabuf.force-enabled

# Set Firefox about:config variables for Nvidia and Flatpak
# flatpak override --env=MOZ_ENABLE_WAYLAND=1 --env=GDK_BACKEND=x11 org.mozilla.firefox

# Enable wayland support
flatpak override --user --socket=wayland --env=MOZ_ENABLE_WAYLAND=1 org.mozilla.firefox

# Temporarily open Firefox to create profiles
flatpak run --user org.mozilla.firefox

# Run tasks as the invoking user
if [ "$EUID" -eq 0 ]; then
    echo "Switching to the invoking user..."
    sudo -u $(logname) bash <<'EOF'

    # Check if the profile directory is found
    FIREFOX_PROFILE_PATH=$(find "${HOME}/.mozilla/firefox" -name "*.default-release")
    if [ -z "$FIREFOX_PROFILE_PATH" ]; then
        echo -e "\nError: Firefox profile directory not found.\n"
    else
        echo -e "\nAll good, Firefox profile directory found\n"
        sleep 4
    fi

    # Check and set XDG_RUNTIME_DIR
    if [ -z "$XDG_RUNTIME_DIR" ]; then
        export XDG_RUNTIME_DIR="/run/user/$(id -u)"
    fi

EOF
fi

# Create or update the user.js file in the Firefox profile directory
cat <<EOL >"$FIREFOX_PROFILE_PATH/user.js"
// Firefox Preferences
user_pref("extensions.pocket.enabled", false);
user_pref("toolkit.telemetry.reportingpolicy.firstRun", false);
user_pref("toolkit.telemetry.enabled", false);
user_pref("media.peerconnection.enabled", false);
user_pref("geo.enabled", false);
user_pref("app.shield.optoutstudies.enabled", false);
user_pref("breakpad.reportURL", "");
user_pref("datareporting.healthreport.uploadEnabled", false);
user_pref("browser.newtabpage.activity-stream.feeds.section.topstories", false);
user_pref("browser.search.defaultenginename", "Google");
user_pref("webgl.disabled", False);
EOL

# Restart Firefox
flatpak run org.mozilla.firefox

# Disable D-Bus warnings in Firefox
# echo 'pref("toolkit.startup.max_resumed_crashes", -1);' >>${FIREFOX_PROFILE_PATH}/user.js
# echo 'pref("toolkit.startup.max_resumed_crashes", -1);' >>"${FIREFOX_PROFILE_PATH}/user.js"
echo 'pref("toolkit.startup.max_resumed_crashes", -1);' >>"${FIREFOX_PROFILE_PATH}/user.js"

# Import extensions
mkdir -p ${FIREFOX_PROFILE_PATH}/extensions
curl https://addons.mozilla.org/firefox/downloads/file/4003969/ublock_origin-latest.xpi -o ${FIREFOX_PROFILE_PATH}/extensions/uBlock0@raymondhill.net.xpi
curl https://addons.mozilla.org/firefox/downloads/file/4018008/bitwarden_password_manager-latest.xpi -o ${FIREFOX_PROFILE_PATH}/extensions/{446900e4-71c2-419f-a6a7-df9c091e268b}.xpi
curl https://addons.mozilla.org/firefox/downloads/file/3998783/floccus-latest.xpi -o ${FIREFOX_PROFILE_PATH}/extensions/floccus@handmadeideas.org.xpi
curl https://addons.mozilla.org/firefox/downloads/file/3932862/multi_account_containers-latest.xpi -o ${FIREFOX_PROFILE_PATH}/extensions/@testpilot-containers.xpi

# uBlock Origin - An efficient ad-blocker for various web browsers
curl https://addons.mozilla.org/firefox/downloads/file/420571/ublock_origin-latest.xpi -o ${FIREFOX_PROFILE_PATH}/extensions/ublock_origin@raymondhill.net.xpi

# SponsorBlock - Skip sponsored segments on YouTube
curl https://addons.mozilla.org/firefox/downloads/file/421708/sponsorblock_for_youtube_0.5.1_an+fx.xpi -o ${FIREFOX_PROFILE_PATH}/extensions/sponsorblock_for_youtube@spicetools.xpi

# Video Downloader PLUS - Download videos from popular websites
curl https://addons.mozilla.org/firefox/downloads/file/427463/video_downloader_plus-1.4.1-an+fx.xpi -o ${FIREFOX_PROFILE_PATH}/extensions/video_downloader_plus@andy.porter.xpi

# Decentraleyes - Protects you against tracking through "free", centralized, content delivery
curl https://addons.mozilla.org/firefox/downloads/file/503313/decentraleyes-latest.xpi -o ${FIREFOX_PROFILE_PATH}/extensions/decentraleyes@decentraleyes.org.xpi

# Privacy Possum - A privacy protection extension that detects and blocks surveillance trackers
curl https://addons.mozilla.org/firefox/downloads/file/556049/privacy_possum-latest.xpi -o ${FIREFOX_PROFILE_PATH}/extensions/privacy_possum@tohodo.com.xpi

# Auto Tab Discard - Automatically discards inactive tabs to free up system resources
curl https://addons.mozilla.org/firefox/downloads/file/573664/auto_tab_discard-latest.xpi -o ${FIREFOX_PROFILE_PATH}/extensions/auto_tab_discard@piro.sakura.ne.jp.xpi

# Disconnect - Visualizes and blocks the invisible sites that track your search and browsing history
curl https://addons.mozilla.org/firefox/downloads/file/442786/disconnect-latest.xpi -o ${FIREFOX_PROFILE_PATH}/extensions/disconnect@disconnect.me.xpi

# Canvas Blocker - Provides additional privacy protection by preventing canvas fingerprinting
curl https://addons.mozilla.org/firefox/downloads/file/432753/canvasblocker-latest.xpi -o ${FIREFOX_PROFILE_PATH}/extensions/canvasblocker@kkapsner.de.xpi

# User Agent Switcher and Manager - Switch user agents and manage custom user agent strings
curl https://addons.mozilla.org/firefox/downloads/file/683079/user_agent_switcher_and_manager-latest.xpi -o ${FIREFOX_PROFILE_PATH}/extensions/{2b10c1c8-a11f-4bad-fe9c-1c11e82cac42}.xpi

# Don't Track me Google - Prevents Google from tracking your searches and personalizing search results
curl https://addons.mozilla.org/firefox/downloads/file/557150/dont_track_me_google-latest.xpi -o ${FIREFOX_PROFILE_PATH}/extensions/dont_track_me_google@rob.xpi

# YouTube NonStop - Prevents YouTube videos from buffering and stops autoplay
curl https://addons.mozilla.org/firefox/downloads/file/416109/youtube_nonstop-latest.xpi -o ${FIREFOX_PROFILE_PATH}/extensions/youtube_nonstop@manizuca.xpi

# Facebook Container - Isolates your Facebook identity into a separate container
curl https://addons.mozilla.org/firefox/downloads/file/584616/facebook_container-latest.xpi -o ${FIREFOX_PROFILE_PATH}/extensions/facebook_container@mozilla.org.xpi

# Dark Reader - Enables dark mode on websites to reduce eye strain
curl https://addons.mozilla.org/firefox/downloads/file/436147/dark_reader-latest.xpi -o ${FIREFOX_PROFILE_PATH}/extensions/dark_reader@darkreader.org.xpi

# KDE specific configurations
tee -a ${FIREFOX_PROFILE_PATH}/user.js <<'EOF'

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
)

# Install applications
for app in "${flatpak_apps[@]}"; do
    flatpak install flathub "$app"
done

flatpak install flathub io.github.aandrew_me.ytdn

echo -e "\e[1;32m[✔]\e[0m Checking updates for installed flatpak programs...\n"
flatpak update -y
sleep 1

echo -e "\e[1;32m[✔]\e[0m Removing Old Flatpak Cruft...\n"
flatpak uninstall --unused
flatpak uninstall --delete-data

echo "#####################################"
echo
echo "Enabling Flatpak Theming Overrides"
echo

# Check and set XDG_RUNTIME_DIR
if [ -z "$XDG_RUNTIME_DIR" ]; then
    export XDG_RUNTIME_DIR="/run/user/$(id -u)"
fi

# Enable the flathub remote (which is disabled by default)
flatpak remote-modify --enable flathub

sudo flatpak override --filesystem=$HOME/.themes
sudo flatpak override --env=GTK_MODULES=colorreload-gtk-module org.mozilla.firefox
sudo flatpak override --filesystem=xdg-config/gtk-4.0:ro
sudo flatpak override --filesystem=xdg-config/gtk-3.0:ro

sudo flatpak override --env=gfx.webrender.all=true \
    --env=media.ffmpeg.vaapi.enabled=true \
    --env=widget.dmabuf.force-enabled=true \
    org.mozilla.firefox

# export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
# Check if the directory exists before attempting to remove it
if [ -d "/var/tmp/flatpak-cache-*" ]; then
    echo -e "\e[1;32m[✔]\e[0m Removing Old Flatpak Cruft...\n"
    sudo rm -rfv /var/tmp/flatpak-cache-*
else
    echo -e "\e[1;32m[✔]\e[0m No old Flatpak cruft found.\n"
fi

clear && echo -e "\e[1;32m[✔]\e[0m Checking updates for installed flatpak programs...\n"
sudo flatpak update -y
sleep 2

clear && echo -e "\e[1;32m[✔]\e[0m Removing Old Flatpak Cruft...\n"
flatpak uninstall --unused
flatpak uninstall --delete-data
sudo rm -rfv /var/tmp/flatpak-cache-*

[ -f /usr/bin/flatpak ] && flatpak uninstall --unused --delete-data --assumeyes

sleep 1

# systemctl status dbus
# sudo systemctl start dbus

# Display all platpaks installed on system
flatpak --columns=app,name,size,installation list
echo -e "\e[1;32m[✔]\e[0m List of flatpaks on system...\n"

echo "Installation completed. You can now run the installed applications."
sleep 10
