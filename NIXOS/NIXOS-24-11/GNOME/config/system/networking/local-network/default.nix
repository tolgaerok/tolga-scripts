{ 
config, 
pkgs, 
lib, 
username,
name,
hostname,
... 
}:

with lib;
let
  hostname = "G4-Nixos";
in
{
  # ---------------------------------------------
  # NETWORKING 
  # ---------------------------------------------
  # Enable networking
  networking = {
    networkmanager = {
      enable = true;
      connectionConfig = {
        "ethernet.mtu" = 1462;
        "wifi.mtu" = 1500;
      };
      appendNameservers = [
        "1.1.1.1"
        "9.9.9.9"
      ];
    };
    firewall.allowPing = true;
    hostName = "${hostname}";
    nftables.enable = true;
    # Set time servers
    timeServers = [
      "0.nixos.pool.ntp.org"
      "1.nixos.pool.ntp.org"
      "2.nixos.pool.ntp.org"
      "3.nixos.pool.ntp.org"
      "time.google.com"
      "time2.google.com"
      "time3.google.com"
      "time4.google.com"
    ];
    # Configure extra hosts
    extraHosts = ''
      127.0.0.1       localhost
      127.0.0.1       HP-G4-800
      192.168.0.1     router
      192.168.0.2     DIGA            # Smart TV
      192.168.0.5     folio-F39       # HP Folio
      192.168.0.6     iPhone          # Dads mobile
      192.168.0.7     Laser           # Laser Printer
      192.168.0.8     min21THIN       # EMMC thinClient
      192.168.0.10    TUNCAY-W11-ENT  # Dads PC
      192.168.0.11    ubuntu-server   # CasaOS
      192.168.0.15    KingTolga       # My mobile
      192.168.0.17    QNAP-SERVER     # Main home server
      192.168.0.32    HP-G4           # Main NixOS rig

      # The following lines are desirable for IPv6 capable hosts
      ::1             localhost ip6-localhost ip6-loopback
      fe00::0         ip6-localnet
      ff00::0         ip6-mcastprefix
      ff02::1         ip6-allnodes
      ff02::2         ip6-allrouters
      ff02::3         ip6-allhosts
    '';
  };
}
