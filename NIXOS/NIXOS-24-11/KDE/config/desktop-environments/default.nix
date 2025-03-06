{ config, pkgs, ... }:

{
  imports = [
    # ---- Desktop Environment ---- #
    # ./cinnamon
    ./kde
    # ./gnome
  ];
}

# sudo chown -R $(whoami):$(id -gn) /etc/nixos && sudo chmod -R 777 /etc/nixos && sudo chmod +x /etc/nixos/* && export NIXPKGS_ALLOW_INSECURE=1

