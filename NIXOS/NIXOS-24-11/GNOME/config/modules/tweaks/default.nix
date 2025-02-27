{ config, pkgs, ... }:

{
  # First, everything that applies to all machines:
  imports = [
    # ./packages/scripts.nix
    # ./packages/custom-fonts.nix
    # ./packages/apple-fonts.nix
    # ./packages/minecraft-fonts.nix
    # ./packages/remote-builders.nix
    # ./services/syncthing.nix
  ];

  #---------------------------------------------------------------------
  # Systemd Configuration
  #---------------------------------------------------------------------
  # Prevents getting stuck in emergency mode due to boot failures.
  # https://github.com/NixOS/nixpkgs/issues/147783
  systemd = {
    # enableEmergencyMode = false;
    # network.wait-online.anyInterface = true;
    services.systemd-udev-settle.enable = false;
  };

  #---------------------------------------------------------------------
  # Nix Configuration
  #---------------------------------------------------------------------
  nix.settings = {
    auto-optimise-store = true; # Corrected option name
    trusted-users = [
      "@wheel"
      "tolga"
    ]; # Corrected option name
    system-features = [
      "i686-linux"
      "big-parallel"
    ];
  };

  nix.gc = {
    automatic = true;
    options = "--delete-older-than 15d";
  };

  environment.sessionVariables = {
    NIXPKGS_ALLOW_INSECURE = "1";
  };

  nixpkgs.config.allowUnfreePredicate = (pkg: true);

  # Enables simultaneous use of processor threads.
  # ---------------------------------------------
  security.allowSimultaneousMultithreading = true;
}

