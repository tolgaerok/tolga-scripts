{ config, pkgs, lib, ... }:
with lib;

{
  # ---------------------------------------------------------------------
  # Enable Direct Rendering Infrastructure (DRI) and OpenGL
  #---------------------------------------------------------------------
  hardware.graphics = {
    enable = true;
    enable32Bit = lib.mkDefault true; # Replaces driSupport32Bit

    #---------------------------------------------------------------------
    # Install additional packages that improve graphics performance and compatibility.
    #---------------------------------------------------------------------
    extraPackages = with pkgs; [
      intel-media-driver # LIBVA_DRIVER_NAME=iHD
      libvdpau-va-gl
      libva-utils
      nvidia-vaapi-driver
      vaapiIntel # LIBVA_DRIVER_NAME=i965 (older but works better for Firefox/Chromium)
      vaapiVdpau
      vulkan-validation-layers
    ];
  };
}

