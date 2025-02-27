{ 
config, 
pkgs, 
... 
}:

{
  #---------------------------------------------------------------------
  # Flatpak Setup
  #---------------------------------------------------------------------
  imports = [ 
  	./flatpak-auto-update.nix 
   ];

  services.flatpak.enable = true;

  # Ensure the Flathub repository is added
  systemd.services.flatpak-repo = {
    description = "Add Flathub repository for Flatpak";
    wantedBy = [ "multi-user.target" ];
    after = [ "network-online.target" ];
    requires = [ "network-online.target" ];
    path = [ pkgs.flatpak ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = "${pkgs.flatpak}/bin/flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo";
    };
  };

  # Install the Adwaita & Yaru GTK themes for NixOS
  environment.systemPackages = with pkgs; [
    adw-gtk3
    yaru-theme
  ];

  # Automatically install the Flatpak themes
  systemd.services.install-flatpak-themes = {
    description = "Install Adw-GTK3 and Yaru themes for Flatpak";
    wantedBy = [ "multi-user.target" ];
    after = [ "network-online.target" "flatpak.service" ];
    requires = [ "network-online.target" "flatpak.service" ];
    path = [ pkgs.flatpak ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = pkgs.writeShellScript "install-flatpak-themes" ''
        # Ensure Flatpak is initialized
        flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

        # Install themes from Flathub
        flatpak install -y flathub org.gtk.Gtk3theme.adw-gtk3
        flatpak install -y flathub org.gtk.Gtk3theme.adw-gtk3-dark
        flatpak install -y flathub org.gtk.Gtk3theme.yaru

        # Set the default Flatpak theme
        flatpak override --user --env=GTK_THEME=adw-gtk3
      '';
    };
  };
}
