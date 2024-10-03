## Personal flatpaks

```bash
#!/bin/bash
# Tolga Erok
# 21 Jun 2024


# Add Flathub remote repository if it doesn't already exist
flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo

# Install specified Flatpak applications from Flathub
flatpak install flathub com.wps.Office -y
flatpak install flathub com.mattjakeman.ExtensionManager -y
flatpak install flathub com.sindresorhus.Caprine -y
flatpak install flathub com.github.tchx84.Flatseal -y
flatpak install flathub io.github.flattool.Warehouse -y
flatpak install flathub org.flameshot.Flameshot -y

echo "All specified Flatpak applications have been installed successfully."



```
