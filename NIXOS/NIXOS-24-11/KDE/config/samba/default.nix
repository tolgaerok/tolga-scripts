{ config, pkgs, lib, ... }:

let
  username = "tolga";
in
{  
  # ---------------------------------------------------------------------
  # Add a systemd tmpfiles rule that creates a directory /var/spool/samba
  # with permissions 1777 and ownership set to root:root.
  # ---------------------------------------------------------------------

  # Create Share1 and Share2 directories in each user's home directory using systemd tmpfiles #
  systemd = {
    tmpfiles.rules = [
      "d /home/tolga/Share1 0775 tolga users -"
      "d /home/tolga/Share2 0775 tolga users -"
      "D! /tmp 1777 root root 0"
      "d /var/spool/samba 1777 root root -"
      "r! /tmp/**/*"
    ];

    # Default timeout for stopping services managed by systemd to 10 seconds
    extraConfig = "DefaultTimeoutStopSec=10s";

    # When a program crashes, systemd will create a core dump file, typically in the /var/lib/systemd/coredump/ directory.
    coredump.enable = true;
  };

  # Samba Service Configuration
  services.samba = {
    enable = true;
    package = pkgs.sambaFull;  # Using full Samba package for printing support
    securityType = "user";
    openFirewall = true;

    # Samba Global Settings
    settings = {
      global = {
        "workgroup" = "WORKGROUP";
        "server string" = "pussy";
        "netbios name" = "CUNT";
        "wins support" = "yes";
        "passdb backend" = "tdbsam";
        "security" = "user";
        "hosts allow" = "192.168.0. 127.0.0.1 localhost";
        "hosts deny" = "0.0.0.0/0";
        "aio read size" = "16384";
        "aio write size" = "16384";
        "client max protocol" = "SMB3";
        "client min protocol" = "COREPLUS";
        "kernel oplocks" = "yes";
        "level2 oplocks" = "yes";
        "max xmit" = "65535";
        "min receivefile size" = "16384";
        "oplocks" = "yes";
        "read raw" = "yes";
        "socket options" = "TCP_NODELAY IPTOS_LOWDELAY SO_RCVBUF=131072 SO_SNDBUF=131072";
        "write raw" = "yes";
        "guest account" = "nobody";
        "map to guest" = "bad user";
        "load printers" = "yes";
        "printing" = "cups";
        "printcap name" = "cups";
        "cups options" = "raw";
      };

      # Samba Shares Configuration
      "homes" = {
        "comment" = "Home Directories";
        "valid users" = "%S, %D%w%S";
        "browseable" = "no";
        "read only" = "no";
        "inherit acls" = "yes";
      };

      "Public" = {
        "path" = "/home/tolga/Public";
        "browseable" = "yes";
        "read only" = "no";
        "guest ok" = "yes";
        "create mask" = "0644";
        "directory mask" = "0755";
        "force user" = "tolga";
        "force group" = "users";
      };

      "Mega" = {
        "path" = "/home/tolga/Documents/MEGA";
        "browseable" = "yes";
        "read only" = "no";
        "guest ok" = "yes";
        "create mask" = "0644";
        "directory mask" = "0755";
        "force user" = "tolga";
        "force group" = "users";
      };
    };
  };

  # Samba Web Service Discovery (Optional)
  services.samba-wsdd = {
    enable = true;
    openFirewall = true;
  };

  # Enable the firewall
  # networking.firewall.enable = true;
  networking.firewall.allowPing = true;
}
