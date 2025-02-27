{ config, lib, pkgs, modulesPath, ... }:

{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    # Add other necessary imports if needed
    # ./nvidia-docker.nix
    # ./opengl.nix
  ];

  boot = {

    # Kernel modules that should be loaded during boot
    kernelModules = [
      "kvm-intel"
      #"nvidia"
      #"nvidia_drm"
      #"nvidia_modeset"
      #"nvidia_uvm"
    ];

    extraModulePackages = [
      # Add any extra kernel modules packages if needed
    ];

    kernelParams = [
      "fbcon=nodefer"
      "io_delay=none"
      "iomem=relaxed"
      "logo.nologo"
      "mitigations=off"
      "quiet"
      "rd.systemd.show_status=auto"
      "rd.udev.log_level=3"
      "rootdelay=0"
      "splash"
      "udev.log_level=3"
    ];

    # Initialize the kernel modules during initrd
    initrd = {
      availableKernelModules = [ 
        "ahci" 
        "sd_mod" 
        "uas" 
        "usbhid" 
        "xhci_pci" 
      ];
      kernelModules = [
        # No need to load NVIDIA modules in initrd as they are handled later
      ];
    };
  };

  # Set up filesystem for root and boot partitions
  fileSystems."/" = {
    device = "/dev/disk/by-uuid/270cc5a5-8ba5-40ae-b3b0-a32697a901ff";
    fsType = "ext4";
    options = [ 
      "defaults" 
      "discard" 
      "noatime" 
      "nodiratime" 
      "relatime" 
    ];
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/972B-7592";
    fsType = "vfat";
    options = [ 
      "dmask=0077" 
      "fmask=0077" 
    ];
  };

  swapDevices = [ ];

  # Network settings
  networking.useDHCP = lib.mkDefault true;

  # Platform settings for nixpkgs
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

  # Enable microcode updates for Intel CPUs
  hardware.cpu.intel.updateMicrocode =
    lib.mkDefault config.hardware.enableRedistributableFirmware;
}

