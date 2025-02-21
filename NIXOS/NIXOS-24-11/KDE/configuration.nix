# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{
  config,
  pkgs,
  lib,
  ...
}:

with lib;

let
  country = "Australia/Perth";
  hostname = "G4-Nixos";
  locale = "en_AU.UTF-8";
  name = "tolga";
in

{
  imports = [
    # USE NIX FMT ONLINE:           https://nixfmt.serokell.io/
    ./config
    ./hardware-configuration.nix
  ];

  # Enables simultaneous use of processor threads.
  # ---------------------------------------------
  security = {
    allowSimultaneousMultithreading = true;
    rtkit.enable = true;
  };

  # --------- NETWORKING ----------- #

  # Enable networking
  networking = {
    networkmanager = {
      enable = true;
      connectionConfig = {
        "ethernet.mtu" = 1462;
        "wifi.mtu" = 1462;
      };
    };

    hostName = "${hostname}";
    nftables.enable = true;
  };

  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # -----------------------------------------------
  # Locale settings
  # -----------------------------------------------

  # Set your time zone.
  time.timeZone = "${country}";

  # Select internationalisation properties.
  i18n = {
    defaultLocale = "${locale}";
    extraLocaleSettings = {
      LC_ADDRESS = "${locale}";
      LC_IDENTIFICATION = "${locale}";
      LC_MEASUREMENT = "${locale}";
      LC_MONETARY = "${locale}";
      LC_NAME = "${locale}";
      LC_NUMERIC = "${locale}";
      LC_PAPER = "${locale}";
      LC_TELEPHONE = "${locale}";
      LC_TIME = "${locale}";
    };
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  #---------------------------------------------------------------------
  # User account settings
  #---------------------------------------------------------------------

  # User and group configuration
  users = {
    groups.${name} = { };

    users."${name}" = {
      isNormalUser = true;
      description = "${name}";
      extraGroups = [
        "${name}"
        "adbusers"
        "audio"
        "corectrl"
        "disk"
        "docker"
        "input"
        "libvirtd"
        "lp"
        "minidlna"
        "mongodb"
        "mysql"
        "network"
        "networkmanager"
        "postgres"
        "power"
        "samba"
        "scanner"
        "smb"
        "sound"
        "storage"
        "systemd-journal"
        "udev"
        "users"
        "video"
        "wheel" # Enable ‘sudo’ for the user.
        "code"
      ];

      packages = with pkgs; [
        kdePackages.kate
        # thunderbird
      ];
    };
  };

  # --------- PROGRAM SETTINGS --------- #
  programs = {
    firefox.enable = true;
    direnv.enable = true;

    # Some programs need SUID wrappers, can be configured further or are started in user sessions.
    # mtr.enable = true;

    gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
    };
  };

  # ----------- PACKAGES ----------- #
  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    #  vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    #  wget
    kchmviewer
    kdeApplications.kdenetwork-filesharing
    keepassxc
    libsForQt5.akonadi
    libsForQt5.akonadi-calendar
    libsForQt5.akonadi-calendar-tools
    libsForQt5.akonadi-contacts
    libsForQt5.akonadi-import-wizard
    libsForQt5.akonadi-mime
    libsForQt5.akonadi-notes
    libsForQt5.akonadi-search
    libsForQt5.akonadiconsole
    libsForQt5.akregator
    libsForQt5.kaddressbook
    libsForQt5.kalarm
    libsForQt5.kcalc
    libsForQt5.kcharselect
    libsForQt5.kdepim-addons
    libsForQt5.kdepim-runtime
    libsForQt5.kfind
    libsForQt5.kget
    libsForQt5.kmag
    libsForQt5.kmail
    libsForQt5.kompare
    libsForQt5.kontact
    libsForQt5.korganizer
    libsForQt5.krecorder
    libsForQt5.plasma-vault
    p7zip
    partition-manager
    pciutils
    powershell
    python311Packages.pynvim
    python3Full
    samba
    unrar
    unzip
    usbutils
    variety
    vscode
    vscode-extensions.brettm12345.nixfmt-vscode
    wpsoffice

    ### System Packages
    qt6.qtwayland
    xorg.libxcb
    udiskie

  ];

  # ---------- SERVICES ------------- #
  services = {
    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      # If you want to use JACK applications, uncomment this
      # jack.enable = true;

      # use the example session manager (enabled by default, no need to redefine)
      # media-session.enable = true;
    };

    # IO Scheduler based on device type
    udev.extraRules = ''
      # HDD
      ACTION=="add|change", KERNEL=="sd[a-z]*", ATTR{queue/rotational}=="1", ATTR{queue/scheduler}="bfq"
      # SSD
      ACTION=="add|change", KERNEL=="sd[a-z]*|mmcblk[0-9]*", ATTR{queue/rotational}=="0", ATTR{queue/scheduler}="none"
      # NVMe SSD
      ACTION=="add|change", KERNEL=="nvme[0-9]*", ATTR{queue/rotational}=="0", ATTR{queue/scheduler}="none"
    '';

    # Enable system services
    openssh.enable = true;
    locate = {
      enable = true;
      package = pkgs.mlocate;
      localuser = null;
    };
    xserver = {
      enable = true;
      xkb = {
        layout = "au";
        variant = "";
      };
    };
    dbus = {
      enable = true;
      packages = with pkgs; [
        dconf
        gcr
        udisks2
      ];
    };
    envfs.enable = true;
    timesyncd.enable = true;
    printing.enable = true;
    gvfs.enable = true;

    # Enable Avahi for network service discovery
    avahi = {
      enable = true;
      nssmdns4 = true;
      openFirewall = true;
      publish = {
        addresses = true;
        domain = true;
        enable = true;
        hinfo = true;
        userServices = true;
        workstation = true;
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
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system = {
    stateVersion = "24.11"; # Did you read the comment?
    copySystemConfiguration = true;

    autoUpgrade = {
      enable = true;
      channel = "https://nixos.org/channels/nixos-unstable";
    };
  };

  #---------------------------------------------------------------------
  # Allow unfree packages
  #---------------------------------------------------------------------
  environment.sessionVariables.NIXPKGS_ALLOW_UNFREE = "1";

  #---------------------------------------------------------------------
  # System optimisations
  #---------------------------------------------------------------------
  nix = {
    settings = {
      allowed-users = [
        "@wheel"
        "${name}"
      ];
      auto-optimise-store = true;

      experimental-features = [
        "flakes"
        "nix-command"
        "repl-flake"
      ];

      cores = 0;
      sandbox = "relaxed";

      trusted-users = [
        "${name}"
        "@wheel"
        "root"
      ];

      keep-derivations = true;
      keep-outputs = true;
      warn-dirty = false;
      tarball-ttl = 300;

      substituters = [
        "https://cache.nixos.org"
        "https://cache.nix.cachix.org"
      ];

      trusted-substituters = [
        "https://cache.nixos.org"
        "https://cache.nix.cachix.org"
      ];
    };

    daemonCPUSchedPolicy = "idle";
    daemonIOSchedPriority = 7;

    gc = {
      automatic = true;
      dates = "weekly";
      randomizedDelaySec = "14m";
      options = "--delete-older-than 10d";
    };
  };

  # nixpkgs.config.allowUnfree = true;
  zramSwap = {
    enable = true;
    memoryPercent = 50;
    algorithm = "zstd";
  };

  xdg.portal = {
    enable = true;
    xdgOpenUsePortal = true;

    lxqt = {
      enable = false;
      styles =
        with pkgs;
        with libsForQt5;
        [
          qtstyleplugin-kvantum
          catppuccin-kvantum
          breeze-qt5
          qtcurve
        ];
    };

    # Turn Wayland off
    wlr.enable = true;

    extraPortals = with pkgs; [
      xdg-desktop-portal-gtk
      xdg-desktop-portal-kde
      xdg-desktop-portal-wlr
    ];
  };

}

