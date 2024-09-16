#!/bin/bash
# Tolga Erok
# 16 Sep 2024

# Define colors and symbols
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
WHITE='\033[1;37m' # Bright white for Flatpak names
NC='\033[0m'       # No Color
TICK='\u2714'      # Unicode for check mark
RED='\033[0;31m'   # Red for error messages

clear

# Remote flatpak list (my personal collection)
FLATPAK_LIST=$(curl -s https://raw.githubusercontent.com/tolgaerok/tolga-scripts/main/FEDORA-40/flatpaks | tr '\n' ' ')

# Add Flathub remote repository if it doesn't already exist
echo -e "${YELLOW}Adding Flathub repository if not present...${NC}"
flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo

# Install or update the Flatpaks from my list
echo -e "${YELLOW}****************************************************${NC}"
echo -e "${RED}Installing or updating Flatpaks from Tolga's list...${NC}"
echo -e "${YELLOW}****************************************************${NC}\n"
for app in $FLATPAK_LIST; do
    if [ -n "$app" ]; then
        echo -e "${YELLOW}Processing: ${WHITE}$app${NC}"
        flatpak --system -y install --or-update flathub "$app" >/dev/null 2>&1
        if [ $? -eq 0 ]; then
            echo -e "${GREEN}[$TICK] Successfully installed or updated: ${WHITE}$app${NC}\n"
        else
            echo -e "${RED}✘ Failed to process: ${WHITE}$app${NC}\n"
        fi
    fi
done

# Check & Install Distrobox if not already installed
if ! command -v distrobox &>/dev/null; then
    echo -e "${YELLOW}Installing Distrobox...${NC}"
    curl -s https://raw.githubusercontent.com/89luca89/distrobox/main/install | sudo sh
    sudo dnf copr enable alciregi/distrobox
    sudo dnf install -y distrobox
else
    echo -e "${GREEN}Distrobox is already installed.${NC}\n"
fi

# check if Firefox is installed as a Flatpak
is_firefox_flatpak_installed() {
    flatpak list | grep -q 'org.mozilla.firefox'
}

# apply the overrides to Firefox
apply_firefox_overrides() {
    echo "Applying overrides for Firefox..."
    flatpak override --user --socket=wayland --env=MOZ_ENABLE_WAYLAND=1 org.mozilla.firefox
    flatpak override --user --env=gfx.webrender.all=true \
                      --env=media.ffmpeg.vaapi.enabled=true \
                      --env=widget.dmabuf.force-enabled=true \
                      org.mozilla.firefox
    echo "Overrides applied."
}

if is_firefox_flatpak_installed; then
    apply_firefox_overrides
else
    echo "Firefox Flatpak is not installed."
fi

# Flatpak packages for type of gpu on device
gpu_related_flatpaks() {
    local gpu_type="$1"
    
    case "$gpu_type" in
        intel)
            echo -e "${GREEN}[$TICK] Detected Intel GPU. Installing Intel VAAPI runtime and multimedia packages ${NC}\n"
            flatpak install -y flathub org.freedesktop.Platform.VAAPI.Intel/x86_64/22.08
            flatpak install -y flathub org.freedesktop.Platform.ffmpeg-full/x86_64/22.08
            flatpak install -y flathub org.freedesktop.Platform.GStreamer.gstreamer-vaapi/x86_64/23.08
        ;;
        nvidia)
            echo -e "${GREEN}[$TICK] Detected NVIDIA GPU. Installing multimedia packages ${NC}\n"
            flatpak install -y flathub org.freedesktop.Platform.ffmpeg-full/x86_64/22.08
        ;;
        *)
            echo -e "${RED}✘ Unknown GPU type. No packages will be installed ${NC}\n"
        ;;
    esac
}

# Detect GPU type
detect_gpu() {
    if lspci | grep -i "VGA" | grep -i "Intel" >/dev/null; then
        echo "intel"
        elif lspci | grep -i "VGA" | grep -i "NVIDIA" >/dev/null; then
        echo "nvidia"
    else
        echo "unknown"
    fi
}

# gpu_related_flatpaks execute
gpu_type=$(detect_gpu)
gpu_related_flatpaks "$gpu_type"

# Enable the flathub remote (which is disabled by default)
flatpak remote-modify --enable flathub

echo -e "${GREEN}All operations completed.${NC}\n"

