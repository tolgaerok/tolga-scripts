#!/bin/bash
# tolga erok
# 28/12/24
# gaming setup - manjaro

# Update system first
echo "Updating system..."
sudo pacman -Syu --noconfirm

# essential gaming packages
echo "Installing essential gaming packages..."
sudo pacman -S --noconfirm \
    alsa-lib \
    alsa-plugins \
    dosbox \
    gamemode \
    gamescope \
    giflib \
    glfw-x11 \
    gnutls \
    gst-plugins-base-libs \
    gtk2 \
    gtk2+extra \
    gtk3 \
    lib32-alsa-lib \
    lib32-alsa-plugins \
    lib32-fontconfig \
    lib32-giflib \
    lib32-gnutls \
    lib32-gst-plugins-base \
    lib32-gst-plugins-base-libs \
    lib32-gst-plugins-good \
    lib32-gtk2 \
    lib32-gtk3 \
    lib32-libgcrypt \
    lib32-libgpg-error \
    lib32-libjpeg-turbo \
    lib32-libldap \
    lib32-libpng \
    lib32-libxcb \
    lib32-libpulse \
    lib32-libva \
    lib32-libxcomposite \
    lib32-libxinerama \
    lib32-libxslt \
    lib32-libxss \
    lib32-mangohud \
    lib32-mesa \
    lib32-mpg123 \
    lib32-ncurses \
    lib32-openal \
    lib32-sqlite \
    lib32-v4l-utils \
    lib32-vkd3d \
    lib32-vulkan-icd-loader \
    libgcrypt \
    libgpg-error \
    libinput \
    libjpeg-turbo \
    libldap \
    libpng \
    libpulse \
    libva \
    libxcb \
    libxcomposite \
    libxinerama \
    libxslt \
    lutris \
    mangohud \
    mesa \
    mpg123 \
    ncurses \
    openal \
    samba \
    sqlite \
    steam \
    steam-native-runtime \
    systemd-libs \
    ttf-liberation \
    v4l-utils \
    vkd3d \
    vulkan-icd-loader \
    wine-gecko \
    wine-mono \
    wine-staging \
    winetricks \
    wqy-zenhei \
    xf86-input-libinput

# optional packages (if desired)
echo "Installing optional packages..."
sudo pacman -S --noconfirm \
    bottles \
    cups \
    protontricks \
    sane

echo "Installation complete. Enjoy your gaming setup!"
