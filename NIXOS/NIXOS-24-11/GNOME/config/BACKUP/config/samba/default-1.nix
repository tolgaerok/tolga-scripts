{ config, hostname, lib, pkgs, username, ... }:

let
  inherit (import ../variables) name;

  mySharedPath = "/home/${name}/Public";
  mySharedPath2 = "/home/${name}/scripts";
  sharedOptions = {
    "guest ok" = "true";
    "read only" = "false";
    "valid users" = "@samba";
    "browseable" = "true";
    "writable" = "true";
  };

in {
  services = {
    samba-wsdd = {
      enable = true;
      openFirewall = true;
    };

    samba = {
      enable = true;
      openFirewall = true;
      package = pkgs.samba4Full;

      settings = {

        global = {
          "workgroup" = "WORKGROUP";
          "bind interfaces only" = "true";
          "dns proxy" = "no";
          "name resolve order" = "lmhosts wins bcast host";
          "netbios name" = config.networking.hostName;
          "passdb backend" = "tdbsam";
          "security" = "user";
          "server role" = "standalone";
          "server string" = "Samba server (version: %v, protocol: %R)";

          # Access Control
          "deadtime" = "30";
          "guest account" = "nobody";
          "hosts allow" =
            "127.0.0.1 10.0.0.0/8 172.16.0.0/12 192.168.0.0/16 169.254.0.0/16 ::1 fd00::/8 fe80::/10";
          "hosts deny" = "allow";
          "inherit permissions" = "yes";
          "map to guest" = "bad user";
          "pam password change" = "yes";

          # Performance Tuning
          "large readwrite" = "yes";
          "max xmit" = "65535";
          "read raw" = "yes";
          "socket options" = "SO_KEEPALIVE SO_REUSEADDR SO_BROADCAST TCP_NODELAY IPTOS_LOWDELAY IPTOS_THROUGHPUT SO_SNDBUF=262144 SO_RCVBUF=131072";
          "use sendfile" = "yes";
          "wins support" = "true";
          "write raw" = "yes";

          # Protocol Settings
          "client ipc max protocol" = "SMB3";
          "client ipc min protocol" = "COREPLUS";
          "client max protocol" = "SMB3";
          "client min protocol" = "COREPLUS";
          "server max protocol" = "SMB3";
          "server min protocol" = "COREPLUS";
          "vfs objects" = "acl_xattr catia streams_xattr";

          # Larger Asynchronous I/O sizes
          "aio read size" = "1024";
          "aio write size" = "1024";

          # Logging
          "ea support" = "yes";
          "log file" = "/var/log/samba/log.%m";
          "log level" = "1 auth:3 smb:3 smb2:3";
          "max log size" = "500";

          # Extended Attributes and Apple-specific Settings
          "cups options" = "raw";
          "disable spoolss" = "yes";
          "fruit:delete_empty_adfiles" = "yes";
          "fruit:metadata" = "stream";
          "fruit:model" = "Macmini";
          "fruit:posix_rename" = "yes";
          "fruit:veto_appledouble" = "no";
          "fruit:wipe_intentionally_left_blank_rfork" = "yes";
          "fruit:zero_file_id" = "yes";
          "load printers" = "yes";
          "printcap name" = "cups";
          "printing" = "cups";

        };

        security = { securityType = "user"; };

        "homes" = sharedOptions // {
          "comment" = "Home Directories";
          "browseable" = "yes";
          "create mask" = "0700";
          "directory mask" = "0700";
          "valid users" = "%S, %D%w%S";
        };

        "NixOS_Scripts" = sharedOptions // {
          "path" = mySharedPath2;
          "comment" = "Scripts Share";
          "create mask" = "0777";
          "directory mask" = "0777";
        };

        "NixOS_Private" = sharedOptions // {
          "path" = "/home/NixOs";
          "comment" = "Private Share";
          "create mask" = "0644";
          "directory mask" = "0755";
          "guest ok" = "no";
        };

        "printers" = sharedOptions // {
          "comment" = "All Printers";
          "path" = "/var/spool/samba";
          "public" = "yes";
          "guest ok" = "yes";
          "writable" = "no";
          "printable" = "yes";
          "create mode" = 700;
        };
      };
    };
  };
  #};

  systemd.tmpfiles.rules = [
    "d ${mySharedPath2} 0777 ${name} users - -"
    "d ${mySharedPath} 0777 ${name} users - -"
    "d /var/spool/samba 1777 root root -"
  ];

  # networking.firewall.enable = true;
  networking.firewall.allowPing = true;

}
