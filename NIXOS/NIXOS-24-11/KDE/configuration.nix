# Tolga Erok
# 23/02/2025
# My personal NIXOS KDE configuration 
# 
#              ¯\_(ツ)_/¯
#   ███▄    █     ██▓   ▒██   ██▒    ▒█████       ██████ 
#   ██ ▀█   █    ▓██▒   ▒▒ █ █ ▒░   ▒██▒  ██▒   ▒██    ▒ 
#  ▓██  ▀█ ██▒   ▒██▒   ░░  █   ░   ▒██░  ██▒   ░ ▓██▄   
#  ▓██▒  ▐▌██▒   ░██░    ░ █ █ ▒    ▒██   ██░     ▒   ██▒
#  ▒██░   ▓██░   ░██░   ▒██▒ ▒██▒   ░ ████▓▒░   ▒██████▒▒
#  ░ ▒░   ▒ ▒    ░▓     ▒▒ ░ ░▓ ░   ░ ▒░▒░▒░    ▒ ▒▓▒ ▒ ░
#  ░ ░░   ░ ▒░    ▒ ░   ░░   ░▒ ░     ░ ▒ ▒░    ░ ░▒  ░ ░
#     ░   ░ ░     ▒ ░    ░    ░     ░ ░ ░ ▒     ░  ░  ░  
#           ░     ░      ░    ░         ░ ░           ░  
#  
#------------------ HP EliteDesk 800 G4 SFF ------------------------

# BLUE-TOOTH        REALTEK 5G
# CPU	              Intel(R) Core(TM)  i7-8700 CPU @ 3.2GHz - 4.6Ghz (Turbo) x 6 (vPro)
# MODEL             HP EliteDesk 800 G4 SFF
# MOTHERBOARD	      Intel Q370 PCH-H—vPro
# NETWORK	          Intel Corporation Wi-Fi 6 AX210/AX211/AX411 160MHz
# PSU               250W
# RAM	              Maximum: 64 GB, DDR4-2666 (16 GB x 4)
# STORAGE           256 GB, M.2 2280, PCIe NVMe SSD
# d-GPU             NVIDIA GeForce GT 1030/PCIe/SSE2
# i-GPU	            Intel UHD Graphics 630, Coffee Lake 
# EXPENSION SLOTS   (1) M.2 PCIe x1 2230 (for WLAN), (2) M.2 PCIe x4 2280/2230 combo (for storage)
#                   (2) PCI Express v3.0 x1, (1) PCI Express v3.0 x16 (wired as x4), (1) PCI Express v3.0 x16
# SOURCE            https://support.hp.com/au-en/document/c06047207

#---------------------------------------------------------------------
{ config, pkgs, lib, ... }:

with lib; {
  imports = [
    # USE NIX FMT ONLINE:           https://nixfmt.serokell.io/
    ./config
    ./hardware-configuration.nix
  ];

  #---------------------------------------------------------------------
  # Allow unfree packages
  #---------------------------------------------------------------------
  environment.sessionVariables.NIXPKGS_ALLOW_UNFREE = "1";

  system = {
    stateVersion = "24.11"; # Did you read the comment?
    copySystemConfiguration = true;
    autoUpgrade = {
      enable = true;
      operation = "boot";
      dates = "Mon 04:40";
      channel = "https://nixos.org/channels/nixos-unstable";
      allowReboot = false;
    };
  };
}

