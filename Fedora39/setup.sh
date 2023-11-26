#!/bin/bash
# Tolga erok
# my personal fedora39 setup file

# Define URLs
DESKTOP_FILE_URL="https://raw.githubusercontent.com/tolgaerok/tolga-scripts/main/Fedora39/my-online-fedora.desktop"
MY_TOOLS_URL="https://raw.githubusercontent.com/tolgaerok/tolga-scripts/main/Fedora39/MY-TOOLS.zip"

# Paths
DESKTOP_FILE_DEST="$HOME/Desktop/my-online-fedora.desktop"
MY_TOOLS_DEST="$HOME/.config/MY-TOOLS"

# Download and copy desktop file
curl -o "$DESKTOP_FILE_DEST" "$DESKTOP_FILE_URL"

# Download MY-TOOLS folder
wget -O /tmp/MY-TOOLS.zip "$MY_TOOLS_URL"

# Create MY-TOOLS directory if it doesn't exist
mkdir -p "$HOME/.config/MY-TOOLS"

# Extract MY-TOOLS folder to ~/.config/
unzip -q -o "/tmp/MY-TOOLS.zip" -d "$HOME/.config/"

# Set permissions
chmod +x "$DESKTOP_FILE_DEST"
chmod -R +xw "$HOME/.config/MY-TOOLS"

# Clean up
rm /tmp/MY-TOOLS.zip

echo "Files copied and permissions set successfully."
