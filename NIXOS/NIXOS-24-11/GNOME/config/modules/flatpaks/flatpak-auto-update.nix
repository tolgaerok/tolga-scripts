{ 
config, 
pkgs, 
... 
}:

{
  #---------------------------------------------------------------------
  # Flatpak Automatic Updates
  #---------------------------------------------------------------------
  systemd.services.flatpak-update = {
    description = "Tolga's Flatpak Automatic Update";
    documentation = [ "man:flatpak(1)" ];
    wants = [ "network-online.target" ];
    after = [ "network-online.target" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.flatpak}/bin/flatpak update -y";
    };
    wantedBy = [ "multi-user.target" ];
  };

  systemd.timers.flatpak-update = {
    description = "Tolga's Flatpak Automatic Update Trigger";
    documentation = [ "man:flatpak(1)" ];
    timerConfig = {
      OnBootSec = "5m";
      OnCalendar = "0/6:00:00"; # Every 6 hours
      Persistent = true;
    };
    wantedBy = [ "timers.target" ];
  };
}

