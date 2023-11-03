#!/bin/bash

# Tolga Erok

password=$1

touch ~/.bashrc
echo $password | sudo -S sudo rm -fr /etc/nixos/configuration.nix
echo $password | sudo -S sudo cp ./NixOS-SETUP/plasma/* /etc/nixos/

export NIXPKGS_ALLOW_UNFREE=1
nix-channel --update
nix-env -u

source ~/.bashrc

mkdir -p ~/.themes
mkdir -p ~/.icons
mkdir -p ~/.backgrounds
cp ./wallpapers/* ~/.backgrounds/
unzip -d ~/.themes/ ./NixOS-SETUP/themes/WhiteSur-dark.zip
unzip -d ~/.icons/ ./NixOS-SETUP/icons/capitaine-cursors.zip
unzip -d ~/.icons/ ./NixOS-SETUP/icons/BigSur.zip
unzip -d ~/.icons/ ./NixOS-SETUP/icons/BigSur-dark.zip
unzip -d ~/.icons/ ./NixOS-SETUP/icons/Win11.tar.xz

echo $password | sudo -S sudo git clone https://github.com/romkatv/powerlevel10k.git $ZSH_CUSTOM/icons/powerlevel10k
curl -L http://install.ohmyz.sh | sh

# Install fonts
fontsDir="${XDG_DATA_HOME:-$HOME/.local/share}/fonts"
mkdir -p "$fontsDir"
cp ./NixOS-SETUP/fonts/* "$fontsDir"
fc-cache -f -v "$fontsDir"

echo $password | sudo -S sudo nix-collect-garbage -d
echo $password | sudo -S sudo nixos-rebuild switch
echo "  __  __      ___ "
echo " /  )/  )/| )(_   "
echo "/(_/(__// |/ /__  "
echo "                  "
echo "Start tailscale using sudo tailscale up" && sleep 1
echo "Rebooting in 5 seconds" && sleep 1
echo "Rebooting in 4 seconds" && sleep 1
echo "Rebooting in 3 seconds" && sleep 1
echo "Rebooting in 2 seconds" && sleep 1
echo "Rebooting in 1 second" && sleep 1
echo $password | sudo -S sudo reboot
