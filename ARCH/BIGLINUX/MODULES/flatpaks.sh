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
DE=$(echo $XDG_CURRENT_DESKTOP | tr '[:upper:]' '[:lower:]')

# Check if GNOME or other BS DE
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
        sudo flatpak install --assumeyes --noninteractive flathub org.virt_manager.virt-manager \
        app/io.github.aandrew_me.ytdn/x86_64/stable \
        app/io.github.flattool.Warehouse/x86_64/stable \
        app/org.gnome.NautilusPreviewer/x86_64/stable \
        app/io.missioncenter.MissionCenter/x86_64/stable 

        # etc etc etc
    fi
fi

echo "Installation complete!"
