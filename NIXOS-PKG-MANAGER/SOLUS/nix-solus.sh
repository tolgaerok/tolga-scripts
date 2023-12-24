#!/usr/bin/env bash

# tolga erok
# 25 Dec 2023

clear

# Ask for the username
read -p "Enter the username: " username

# setup nix pkgs on solus
cd /home/$username

sh <(curl -L https://nixos.org/nix/install) --no-daemon
. /home/$username/.nix-profile/etc/profile.d/nix.sh
nix --version

# Add the following lines to append export statements to .bashrc
echo 'export PATH="/home/$username/.nix-profile/bin:$PATH"' >> /home/$username/.bashrc
echo '. /home/$username/.nix-profile/etc/profile.d/nix.sh' >> /home/$username/.bashrc

# Create a default.nix file in the home directory
echo '{ pkgs ? import <nixpkgs> {} }: pkgs.mkShell { buildInputs = [ pkgs.nixpkgs-fmt ]; }' > /home/$username/default.nix

# Source the modified .bashrc to apply changes without restarting the shell
source /home/$username/.bashrc

# Verify that the changes took effect
nix --version
nix-shell
