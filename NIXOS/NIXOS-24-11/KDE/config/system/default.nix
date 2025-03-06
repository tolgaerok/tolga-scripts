{ config, pkgs, ... }:

{
  imports = [
    # ./activationScripts
    # ./efi
    # ./environment-sessions
    # ./firewall
    # ./flatpaks
    # ./mnt
    # ./nvidia
    # ./scripts
    ./fonts
    ./locale
    ./networking
    ./nix
    ./nix-documentation
    ./packages
    ./printing
    ./program-settings
    ./security
    ./services
    ./user
    ./zram
  ];
}
