{ config, pkgs, ... }:

{
  imports = [
    # Initialize tmpfs parameters
    # ./tmpfs
  ];

  #---------------------------------------------------------------------
  # Bootloader - EFI
  #---------------------------------------------------------------------
  boot.loader = {
    efi.canTouchEfiVariables = true;  # Enables the ability to modify EFI variables.
    systemd-boot = {
      enable = true;                  # Activates the systemd-boot bootloader.
      editor = true;
    };
  };

  boot.initrd = {
    systemd.enable = true;  # Enables systemd services in the initial ramdisk (initrd).
    verbose = false;        # Silent boot
  };

  boot.plymouth = {
    enable = true;         # Activates the Plymouth boot splash screen.
    theme = "breeze";      # Sets the Plymouth theme to "breeze."
  };
}

#---------------------------------------------------------------------
# Original Configuration for Reference
#---------------------------------------------------------------------
# Bootloader.
# boot.loader.systemd-boot.enable = true;
# boot.loader.efi.canTouchEfiVariables = true;
