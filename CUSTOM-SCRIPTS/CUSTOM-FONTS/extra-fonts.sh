#!/bin/bash

# Tolga Erok
# 24/2/24

sudo dnf install ibm-plex-mono-fonts ibm-plex-sans-fonts ibm-plex-serif-fonts \
    redhat-display-fonts redhat-text-fonts \
    lato-fonts \
    jetbrains-mono-fonts \
    fira-code-fonts mozilla-fira-mono-fonts mozilla-fira-sans-fonts mozilla-zilla-slab-fonts \
    adobe-source-serif-pro-fonts adobe-source-sans-pro-fonts \
    intel-clear-sans-fonts intel-one-mono-fonts

sudo dnf install curl cabextract xorg-x11-font-utils fontconfig
sudo rpm -i https://downloads.sourceforge.net/project/mscorefonts2/rpms/msttcore-fonts-installer-2.6-1.noarch.rpm
