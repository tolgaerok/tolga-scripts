
# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports = [
    # USE NIX FMT ONLINE:           https://nixfmt.serokell.io/
    ./config
    ./hardware-configuration.nix
  ];

  # Enables simultaneous use of processor threads.
  # ---------------------------------------------
  security.allowSimultaneousMultithreading = true;
  security.rtkit.enable = true;  

  # --------- NETWORKING ----------- #

  networking.hostName = "nixos"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Or disable the firewall altogether.
  # networking.firewall.enable = false;
  networking.nftables.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # ---------- LOCALE --------------- #
  # Set your time zone.
  time.timeZone = "Australia/Perth";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_AU.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_AU.UTF-8";
    LC_IDENTIFICATION = "en_AU.UTF-8";
    LC_MEASUREMENT = "en_AU.UTF-8";
    LC_MONETARY = "en_AU.UTF-8";
    LC_NAME = "en_AU.UTF-8";
    LC_NUMERIC = "en_AU.UTF-8";
    LC_PAPER = "en_AU.UTF-8";
    LC_TELEPHONE = "en_AU.UTF-8";
    LC_TIME = "en_AU.UTF-8";
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.tolga = {
    isNormalUser = true;
    description = "tolga";
    extraGroups = [
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
    ];
    packages = with pkgs; [
      kdePackages.kate
      #  thunderbird
    ];
  };

  # --------- PROGRAM SETTINGS --------- #

  # Install firefox.
  programs.firefox.enable = true;
  programs.direnv.enable = true;

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };

  # ----------- PACKAGES ----------- #

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    #  vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    #  wget
    kchmviewer
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

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # IO Scheduler based on device type
  services.udev.extraRules = ''
    # HDD
    ACTION=="add|change", KERNEL=="sd[a-z]*", ATTR{queue/rotational}=="1", ATTR{queue/scheduler}="bfq"
    # SSD
    ACTION=="add|change", KERNEL=="sd[a-z]*|mmcblk[0-9]*", ATTR{queue/rotational}=="0", ATTR{queue/scheduler}="none"
    # NVMe SSD
    ACTION=="add|change", KERNEL=="nvme[0-9]*", ATTR{queue/rotational}=="0", ATTR{queue/scheduler}="none"
  '';

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;
  services.locate.enable = true;
  services.locate.package = pkgs.mlocate;
  services.locate.localuser = null;
  # Enable the X11 windowing system.
  # You can disable this if you're only using the Wayland session.
  services.xserver.enable = true;

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "au";
    variant = "";
  };

  services = {
    envfs = {
      enable = true;
    };
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;
  services.gvfs.enable = true;

  services.avahi = {
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

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.11"; # Did you read the comment?
  system.copySystemConfiguration = true;

  system.autoUpgrade = {
    enable = true;
    channel = "https://nixos.org/channels/nixos-unstable";
  };

  nix = {
    settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      auto-optimise-store = true;
    };

    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
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
    wlr = {
      enable = true;

    };

    extraPortals = with pkgs; [
      xdg-desktop-portal-gtk

      xdg-desktop-portal-kde
      xdg-desktop-portal-wlr
    ];

  };

}

