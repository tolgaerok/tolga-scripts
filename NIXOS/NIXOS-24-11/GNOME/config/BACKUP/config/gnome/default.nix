{ lib, config, pkgs, ... }:

with lib; {
  imports = [
    # USE NIX FMT ONLINE: https://nixfmt.serokell.io/
    ./gnome-packages.nix
  ];

  # Enable the GNOME Desktop Environment.
  services = {
    xserver = {
      displayManager.gdm.enable = true;
      desktopManager.gnome.enable = true;
    };
  };
  xdg.portal = {
    enable = true;
    xdgOpenUsePortal = true;
    extraPortals = with pkgs; [ 
      xdg-desktop-portal-gnome 
    ];
  };
}
