{ config, pkgs, ... }:

{
  imports = [
    # Initialize tmpfs parameters
    # ./tmpfs
  ];

  #---------------------------------------------------------------------
  # PLASMA 6
  #---------------------------------------------------------------------
  # Enable the KDE Plasma Desktop Environment.
  services = {
    displayManager.sddm.enable = true;
    desktopManager.plasma6.enable = true;
  };
  # services.xserver = {
  #  enable = true;
  #  displayManager.sddm.enable = true;
  #  desktopManager.plasma6.enable = true;
  # };
  # services.xserver.displayManager.sddm.wayland.enable = true;

  #---------------------------------------------------------------------
  # PLASMA 5
  #---------------------------------------------------------------------
  # services.xserver = {       
  #     desktopManager.plasma5.enable = true;      
  #   };
}

#---------------------------------------------------------------------
# Original Configuration for Reference
#---------------------------------------------------------------------
# Bootloader.
# boot.loader.systemd-boot.enable = true;
# boot.loader.efi.canTouchEfiVariables = true;

