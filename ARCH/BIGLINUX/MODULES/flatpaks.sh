#!/bin/bash
# tolga erok
# 14/3/25

# Install Repo
echo "Adding Flathub repository..."
sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo || {
    echo "Failed to add Flathub repository"
    exit 1
}
sudo flatpak remote-modify --enable flathub || {
    echo "Failed to enable Flathub repository"
    exit 1
}

# Install Flatseal
echo "Installing Flatseal..."
sudo flatpak install --assumeyes --noninteractive flathub com.github.tchx84.Flatseal || {
    echo "Failed to install Flatseal"
    exit 1
}

# Detect the Desktop Environment (DE)
DE=$(echo $XDG_CURRENT_DESKTOP | tr '[:upper:]' '[:lower:]') # Converts to lowercase for consistency

# Check if GNOME or other
if [[ "$DE" == "gnome" ]]; then
    echo "Detected GNOME. Installing GNOME-specific packages..."
    sudo flatpak install --assumeyes --noninteractive flathub org.gtk.Gtk3theme.adw-gtk3 \
        flathub org.gtk.Gtk3theme.adw-gtk3-dark \
        flathub com.mattjakeman.ExtensionManager \
        flathub me.dusansimic.DynamicWallpaper || {
        echo "Failed to install GNOME-Flatpak packages"
        exit 1
    }
else
    echo "Detected $DE. Skipping GNOME-specific installation."
    if [[ "$DE" == "kde" ]]; then
        echo "Detected KDE. Installing KDE-packages..."
        # etc etc etc
    fi
fi

echo "Installation complete!"
