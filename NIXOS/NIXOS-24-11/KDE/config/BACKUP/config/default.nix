{ config, pkgs, ... }:

{
  imports = [ # Include the results of the hardware scan.
    ./efi
    #./firewall
    #./flatpaks
    ./kde
    ./nvidia
    #./packages
    #./samba
    ./scripts
    #./services
    #./tmpfs
    #./tweaks
    #./fonts
    
  ];

}

# sudo chown -R $(whoami):$(id -gn) /etc/nixos
# sudo chmod -R 777 /etc/nixos
# sudo chmod +x /etc/nixos/*
# export NIXPKGS_ALLOW_INSECURE=1
