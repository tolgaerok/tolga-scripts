{ config, lib, pkgs, ... }:
{
  imports = [
    ./opengl.nix
    # Add other necessary imports if needed
    # ./nvidia-docker.nix
    # ./vaapi.nix
  ];

  # Enable firmware
  hardware.enableAllFirmware = true;

  # NVIDIA configuration
  hardware.nvidia = {
    modesetting.enable = true;
    nvidiaPersistenced = true;
    powerManagement = {
      enable = true;
      finegrained = false;
    };
    open = true;
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };

  # Load NVIDIA driver for Xorg and Wayland
  services.xserver.videoDrivers = [ "nvidia" ];

  # Set environment variables related to NVIDIA graphics
  environment.variables = {
    GBM_BACKEND = "nvidia-drm";                     # Required for Wayland support
    __GLX_VENDOR_LIBRARY_NAME = "nvidia";           # Ensures correct GLX vendor
    LIBVA_DRIVER_NAME = "nvidia";                   # Ensures VA-API uses NVIDIA
    WLR_NO_HARDWARE_CURSORS = "1";                  # Fixes hardware cursor issues
    NIXOS_OZONE_WL = "1";                           # Enables Ozone on Wayland
    __GL_THREADED_OPTIMIZATION = "1";               # Enables threaded optimizations
    __GL_SHADER_CACHE = "1";                        # Enables shader caching
  };

  # Additional NVIDIA kernel module options
  boot.extraModprobeConfig = lib.concatStringsSep " " [
    "options nvidia"
    "NVreg_UsePageAttributeTable=1"  # Assume CPU supports PAT (performance improvement)
    "NVreg_EnablePCIeGen3=1"         # Enables PCIe Gen3 (can improve bandwidth)
    "NVreg_RegistryDwords=RMUseSwI2c=0x01;RMI2cSpeed=100"  # Enables DDC/CI support
  ];
}
