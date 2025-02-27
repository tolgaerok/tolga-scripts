{ 
config, 
pkgs, 
... 
}:

{
  imports = [
    ./activationScripts
    ./efi
    #./enviroment-sessions
    ./firewall
    ./flatpaks
    ./fonts
    ./gnome
    ./locale
    ./mnt
    ./networking
    ./nix
    ./nix-documentation
    ./nvidia
    ./printing
    ./program-settings
    ./samba
    ./scripts
    ./security
    ./services
    ./systemD
    ./tmpfs
    ./user
    ./zram
    
    # ---- OUT OF SERVICE ---- #
    #./kde
    #./packages
    #./tweaks
  ];
}  

# sudo chown -R $(whoami):$(id -gn) /etc/nixos && sudo chmod -R 777 /etc/nixos && sudo chmod +x /etc/nixos/* && export NIXPKGS_ALLOW_INSECURE=1

