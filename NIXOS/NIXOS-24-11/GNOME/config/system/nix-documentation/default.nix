{
  lib,
  config,
  pkgs,
  ...
}:

with lib;
{
  # ---------------------------------------------
  # SYSTEM DOCUMENTATION, DISABLE TO SPEED UP REBUILDS 
  # ---------------------------------------------
  documentation = {
    doc.enable = false;
    info.enable = false;
    nixos.enable = false;
    man = {
      generateCaches = true;
    };
  };
}
