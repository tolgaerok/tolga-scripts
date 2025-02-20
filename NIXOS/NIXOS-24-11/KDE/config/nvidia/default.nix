
let
/*
 * What you're seeing here is our nix formatter. It's quite opinionated:
 */
  sample-01 = { lib }:
{
  list = [
    elem1
    elem2
    elem3
  ] ++ lib.optionals stdenv.isDarwin [
    elem4
    elem5
  ]; # and not quite finished
}; # it will preserve your newlines

  sample-02 = { stdenv, lib }:
{
  list =
    [
      elem1
      elem2
      elem3
    ]
    ++ lib.optionals stdenv.isDarwin [ elem4 elem5 ]
    ++ lib.optionals stdenv.isLinux [ elem6 ]
    ;
};
# but it can handle all nix syntax,
# and, in fact, all of nixpkgs in <20s.
# The javascript build is quite a bit slower.
 sample-03 = { stdenv, system }:
assert system == "i686-linux";
stdenv.mkDerivation { };
# these samples are all from https://github.com/nix-community/nix-fmt/tree/master/samples
sample-simple = # Some basic formatting
{
  empty_list = [ ];
  inline_list = [ 1 2 3 ];
  multiline_list = [
    1
    2
    3
    4
  ];
  inline_attrset = { x = "y"; };
  multiline_attrset = {
    a = 3;
    b = 5;
  };
  # some comment over here
  fn = x: x + x;
  relpath = ./hello;
  abspath = /hello;
  # URLs get converted from strings
  url = "https://foobar.com";
  atoms = [ true false null ];
  # Combined
  listOfAttrs = [
    {
      attr1 = 3;
      attr2 = "fff";
    }
    {
      attr1 = 5;
      attr2 = "ggg";
    }
  ];

  # long expression
  attrs = {
    attr1 = short_expr;
    attr2 =
      if true then big_expr else big_expr;
  };
}
;
in
[ sample-01 sample-02 sample-03 ]
  

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
      finegrained = false;
    };
    open = true;
    nvidiaSettings = true;
    #package = config.boot.kernelPackages.nvidiaPackages.stable;
    package = config.boot.kernelPackages.nvidiaPackages.latest;
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
    "options nvidia"
    "NVreg_UsePageAttributeTable=1" # Assume CPU supports PAT (performance improvement)
    "NVreg_EnablePCIeGen3=1" # Enables PCIe Gen3 (can improve bandwidth)
    "NVreg_RegistryDwords=RMUseSwI2c=0x01;RMI2cSpeed=100" # Enables DDC/CI support
  ];
}

