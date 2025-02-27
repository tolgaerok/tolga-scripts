{ config, pkgs, ... }: {

  services = {
    xserver = {
      # Enable the Cinnamon Desktop Environment.
      displayManager.lightdm.enable = true;
      desktopManager.cinnamon.enable = true;
    };
  };
}
