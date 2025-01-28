#!/usr/bin/env bash
# Tolga Erok

mkdir -p ~/.local/share/fonts
ln -s ~/.local/share/fonts/ ~/.fonts
cd ~/.fonts
curl -OL https://github.com/ryanoasis/nerd-fonts/releases/latest/download/Hack.tar.xz
tar -xvf Hack.tar.xz


# ORIGINAL = 'Droid Sans Mono', 'monospace', monospace
# ....  'Cascadia Code', 'Droid Sans Mono', 'monospace','Hack Nerd Font',monospace