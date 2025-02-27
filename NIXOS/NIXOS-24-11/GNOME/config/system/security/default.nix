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
  # ---------------------------------------------
  # Various Security Mods
  # ---------------------------------------------
  security = {
    allowSimultaneousMultithreading = true;
    rtkit.enable = true;
    sudo = {
      enable = true;
      wheelNeedsPassword = false;
    };
  };
}
