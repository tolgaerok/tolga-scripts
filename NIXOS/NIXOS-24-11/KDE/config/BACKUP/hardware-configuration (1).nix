{ config, lib, pkgs, modulesPath, ... }:

{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  boot = {
    initrd.availableKernelModules = [
    "xhci_pci"
    "ahci"
    "uas"
    "usbhid"
    "sd_mod"
    "nvidia"
    "nvidia_modeset"
    "nvidia_uvm"
    "nvidia_drm"
    ];
    blacklistedKernelModules = lib.mkDefault [ "nouveau" ];
    kernelModules = [
    "cifs"
    "kvm-intel"
    "nvidia"
    "tcp_cubic"     # Cubic: A traditional and widely used congestion control algorithm
    "tcp_reno"      # Reno: Another widely used and stable algorithm
    "tcp_newreno"   # New Reno: An extension of the Reno algorithm with some improvements
    "tcp_bbr"       # BBR: Dynamically optimize how data is sent over a network, aiming for higher throughput and reduced latency
    "tcp_westwood"  # Westwood: Particularly effective in wireless networks
    ];
    extraModulePackages = [ ];
    kernel.sysctl = {
      "kernel.pty.max" = 24000;
      "net.ipv4.tcp_congestion_control" = "westwood";
    };
    kernelParams = [
      "fbcon=nodefer"
      "logo.nologo"
      "mitigations=off"
      "nvidia_drm.fbdev=1"
      "nvidia_drm.modeset=1"
      "quiet"
      "rd.systemd.show_status=auto"
      "rd.udev.log_level=3"
      "udev.log_level=3"
      "video.allow_duplicates=1"
      "nvidia.NVreg_EnablePCIeGen3=1"
      "nvidia.NVreg_UsePageAttributeTable=1"
      "nvidia.NVreg_RegistryDwords=RMUseSwI2c=0x01;RMI2cSpeed=100"
    ];
  };

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/b30a6664-33f2-407f-b8a2-0754da2c9147";
    fsType = "ext4";
    options = [
      "data=ordered"
      "defaults"
      "discard"
      "errors=remount-ro"
      "noatime"
      "nodiratime"
      "relatime"
    ];
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/1554-3D6A";
    fsType = "vfat";
    options = [
    "fmask=0077"
    "dmask=0077"
    ];
  };

  swapDevices = [ ];
  networking.useDHCP = lib.mkDefault true;
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
