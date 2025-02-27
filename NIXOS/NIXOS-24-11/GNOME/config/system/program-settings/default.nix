{
  lib,
  config,
  pkgs,
  ...
}:

with lib;
{
  # ---------------------------------------------
  # PROGRAM SETTINGS 
  # ---------------------------------------------
  programs = {
    firefox.enable = true;
    # direnv.enable = true;
    direnv = {
      enable = true;
      nix-direnv.enable = true;
    };
    # Some programs need SUID wrappers, can be configured further or are started in user sessions.
    # mtr.enable = true;
    gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
    };
  };
}
