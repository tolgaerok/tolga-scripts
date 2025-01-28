#!/usr/bin/env bash
# Tolga Erok

# check dependencies 
if ! command -v curl &> /dev/null || ! command -v tar &> /dev/null; then
    echo "Error: curl and tar are required but not installed."
    exit 1
fi

# Create fonts directory
mkdir -p ~/.local/share/fonts
ln -sf ~/.local/share/fonts/ ~/.fonts

# change to fonts directory
cd ~/.fonts || exit 1

# Check if font is already installed
if [ -d "Hack" ]; then
    echo "Hack Nerd Font is already installed."
    exit 0
fi

# Download and extract font
FONT_URL="https://github.com/ryanoasis/nerd-fonts/releases/latest/download/Hack.tar.xz"
echo "Downloading Hack Nerd Font..."
curl -OL "$FONT_URL"

echo "Extracting font..."
tar -xvf Hack.tar.xz

# clean up
rm -f Hack.tar.xz

# Refresh font cache
fc-cache -fv

echo "Hack Nerd Font installed successfully!"



# ORIGINAL = 'Droid Sans Mono', 'monospace', monospace
# ....  'Cascadia Code', 'Droid Sans Mono', 'monospace','Hack Nerd Font',monospace