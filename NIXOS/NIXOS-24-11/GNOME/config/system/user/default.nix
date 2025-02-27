{ 
config, 
pkgs, 
lib, 
username, 
name, 
hostname, 
... 
}:

with lib;
let
  name = "tolga";  # Define the user name
in
{
  #---------------------------------------------------------------------
  # User account settings
  #---------------------------------------------------------------------
  # User and group configuration
  users = {
    groups.${name} = { };
    users."${name}" = {
      isNormalUser = true;
      description = "${name}";
      uid = 1000;
      shell = pkgs.bashInteractive;  # Define the user's shell
      extraGroups = [
        "${name}"
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
        "wheel"
        "code"
      ];
      packages = with pkgs; [
        kdePackages.kate
      ];
    };
  };
}

