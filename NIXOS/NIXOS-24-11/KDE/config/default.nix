{ config, pkgs, ... }:

{
  imports = [ # Include the results of the hardware scan.
    #./packages
    #./services
    #./tweaks
    ./efi
    ./firewall
    ./flatpaks
    ./fonts
    ./kde
    ./mnt
    ./nvidia
    ./samba
    ./scripts
    ./tmpfs
    
  ];

}

# sudo chown -R $(whoami):$(id -gn) /etc/nixos && sudo chmod -R 777 /etc/nixos && sudo chmod +x /etc/nixos/* && export NIXPKGS_ALLOW_INSECURE=1

