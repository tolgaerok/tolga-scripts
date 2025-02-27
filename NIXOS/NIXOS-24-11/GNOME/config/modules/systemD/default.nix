{ 
config, 
pkgs, 
... 
}:

{
  # ---------------------------------------------------------------------
  # Add a systemd tmpfiles rule that creates a directory /var/spool/samba
  # with permissions 1777 and ownership set to root:root.
  # ---------------------------------------------------------------------
  # Create Share1 and Share2 directories in each user's home directory using systemd tmpfiles #
  systemd = {
    tmpfiles.rules = [
      "D! /tmp 1777 root root 0"
      "d /home/tolga/Share1 0775 tolga users -"
      "d /home/tolga/Share2 0775 tolga users -"
      "d /home/tolga/Documents/MEGA 0775 tolga samba -"
      "d /var/spool/samba 1777 root root -"      
      "r! /tmp/**/*"
    ];
    # Default timeout for stopping services managed by systemd to 10 seconds
    extraConfig = ''
      DefaultLimitNOFILE=1048576
      DefaultTimeoutStopSec=3s
    '';
    # When a program crashes, systemd will create a core dump file, typically in the /var/lib/systemd/coredump/ directory.
    coredump.enable = true;
  };
}  

# sudo chown -R $(whoami):$(id -gn) /etc/nixos && sudo chmod -R 777 /etc/nixos && sudo chmod +x /etc/nixos/* && export NIXPKGS_ALLOW_INSECURE=1

