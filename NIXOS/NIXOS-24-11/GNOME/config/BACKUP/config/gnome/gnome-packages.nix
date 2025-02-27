{ config, pkgs, lib, ... }:

with lib;
let

in {
  # ---------------------------------------------
  # SYSTEM WIDE GNOME PACKAGES
  # ---------------------------------------------
  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    #  vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    #  wget
    gnome-extension-manager
    gnomeExtensions.appindicator
    gnomeExtensions.blur-my-shell
    gnomeExtensions.burn-my-windows
    gnomeExtensions.compact-top-bar
    gnomeExtensions.custom-accent-colors
    gnomeExtensions.dash-to-panel
    gnomeExtensions.gtile
    gnomeExtensions.just-perfection
    gnomeExtensions.logo-menu
    gnomeExtensions.mock-tray
    gnomeExtensions.tray-icons-reloaded
    gnomeExtensions.vitals
    gradience
    pkgs.dconf-editor
    pkgs.gnome-tweaks

    xdg-desktop-portal
    xdg-desktop-portal-gnome
    xdg-desktop-portal-gtk

    # ---- OUT OF SERVICE ---- #
    #gnomeExtensions.arcmenu
    #gnomeExtensions.gesture-improvements
    #gnomeExtensions.paperwm
    #gnomeExtensions.rounded-window-corners

  ];
}

