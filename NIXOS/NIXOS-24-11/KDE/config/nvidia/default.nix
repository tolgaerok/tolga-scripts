
{
  config,
  lib,
  pkgs,
  ...
}:
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
      finegrained = true;
    };
    open = true;
    nvidiaSettings = true;
    # package = config.boot.kernelPackages.nvidiaPackages.stable;
    package = config.boot.kernelPackages.nvidiaPackages.latest;
  };
  vaapi = {
    enable = true;
    firefox.enable = true;
  };
  # Load NVIDIA driver for Xorg and Wayland
  services.xserver.videoDrivers = [ "nvidia" ];

  # Set environment variables related to NVIDIA graphics
  environment.variables = {
    GBM_BACKEND = "nvidia-drm";             # Required for Wayland support
    __GLX_VENDOR_LIBRARY_NAME = "nvidia";   # Ensures correct GLX vendor
    LIBVA_DRIVER_NAME = "nvidia";           # Ensures VA-API uses NVIDIA
    WLR_NO_HARDWARE_CURSORS = "1";          # Fixes hardware cursor issues
    NIXOS_OZONE_WL = "1";                   # Enables Ozone on Wayland
    __GL_THREADED_OPTIMIZATION = "1";       # Enables threaded optimizations
    __GL_SHADER_CACHE = "1";                # Enables shader caching
    MOZ_ENABLE_WAYLAND = "1";               # Enables Wayland support in Mozilla applications (e.g., Firefox).

  };
  # Additional NVIDIA kernel module options
  boot.extraModprobeConfig = lib.concatStringsSep " " [
    "options nvidia NVreg_UsePageAttributeTable=1"                        # Assume CPU supports PAT (performance improvement)
    "options nvidia NVreg_EnablePCIeGen3=1"                               # Enables PCIe Gen3 (can improve bandwidth)
    "options nvidia NVreg_RegistryDwords=RMUseSwI2c=0x01;RMI2cSpeed=100"  # Enables DDC/CI support
    "options nvidia NVreg_EnableMSI=1"                                    # Enable MSI interrupts
    "options nvidia NVreg_PreserveVideoMemoryAllocations=1"               # Preserve video memory allocations
    "options nvidia NVreg_TemporaryFilePath=/var/tmp"                     # Set temporary file path
  ];
}

