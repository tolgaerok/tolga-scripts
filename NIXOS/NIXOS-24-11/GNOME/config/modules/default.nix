{ config, pkgs, ... }:

{
  imports = [
    # ./efi
    # ./firewall
    # ./fonts
    # ./locale
    # ./mnt
    # ./networking
    # ./nix
    # ./nix-documentation
    # ./printing
    # ./program-settings
    # ./samba
    # ./security
    # ./services
    # ./tmpfs
    # ./user
    # ./zram
    ./activationScripts
    ./flatpaks
    ./nvidia
    ./scripts
    ./systemD

    # ---- Desktop Environment ---- #
    # ./gnome
    # ./kde
    # ./cinnamon

    # ---- OUT OF SERVICE ---- # 
    #./enviroment-sessions   
    #./packages
    #./tweaks
  ];
}

# sudo chown -R $(whoami):$(id -gn) /etc/nixos && sudo chmod -R 777 /etc/nixos && sudo chmod +x /etc/nixos/* && export NIXPKGS_ALLOW_INSECURE=1

