# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

# Tolga Erok
# 10-6-2024
# My personal NIXOS 24-05 GNOME configuration
#
#              ¯\_(ツ)_/¯
#   ███▄    █     ██▓   ▒██   ██▒    ▒█████       ██████
#   ██ ▀█   █    ▓██▒   ▒▒ █ █ ▒░   ▒██▒  ██▒   ▒██    ▒
#  ▓██  ▀█ ██▒   ▒██▒   ░░  █   ░   ▒██░  ██▒   ░ ▓██▄
#  ▓██▒  ▐▌██▒   ░██░    ░ █ █ ▒    ▒██   ██░     ▒   ██▒
#  ▒██░   ▓██░   ░██░   ▒██▒ ▒██▒   ░ ████▓▒░   ▒██████▒▒
#  ░ ▒░   ▒ ▒    ░▓     ▒▒ ░ ░▓ ░   ░ ▒░▒░▒░    ▒ ▒▓▒ ▒ ░
#  ░ ░░   ░ ▒░    ▒ ░   ░░   ░▒ ░     ░ ▒ ▒░    ░ ░▒  ░ ░
#     ░   ░ ░     ▒ ░    ░    ░     ░ ░ ░ ▒     ░  ░  ░
#           ░     ░      ░    ░         ░ ░           ░

#-------------- Hewlett-Packard HP EliteBook Folio 9470m ------------------
#------------------ Intel® Core™ i7-3667U × 4 8GB  ------------------------
#---------------- Intel® HD Graphics 4000 (IVB GT2) -----------------------

{
  config,
  pkgs,
  lib,
  ...
}:

with lib;

let

  country = "Australia/Perth";
  hostname = "Folio-Nixos";
  kernel = pkgs.linuxPackages_zen;
  locale = "en_AU.UTF-8";
  name = "tolga";
in
{

  imports = [

    # ./DE/kde.nix
    # ./core
    # ./core/modules
    # ./core/modules/system-tweaks/kernel-tweaks/8GB-SYSTEM/8GB-SYSTEM.nix
    # ./core/modules/system-tweaks/kernel-upgrades/latest-standard.nix
    # ./core/modules/system-tweaks/storage-tweaks/SSD/SSD-tweak.nix
    # ./user/tolga/home-network/mnt-samba.nix

    ./DE/gnome.nix
    ./core/modules
    ./core/services
    ./hardware-configuration.nix
    ./network
  ];

  #---------------------------------------------------------------------
  # Bootloader configuration - EFI, plymouth, tmpfs
  #---------------------------------------------------------------------
  boot = {
    loader = {
      efi.canTouchEfiVariables = true; # Enables the ability to modify EFI variables.
      systemd-boot.enable = true; # Activates the systemd-boot bootloader.
      systemd-boot.consoleMode = "max";
    };

    initrd.systemd.enable = true; # Enables systemd services in the initial ramdisk (initrd).
    initrd.verbose = false; # silent boot
    plymouth.enable = true; # Activates the Plymouth boot splash screen.
    plymouth.theme = "breeze"; # Sets the Plymouth theme to "breeze."
  };

  boot.kernelPackages = kernel;

  boot.kernelParams = [
    "elevator=kyber" # Change to kyber scheduler
    "mitigations=off" # Disables certain security mitigations, potentially improving performance but reducing security.
    "quiet" # Suppresses verbose kernel messages during boot, providing a quieter boot process.
  ];

  boot.supportedFilesystems = [ "ntfs" ]; # USB Drives might have this format

  # silence ACPI "errors" at boot shown before NixOS stage 1 output (default is 4)
  boot.consoleLogLevel = 3;

  # tmpfs (a filesystem stored in RAM) settings for the NixOS boot process.
  # Clean tmpfs on system boot, useful for ensuring a clean state.
  # NOTE:  boot.tmp can not be nested, must stay as toplevel as they are part of the global system configuration
  boot.tmp.cleanOnBoot = true;

  # Enable tmpfs for the specified directories.
  boot.tmp.useTmpfs = true;

  # NEW: set to auto to dynamically grow    OLD:Allocate 35% of RAM for tmpfs. You can adjust this percentage to your needs.
  boot.tmp.tmpfsSize = "35%";

  fileSystems."/run" = {
    device = "tmpfs";
    options = [ "size=4G" ]; # Adjust based on your preferences and needs
  };

  # Fixed : better to use Dynamic
  fileSystems."/tmp" = {
    device = "tmpfs";
    options = [ "size=5G" ]; # Adjust based on your preferences and needs
  };

  # Add a file system entry for the "DLNA" directory bind mount
  fileSystems."/mnt/DLNA" = {
    device = "/home/${name}/DLNA";
    fsType = "none";
    options = [
      "bind"
      "rw"
    ]; # Read-write access
  };

  # Add a file system entry for the "MyGit" directory bind mount
  fileSystems."/mnt/MyGit" = {
    device = "/home/${name}/MyGit";
    fsType = "none";
    options = [
      "bind"
      "rw"
    ]; # Read-write access
  };

  fileSystems."/home/${name}/Universal" = {
    device = "/Universal";
    options = [
      "bind"
      "rw"
    ]; # Read-write access
  };

  # -----------------------------------------------
  # Services
  # -----------------------------------------------

  # -------------------------------------------------------------------
  # Disable unused serial device's at boot && extra powersave options &&
  # autosuspend USB devices && autosuspend PCI devices
  # -------------------------------------------------------------------
  services.udev.extraRules = ''
    ACTION=="add", SUBSYSTEM=="net", NAME=="enp*", RUN+="${pkgs.ethtool}/sbin/ethtool -s $name wol d"   # disable Ethernet Wake-on-LAN
    ACTION=="add", SUBSYSTEM=="pci", TEST=="power/control", ATTR{power/control}="auto"                  # autosuspend PCI devices
    ACTION=="add", SUBSYSTEM=="usb", TEST=="power/control", ATTR{power/control}="auto"                  # autosuspend USB devices
    ACTION=="add|change", KERNEL=="sd[a-z]*[0-9]*|mmcblk[0-9]*p[0-9]*|nvme[0-9]*n[0-9]*p[0-9]*", ENV{ID_FS_TYPE}=="ext4", ATTR{../queue/scheduler}="mq-deadline"
    KERNEL=="hpet", GROUP="audio"
    KERNEL=="rtc0", GROUP="audio"
    KERNEL=="ttyS[1-3]", SUBSYSTEM=="tty", ACTION=="add", ATTR{enabled}="0"
  '';

  #---------------------------------------------------------------------
  # Enable the OpenSSH daemon.
  #---------------------------------------------------------------------
  services.openssh.enable = true;

  #---------------------------------------------------------------------
  # Enable CUPS to print documents.
  #---------------------------------------------------------------------
  services.printing.enable = true;

  # Enable the D-Bus service, which is a message bus system that allows
  # communication between applications.
  # Thanks Chris Titus!
  services = {
    dbus = {
      enable = true;
      packages = with pkgs; [

        dconf
        gcr
        udisks2
      ];
    };
  };

  services = {
    envfs = {
      enable = true;
    };
  };

  services.timesyncd.enable = true;
  # services.docker.enable = true;

  #---------------------------------------------------------------------
  # SystemD settings
  #---------------------------------------------------------------------
  systemd = {
    services = {

      bind-mount-DLNA = {
        description = "Bind mount /home/${name}/DLNA to /mnt/DLNA";
        after = [ "network.target" ];
        serviceConfig = {
          Type = "oneshot";
          ExecStart = "${pkgs.util-linux}/bin/mount --bind /home/${name}/DLNA /mnt/DLNA";
          RemainAfterExit = true;
        };
        wantedBy = [ "multi-user.target" ];
      };

      bind-mount-MyGit = {
        description = "Bind mount /home/${name}/DLNA to /mnt/MyGit";
        after = [ "network.target" ];
        serviceConfig = {
          Type = "oneshot";
          ExecStart = "${pkgs.util-linux}/bin/mount --bind /home/${name}/MyGit /mnt/MyGit";
          RemainAfterExit = true;
        };
        wantedBy = [ "multi-user.target" ];
      };

      # Ensure correct ownership to my /Universal directory and chown to the user
      chown-universal-directory = {
        description = "Ensure correct ownership of /Universal";
        after = [
          "local-fs.target"
          "nss-user-lookup.target"
        ];
        wantedBy = [ "multi-user.target" ];
        serviceConfig = {
          Type = "oneshot";
          ExecStart = "${pkgs.bash}/bin/bash -c 'if id -u ${name} >/dev/null 2>&1 && id -g ${name} >/dev/null 2>&1; then mkdir -p /Universal && chown ${name}:${name} /Universal; fi'";
          RemainAfterExit = true;
        };
      };

      "io-scheduler" = {
        description = "Set I/O Scheduler on boot - Tolga Erok";
        wantedBy = [ "multi-user.target" ];
        serviceConfig = {
          Type = "oneshot";
          ExecStart = "${pkgs.bash}/bin/bash -c 'echo -e \"Configuring I/O Scheduler to: \"; echo \"kyber\" | ${pkgs.coreutils}/bin/tee /sys/block/sda/queue/scheduler; printf \"I/O Scheduler has been set to ==>  \"; cat /sys/block/sda/queue/scheduler; echo \"\"'";
        };
        enable = true;
      };

      check-create-user-home-dirs = {
        description = "Ensure user home directories are created and owned by the user";
        after = [ "network.target" ];
        wantedBy = [ "default.target" ];
        serviceConfig = {
          Type = "oneshot";
          ExecStart = ''
            ${pkgs.bash}/bin/bash -c 'if id -u ${name} >/dev/null 2>&1 && id -g ${name} >/dev/null 2>&1; then \
              for dir in Documents Downloads Music Pictures Videos MyGit DLNA Applications; do \
                mkdir -p /home/${name}/$dir && chown ${name}:${name} /home/${name}/$dir; \
              done; \
            fi'
          '';
        };
        enable = true;
      };

      "NetworkManager-wait-online".enable = false;
      "systemd-udev-settle".enable = false;
      "getty@tty1".enable = false;
      "autovt@tty1".enable = false;
    };

    tmpfiles.rules = [
      "d /Universal 0755 ${name} ${name} -"
      "D! /tmp 1777 root root 0"
      "d /var/spool/samba 1777 root root -"
      "r! /tmp/**/*"
    ];

    coredump.enable = true;

    slices."nix-daemon".sliceConfig = {
      MemoryHigh = "2G";
      MemoryMax = "3G";
      CPUQuota = "50%";
      ManagedOOMMemoryPressure = "kill";
      ManagedOOMMemoryPressureLimit = "95%";
    };

    services."nix-daemon".serviceConfig = {
      Slice = "nix-daemon.slice";
      OOMScoreAdjust = 1000;
    };
  };

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

  #---------------------------------------------------------------------
  # MISC settings
  #---------------------------------------------------------------------
  nixpkgs.config.joypixels.acceptLicense = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    #  vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    #  wget
  ];

  #---------------------------------------------------------------------
  # Allow unfree packages
  #---------------------------------------------------------------------
  environment.sessionVariables.NIXPKGS_ALLOW_UNFREE = "1";
  nixpkgs.config.allowUnfree = true;

  # -----------------------------------------------
  # Enables simultaneous use of processor threads.
  # -----------------------------------------------
  security.allowSimultaneousMultithreading = true;

  #---------------------------------------------------------------------
  # Networking
  #---------------------------------------------------------------------
  networking.hostName = "${hostname}"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  networking.networkmanager.enable = true;
  networking.networkmanager.connectionConfig = {
    "ethernet.mtu" = 1462;
    "wifi.mtu" = 1462;
  };

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # --------------------------------------------------------------------
  # Permit Insecure Packages
  # --------------------------------------------------------------------
  nixpkgs.config.permittedInsecurePackages = [
    "openssl-1.1.1u"
    "openssl-1.1.1v"
    "electron-12.2.3"
  ];

  # -----------------------------------------------
  # Locale settings
  # -----------------------------------------------

  # Set your time zone.
  time.timeZone = "${country}";

  # Select internationalisation properties.
  i18n.defaultLocale = "${locale}";

  i18n.extraLocaleSettings = {
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

  #---------------------------------------------------------------------
  # User account settings
  #---------------------------------------------------------------------

  # Add user into user groups
  users.groups.${name} = { };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users."${name}" = {
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

      # Gnome extensions
      caprine-bin
      docker
      ethtool
      firefox
      gimp-with-plugins
      gnome-extension-manager
      gnome.dconf-editor
      gnome.gnome-disk-utility
      gnome.gnome-tweaks
      gnomeExtensions.blur-my-shell
      gnomeExtensions.dash-to-dock
      gnomeExtensions.forge
      gnomeExtensions.logo-menu
      kate
      mesa
      neofetch

      vscode
      nixfmt-rfc-style
      vscode-extensions.brettm12345.nixfmt-vscode
      direnv

      #  thunderbird
    ];
  };

  # -----------------------------------------------
  # X11 settings
  # -----------------------------------------------

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Enable the KDE Plasma Desktop Environment.
  # services.xserver.displayManager.sddm.enable = true;

  # Configure keymap in X11
  services.xserver = {
    xkb.layout = "au";
    xkb.variant = "";
  };

  #---------------------------------------------------------------------
  # Audio settings
  #---------------------------------------------------------------------

  # Enable sound with pipewire.
  sound.enable = true;
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
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

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  ###################################################################################################
  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  #---------------------------------------------------------------------
  # Automatic system upgrades, automatically reboot after an upgrade if
  # necessary
  #---------------------------------------------------------------------
  # system.autoUpgrade.allowReboot = true;  # Very annoying .
  system.autoUpgrade.enable = true;
  system.copySystemConfiguration = true;
  system.stateVersion = "23.05";
  systemd.extraConfig = "DefaultTimeoutStopSec=10s";
}
