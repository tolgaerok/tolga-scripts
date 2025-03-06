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
    
    kernel.sysctl = {
      #---------------------------------------------------------------------
      #   Network and memory-related optimizationss for 32GB
      #---------------------------------------------------------------------
      "kernel.sysrq" = 1;                         # Enable SysRQ for rebooting the machine properly if it freezes. [Source](https://oglo.dev/tutorials/sysrq/index.html)
      "net.core.netdev_max_backlog" = 30000;      # Help prevent packet loss during high traffic periods.
      "net.core.rmem_default" = 262144;           # Default socket receive buffer size, improve network performance & applications that use sockets. Adjusted for 32GB RAM.
      "net.core.rmem_max" = 67108864;             # Maximum socket receive buffer size, determine the amount of data that can be buffered in memory for network operations. Adjusted for 32GB RAM.
      "net.core.wmem_default" = 262144;           # Default socket send buffer size, improve network performance & applications that use sockets. Adjusted for 32GB RAM.
      "net.core.wmem_max" = 67108864;             # Maximum socket send buffer size, determine the amount of data that can be buffered in memory for network operations. Adjusted for 32GB RAM.
      "net.ipv4.ipfrag_high_threshold" = 5242880; # Reduce the chances of fragmentation. Adjusted for SSD.
      "net.ipv4.tcp_keepalive_intvl" = 30;        # TCP keepalive interval between probes to detect if a connection is still alive.
      "net.ipv4.tcp_keepalive_probes" = 5;        # TCP keepalive probes to detect if a connection is still alive.
      "net.ipv4.tcp_keepalive_time" = 300;        # TCP keepalive interval in seconds to detect if a connection is still alive.
      "vm.dirty_background_bytes" = 134217728;    # 128 MB
      "vm.dirty_bytes" = 402653184;               # 384 MB
      "vm.min_free_kbytes" = 65536;               # Minimum free memory for safety (in KB), helping prevent memory exhaustion situations. Adjusted for 32GB RAM.
      "vm.swappiness" = 5;                        # Adjust how aggressively the kernel swaps data from RAM to disk. Lower values prioritize keeping data in RAM. Adjusted for 32GB RAM.
      "vm.vfs_cache_pressure" = 90;               # Adjust vfs_cache_pressure (0-1000) to manage memory used for caching filesystem objects. Adjusted for 32GB RAM.

      # Nobara Tweaks  
      "fs.aio-max-nr" = 1000000;                  # defines the maximum number of asynchronous I/O requests that can be in progress at a given time.     1048576
      "fs.inotify.max_user_watches" = 65536;      # sets the maximum number of file system watches, enhancing file system monitoring capabilities.       Default: 8192  TWEAKED: 524288
      "kernel.panic" = 5;                         # Reboot after 5 seconds on kernel panic                                                               Default: 0
      "kernel.pid_max" = 131072;                  # allows a large number of processes and threads to be managed                                         Default: 32768 TWEAKED: 4194304

      "kernel.pty.max" = 24000;
      "net.ipv4.tcp_congestion_control" = "westwood";   # sets the TCP congestion control algorithm to Westwood for IPv4 in the Linux kernel.
      # "kernel.sysrq" = 1;
      # "net.ipv4.tcp_congestion_control" = "bbr";
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
      "discard" 
      "noatime" 
      # "defaults" 
      # "nodiratime" 
      # "relatime" 
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


