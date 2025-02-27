{ 
config, 
options, 
lib, 
pkgs, 
... 
}: 

{
  networking = {
    enableIPv6 = true;
    # enableIPv4 = true;
    networkmanager.enable = true;
    # Configure firewall to your likings:
    firewall = {
      allowPing = true;
      # I want to configure my own ports
      enable = false;
      #--------------------------------------------------------------------- 
      # Curiously, `services.samba` does not automatically open
      # the needed ports in the firewall. Manualy open ports = [ 139 445 ]
      #--------------------------------------------------------------------- 
      allowedTCPPorts = [
	    21    # FTP
	    53    # DNS
	    80    # HTTP
	    443   # HTTPS
	    143   # IMAP
	    389   # LDAP
	    139   # Samba
	    445   # Samba
	    25    # SMTP
	    22    # SSH
	    5432  # PostgreSQL
	    3306  # MySQL/MariaDB
	    3307  # MySQL/MariaDB
	    111   # NFS
	    2049  # NFS
	    2375  # Docker
	    22000 # Syncthing
	    9091  # Transmission
	    60450 # Transmission
	    80    # Gnomecast server
	    8010  # Gnomecast server
	    8200  # Teamviewer
	    8888  # Gnomecast server
	    5357  # wsdd: Samba
	    1714  # Open KDE Connect
	    1764  # Open KDE Connect
	    8200  # Teamviewer
            5357  # wsdd : samba        
        # Open KDE Connect
        {
          from = 1714;
          to = 1764;
        }        
      ];
      allowedUDPPorts = [
	    53    # DNS
	    137   # NetBIOS Name Service
	    138   # NetBIOS Datagram Service
	    3702  # wsdd: Samba
	    5353  # Device discovery
	    21027 # Syncthing
	    22000 # Syncthing
	    8200  # Teamviewer
	    1714  # Open KDE Connect
	    1764  # Open KDE Connect
	    22000 # Syncthing port
	    8200  # Syncthing port
            # Open KDE Connect
            {
             from = 1714;
             to = 1764;
           }       
      ];
      #--------------------------------------------------------------------- 
      # Adding a rule to the iptables firewall to allow NetBIOS name 
      # resolution traffic on UDP port 137
      #--------------------------------------------------------------------- 
      extraCommands = "iptables -t raw -A OUTPUT -p udp -m udp --dport 137 -j CT --helper netbios-ns";
    };
  };
}
