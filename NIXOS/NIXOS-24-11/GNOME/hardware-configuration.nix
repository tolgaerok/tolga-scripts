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
    extraModulePackages = [];
    
    kernel.sysctl = {
      # Network and memory-related optimizations for 32GB
      
      # General Networking Performance Tweaks
      "net.core.default_qdisc" = "cake";
      "net.core.netdev_max_backlog" = 30000;
      "net.core.rmem_default" = 262144;
      "net.core.rmem_max" = 1073741824;
      "net.core.wmem_default" = 262144;
      "net.core.wmem_max" = 1073741824;
      
      # TCP Performance Optimizations
      "net.ipv4.tcp_congestion_control" = "bbr";
      "net.ipv4.tcp_ecn" = 1;
      "net.ipv4.tcp_fastopen" = 3;
      "net.ipv4.tcp_low_latency" = 1;
      "net.ipv4.tcp_mtu_probing" = 1;
      "net.ipv4.tcp_rmem" = "4096 87380 1073741824";
      "net.ipv4.tcp_wmem" = "4096 87380 1073741824";
      "net.ipv4.tcp_window_scaling" = 1;
      
      # IPv4 Security & Optimization
      "net.ipv4.conf.all.accept_redirects" = 0;
      "net.ipv4.conf.all.send_redirects" = 0;
      "net.ipv4.conf.default.accept_redirects" = 0;
      "net.ipv4.conf.default.send_redirects" = 0;
      
      # Virtual Memory Settings
      "vm.swappiness" = 5;
      "vm.dirty_background_ratio" = 10;
      "vm.dirty_expire_centisecs" = 600;
      "vm.dirty_ratio" = 20;
      "vm.dirty_writeback_centisecs" = 150;
      "vm.min_free_kbytes" = 65536;
      "vm.overcommit_memory" = 1;
      "vm.overcommit_ratio" = 80;
      "vm.page-cluster" = 3;
      "vm.vfs_cache_pressure" = 90;
      
      # CPU Scheduler Performance Optimization
      "kernel.sched_child_runs_first" = 0;
      
      # Nobara Tweaks (Additional Optimizations)
      "fs.aio-max-nr" = 1000000;
      "fs.inotify.max_user_watches" = 65536;
      "kernel.panic" = 5;
      "kernel.pid_max" = 131072;
      "kernel.pty.max" = 24000;
      "kernel.sysrq" = 1;
    };
    
    kernelParams = [
      "fbcon=nodefer"
      "io_delay=none"
      "iomem=relaxed"
      "logo.nologo"
      "mitigations=off"
      "nvidia_drm.fbdev=1" 
      "nvidia_drm.modeset=1" 
      "quiet"
      "rd.systemd.show_status=auto"
      "rd.udev.log_level=3"
      "rootdelay=0"
      "splash"
      "udev.log_level=3"
      "video.allow_duplicates=1"
      "wayland"
    ];
    
    initrd = {
      availableKernelModules = [ "ahci" "sd_mod" "uas" "usbhid" "xhci_pci" ];
      kernelModules = [];
    };
  };

  # Set up filesystem for root and boot partitions
  fileSystems."/" = {
    device = "/dev/disk/by-uuid/270cc5a5-8ba5-40ae-b3b0-a32697a901ff";
    fsType = "ext4";
    options = [ "discard" "noatime" ];
  };
  
  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/972B-7592";
    fsType = "vfat";
    options = [ "dmask=0077" "fmask=0077" ];
  };

  swapDevices = [];
  
  # Network settings
  networking.useDHCP = lib.mkDefault true;
  
  # Platform settings for nixpkgs
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  
  # Enable microcode updates for Intel CPUs
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}