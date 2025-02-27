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
  # ENVIRONMENT SESSION VARIABLES (Bash)
  # ---------------------------------------------
  environment = {
    sessionVariables = {
      # Wayland
      MOZ_ENABLE_WAYLAND = "1";
      MOZ_USE_XINPUT2 = "1";
      QT_QPA_PLATFORM = "wayland";
      QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
      SDL_VIDEODRIVER = "wayland";
      NIXOS_OZONE_WL = "1";
      NIXPKGS_ALLOW_UNFREE = "1";
    };
  };  
}

