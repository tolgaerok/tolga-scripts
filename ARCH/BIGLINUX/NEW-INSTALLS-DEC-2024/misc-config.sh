#!/usr/bin/env bash
# Tolga Erok
# 10/6/2024
# misc

flatpak install flathub io.github.aandrew_me.ytdn
flatpak run io.github.aandrew_me.ytdn

sudo systemctl enable --now smb.service nmb.service && sudo systemctl restart smb.service nmb.service

# grub
# GRUB_CMDLINE_LINUX="io_delay=none rootdelay=0 io_delay=none mitigations=off"
sudo grub-mkconfig -o /boot/grub/grub.cfg

# Google chrome
pamac build google-chrome

# install the recommended fonts.

sudo pacman -S noto-fonts
sudo pacman -S noto-fonts-cjk
sudo pacman -S noto-fonts-emoji
sudo pacman -S noto-fonts-extra

# Optional but highly recommended fonts

sudo pacman -S ttf-liberation
sudo pacman -S ttf-dejavu
sudo pacman -S ttf-roboto

# Available on the AUR
paru -S ttf-symbola

# Popular Monospaced Fonts
sudo pacman -S ttf-jetbrains-mono
sudo pacman -S ttf-fira-code
sudo pacman -S ttf-hack
sudo pacman -S adobe-source-code-pro-fonts
