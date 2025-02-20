# This NixOS configuration file is for setting up various services and printer drivers on the system.

{ config, pkgs, lib, username, ... }:
let

  #---------------------------------------------------------------------
  #   Printers and printer drivers (To suit my HP LaserJet 600 M601)
  #---------------------------------------------------------------------
  # List of printer drivers to be installed
  printerDrivers = [
    #pkgs.brgenml1cupswrapper  # Generic drivers for more Brother printers
    #pkgs.brgenml1lpr          # Generic drivers for more Brother printers
    #pkgs.brlaser              # Drivers for some Brother printers
    # pkgs.cnijfilter2          # Generic Canon printer drivers
    pkgs.gutenprint # Drivers for many different printers from many different vendors
    pkgs.gutenprintBin # Additional, binary-only drivers for some printers
    pkgs.hplip # Drivers for HP printers
    pkgs.hplipWithPlugin # HP printer drivers with proprietary plugin
  ];

in {
  imports = [
    # ./samba
    #./extra-printers/HL2130_NET_DADS_LASER.nix
  ];

  #---------------------------------------------------------------------
  # Services
  #---------------------------------------------------------------------

  # services.flatpak.enable = true;
  # services.teamviewer.enable = true;

  services = {

    # Enable GEO location
    geoclue2 = { enable = true; };

    # GVFS: GNOME Virtual File System support
    #gvfs = {
    #  enable = true;
    #  package = lib.mkForce pkgs.gnome.gvfs;
    #};

    # PipeWire: Manages audio and media
    pipewire = {
      enable = true;
      alsa.enable = true; # Enable ALSA backend for PipeWire
      alsa.support32Bit = true; # Enable 32-bit ALSA support
      pulse.enable = true; # Enable PulseAudio compatibility layer for PipeWire
    };

    # EnvFS: Encrypted filesystem support
    envfs = {
      enable = true; # Enable EnvFS for encrypted filesystem support
    };

    # Timesyncd: Synchronizes system time with network time servers
    timesyncd.enable = true;

    # Udev: Device management and custom rules
    udev = {
      enable = true; # Enable udev for device management

      # Performance-optimized udev rules for SSD
      extraRules = ''
        # Improve disk writeback behavior for faster I/O
        ACTION=="add|change", SUBSYSTEM=="bdi", ATTR{min_ratio}="10", ATTR{max_ratio}="100"

        # Set optimal I/O scheduler for SSDs
        ACTION=="add|change", KERNEL=="sd[a-z]*|nvme[0-9]*n[0-9]*p[0-9]*", ATTR{../queue/scheduler}="none"

        # Disable serial ports (still unnecessary)
        KERNEL=="ttyS[1-3]", SUBSYSTEM=="tty", ACTION=="add", ATTR{power/control}="on", ATTR{power/runtime_enabled}="enabled"
      '';
    };

    # Udisks2: Disk management service
    udisks2 = { enable = true; };

    # Devmon: Automount removable media
    devmon = {
      enable = true; # Enable devmon for automounting removable media
    };

    # Avahi: Network service discovery
    avahi = {
      enable = true; # Enable Avahi for network service discovery
      nssmdns4 = true; # Enable mDNS for name resolution
      openFirewall = true; # Open firewall ports for Avahi

      publish = {
        addresses = true; # Publish IP addresses
        domain = true; # Publish domain name
        enable = true; # Enable Avahi publishing
        hinfo = true; # Publish host information
        userServices = true; # Publish user services
        workstation = true; # Publish workstation type
      };

      extraServiceFiles = {
        smb = ''
          <?xml version="1.0" standalone='no'?><!--*-nxml-*-->
          <!DOCTYPE service-group SYSTEM "avahi-service.dtd">
          <service-group>
            <name replace-wildcards="yes">%h</name>
            <service>
              <type>_smb._tcp</type>
              <port>445</port>
            </service>
          </service-group>
        '';
      };
    };

    # Blueman: Bluetooth management tool
    blueman.enable = true; # Enable Blueman for Bluetooth management

    # D-Bus: Message bus system
    dbus = {
      enable = true; # Enable D-Bus message bus system
      packages = with pkgs; [
        dconf # Dconf editor for GNOME settings
        gcr # GNOME keyring
        udisks2 # Disk management service
      ];
    };

    # Hardware: Configuration for various hardware services
    hardware = {
      bolt.enable = true; # Enable Bolt for Thunderbolt device management
      # firmware.enable = true; # Enable firmware updates (commented out)
    };

    # Fstrim: SSD maintenance
    fstrim = {
      enable = true; # Enable fstrim service for SSD maintenance
    };

    # Logind: Login management settings
    logind = {
      extraConfig = ''
        # Set the maximum size of runtime directories to 100%
        RuntimeDirectorySize=100%

        # Set the maximum number of inodes in runtime directories to 1048576
        RuntimeDirectoryInodesMax=1048576
      '';
    };

    # OpenSSH: Secure shell access
    openssh = {
      enable = true; # Enable OpenSSH server

      settings = {
        PermitRootLogin = lib.mkForce "yes"; # Allow root login
        UseDns = false; # Disable DNS lookup
        X11Forwarding = false; # Disable X11 forwarding
        PasswordAuthentication =
          lib.mkForce true; # Enable password authentication
        KbdInteractiveAuthentication =
          true; # Enable keyboard-interactive authentication
      };

      banner = ''
        # SSH login banner
               Tolga Erok ¯\_(ツ)_/¯⠀  ⢀⣠⣴⣾⣿⣿⣿⣿⣿
               >ligma
      '';

      hostKeys = [
        {
          bits = 4096; # RSA key with 4096 bits
          path = "/etc/ssh/ssh_host_rsa_key";
          type = "rsa";
        }

        {
          path = "/etc/ssh/ssh_host_ed25519_key";
          type = "ed25519"; # ED25519 key
        }
      ];
    };

    #---------------------------------------------------------------------
    #   Enable CUPS to print documents.
    #---------------------------------------------------------------------
    # Printing: CUPS printing service and drivers
    printing = {
      drivers = printerDrivers; # Install printer drivers
      enable = true; # Enable CUPS printing service
      browsing = true;
    };

    #---------------------------------------------------------------------
    #   Enable the SSH daemon
    #---------------------------------------------------------------------
    sshd.enable = lib.mkForce
      true; # Enable SSH daemon (redundant with OpenSSH configuration above)

    # Thermald: Thermal management daemon (disabled)
    #thermald = {
    #  enable = false;     # Disable thermald service
    #};
  };

  # iPhone Support: Configures support for iPhone
  #iphone = {
  #  enable = true; # Enable iPhone support
  #  user = "tolga"; # Set the user for iPhone support
  #};

}
