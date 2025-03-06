{ config, pkgs, ... }:

{
  imports = [
    # ./activationScripts
    # ./firewall
    # ./flatpaks
    # ./fonts
    # ./locale
    # ./networking
    # ./nix
    # ./nix-documentation
    # ./nvidia
    # ./printing
    # ./program-settings
    # ./samba
    # ./scripts
    # ./security
    # ./services
    # ./systemD
    # ./user
    # ./zram
    ./efi
    # ./mnt
    ./tmpfs

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

