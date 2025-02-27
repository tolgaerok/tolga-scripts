{ 
config, 
pkgs, 
lib, 
username, 
... 
}:

{
  # ---------------------------------------------
  # SERVICES 
  # ---------------------------------------------
  services = {
    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      # If you want to use JACK applications, uncomment this
      # jack.enable = true;
      # use the example session manager (enabled by default, no need to redefine)
      # media-session.enable = true;
    };
    gnome.rygel.enable = true;
    fstrim = {
      enable = true;
    };
    flatpak = {
      enable = true;
    };
    dbus = {
      enable = true;
      packages = with pkgs; [
        miraclecast
        dconf
        gcr
        udisks2
      ];
    };
    # IO Scheduler based on device type
    udev.extraRules = ''
      # HDD
      ACTION=="add|change", KERNEL=="sd[a-z]*", ATTR{queue/rotational}=="1", ATTR{queue/scheduler}="bfq"
      # SSD
      ACTION=="add|change", KERNEL=="sd[a-z]*|mmcblk[0-9]*", ATTR{queue/rotational}=="0", ATTR{queue/scheduler}="mq-deadline"
      # NVMe SSD
      ACTION=="add|change", KERNEL=="nvme[0-9]*", ATTR{queue/rotational}=="0", ATTR{queue/scheduler}="none"
    '';
    # Enable system services
    openssh.enable = true;
    locate = {
      enable = true;
      package = pkgs.mlocate;
      localuser = null;
    };
    xserver = {
      enable = true;
      xkb = {
        layout = "au";
        variant = "";
      };
    };
    envfs.enable = true;
    timesyncd.enable = true;
    gvfs.enable = true;
    fwupd.enable = true;
    logind = {
      extraConfig = ''
        # Set the maximum size of runtime directories to 100%
        RuntimeDirectorySize=100%

        # Set the maximum number of inodes in runtime directories to 1048576
        RuntimeDirectoryInodesMax=1048576
      '';
    };
    # Enable Avahi for network service discovery
    avahi = {
      enable = true;
      nssmdns4 = true;
      openFirewall = true;
      publish = {
        addresses = true;
        domain = true;
        enable = true;
        hinfo = true;
        userServices = true;
        workstation = true;
      };
      extraServiceFiles = {
        smb = ''
          <?xml version="1.0" standalone='no'?><!--*-nxml-*-->
          <!DOCTYPE service-group SYSTEM "avahi-service.dtd">
          <service-group>
            <name replace-wildcards="yes">%h</name>
            <service>
              <type>_smb._tcp</type>
              <port>445</port>
            </service>
          </service-group>
        '';
      };
    };
  };
}
