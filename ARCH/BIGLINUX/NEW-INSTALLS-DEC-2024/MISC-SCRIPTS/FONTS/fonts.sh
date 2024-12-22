#!/usr/bin/env bash

# Metadata
# ----------------------------------------------------------------------------
AUTHOR="Tolga Erok"
VERSION="1"
DATE_CREATED="22/12/2024"

# Configuration to install custom fonts
# ----------------------------------------------------------------------------

# print formatted headers
print_header() {
  clear
  echo -e "\n\033[94m=============================\033[0m"
  echo -e "\033[1;94m$1\033[0m"
  echo -e "\033[94m=============================\033[0m\n"
}

# install packages with a message
install_packages() {
  local msg="$1"
  shift
  echo -e "\033[92m$msg\033[0m"
  for package in "$@"; do
    echo -e "  - Installing \033[93m$package\033[0m..."
    sudo pacman -S --noconfirm "$package"
  done
  echo
}

# AUR installations with a message
install_aur() {
  local msg="$1"
  shift
  echo -e "\033[92m$msg\033[0m"
  for package in "$@"; do
    echo -e "  - Installing \033[93m$package\033[0m from AUR..."
    paru -S --noconfirm "$package"
  done
  echo
}

# Main script
print_header "Installing Recommended Fonts"
install_packages "Recommended fonts for comprehensive coverage:" \
  noto-fonts noto-fonts-cjk noto-fonts-emoji noto-fonts-extra

print_header "Optional but Highly Recommended Fonts"
install_packages "Adding optional but highly recommended fonts for broader compatibility:" \
  ttf-liberation ttf-dejavu ttf-roboto

print_header "Fonts Available on the AUR"
install_aur "Installing fonts available on the Arch User Repository:" \
  ttf-symbola

print_header "Popular Monospaced Fonts"
install_packages "Enhancing your experience with popular monospaced fonts:" \
  ttf-jetbrains-mono ttf-fira-code ttf-hack adobe-source-code-pro-fonts

echo -e "\033[92mFont installation complete!\033[0m"
