{ config, pkgs, lib, username, ... }:

with lib;
let
  username = builtins.getEnv "USER";
  name = "tolga";  # Define the user name

  createUserXauthority = lib.mkForce ''
    if [ ! -f "/home/${name}/.Xauthority" ]; then
      xauth generate :0 . trusted
      touch /home/${name}/.Xauthority
      chmod 600 /home/${name}/.Xauthority
    fi
  '';
in
{
  #---------------------------------------------------------------------
  # Custom activationScripts
  #---------------------------------------------------------------------
  system.activationScripts = {

    # Custom Information Script shown after rebuilds
    # customInfoScript = lib.mkAfter ''
    #  ${pkgs.bash}/bin/bash /etc/nixos/core/system/systemd/custom-info-script.sh
    # '';

    #---------------------------------------------------------------------
    # Create personal directories
    #---------------------------------------------------------------------
    text = ''
      for dir in MUM DAD WORK SNU Documents Downloads Music Pictures Videos MyGit DLNA Applications Universal .icons .ssh; do
        mkdir -p /home/${name}/$dir
        chown ${name}:${name} /home/${name}/$dir
      done
    '';

    #---------------------------------------------------------------------
    # Create Thank-you note
    #---------------------------------------------------------------------
    thank-you = {
      text = ''
        cat << EOF > /home/${name}/THANK-YOU
        Tolga Erok
        10-6-2024
        My personal NIXOS 24-11 GNOME configuration.

        Thank you for using my personal NixOS GNOME 24-05 configuration.
        I hope you will enjoy my setup as much as I do.
        If you encounter any issues, please contact me via email: kingtolga@gmail.com


        ¯\_(ツ)_/¯  Date and time of system rebuild
        --------------------------------------------
        $(date '+%a - %b %d %l:%M %p')
        EOF
      '';
    };

    #---------------------------------------------------------------------
    # Create AutoStart shortcuts
    #---------------------------------------------------------------------
    megasync-start = {
      text = ''
        cat << EOF > /home/${name}/.config/autostart/megasync.desktop
        [Desktop Entry]
        Type=Application
        Version=1.0
        GenericName=File Synchronizer
        Name=MEGAsync
        Comment=Easy automated syncing between your computers and your MEGA cloud drive.
        TryExec=megasync
        Exec=megasync
        Icon=mega
        Terminal=false
        Categories=Network;System;
        StartupNotify=false
        X-GNOME-Autostart-Delay=2
        EOF
      '';
    };

    variety-start = {
      text = ''
        cat << EOF > /home/${name}/.config/autostart/variety.desktop
        [Desktop Entry]
        Name=Variety
        Comment=Variety Wallpaper Changer
        Categories=GNOME;GTK;Utility;
        Exec=variety %U
        MimeType=text/uri-list;x-scheme-handler/variety;x-scheme-handler/vrty;
        Icon=variety
        Terminal=false
        Type=Application
        StartupNotify=false
        Actions=Next;Previous;PauseResume;History;Preferences;
        Keywords=Wallpaper;Changer;Change;Download;Downloader;Variety;
        StartupWMClass=Variety

        [Desktop Action Next]
        Exec=variety --next
        Name=Next

        [Desktop Action Previous]
        Exec=variety --previous
        Name=Previous

        [Desktop Action PauseResume]
        Exec=variety --toggle-pause
        Name=Pause / Resume

        [Desktop Action History]
        Exec=variety --history
        Name=History

        [Desktop Action Preferences]
        Exec=variety --preferences
        Name=Preferences
        EOF
      '';
    };

    rygel-start = {
      text = ''
        cat << EOF > /home/${name}/.config/autostart/rygel-preferences.desktop
        [Desktop Entry]
        Type=Application
        Version=1.0
        GenericName=DLNA Media Server
        Name=Rygel Preferences
        Comment=Configure Rygel settings
        TryExec=rygel-preferences
        Exec=rygel-preferences
        Icon=rygel
        Terminal=false
        Categories=Network;System;
        StartupNotify=false
        X-GNOME-Autostart-Delay=1
        EOF
      '';
    };

  };
}

