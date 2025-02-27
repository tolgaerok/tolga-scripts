{
  config,
  pkgs,
  lib,
  ...
}:

with lib;
let

in
{
  # ---------------------------------------------
  # SYSTEM WIDE GNOME PACKAGES
  # ---------------------------------------------
  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    #  vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    #  wget
    gnomeExtensions.appindicator
    gnomeExtensions.blur-my-shell
    gnomeExtensions.burn-my-windows
    gnomeExtensions.compact-top-bar
    gnomeExtensions.custom-accent-colors
    gnomeExtensions.dash-to-panel
    gnome-extension-manager
    gnomeExtensions.gtile
    gnomeExtensions.just-perfection
    gnomeExtensions.tray-icons-reloaded
    gnomeExtensions.vitals
    gradience
    pkgs.gnome-tweaks
    pkgs.dconf-editor
    gnomeExtensions.logo-menu
    gnomeExtensions.mock-tray
    
    xdg-desktop-portal
    xdg-desktop-portal-gtk
    xdg-desktop-portal-gnome
    
    # ---- OUT OF SERVICE ---- #
    #gnomeExtensions.arcmenu
    #gnomeExtensions.gesture-improvements
    #gnomeExtensions.paperwm
    #gnomeExtensions.rounded-window-corners

  ];
}


