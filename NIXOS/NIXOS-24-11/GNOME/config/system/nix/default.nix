{ 
config, 
pkgs, 
lib, 
username, 
... 
}:

with lib;
let
  name = "tolga";
in
{
  #---------------------------------------------------------------------
  # System optimisations
  #---------------------------------------------------------------------
  nixpkgs.config.allowUnfree = true;
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
        # "repl-flake"
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
        # "https://cache.nix.cachix.org"
      ];
      trusted-substituters = [
        "https://cache.nixos.org"
        # "https://cache.nix.cachix.org"
      ];
    };
    daemonCPUSchedPolicy = "idle";
    daemonIOSchedPriority = 7;
    gc = {
      automatic = true;
      dates = "Mon 3:40";
      randomizedDelaySec = "14m";
      options = "--delete-older-than 10d";
    };
  };
 }
