{
  config,
  pkgs,
  lib,
  ...
}:

with lib;

let
  add = "${pkgs.openssh}/bin/ssh-add";
  agent = "${pkgs.openssh}/bin/ssh-agent";
  keygen = "${pkgs.openssh}/bin/ssh-keygen";

  genSshKey = pkgs.writeShellScriptBin "gen-ssh-key" ''
    ${keygen} -t ed25519 -C "$1"
    eval $(${agent} -s)
    ${add} $HOME/.ssh/id_ed25519
  '';
in

{
  imports = [
    # USE NIX FMT ONLINE:           https://nixfmt.serokell.io/
    ./config
    ./hardware-configuration.nix
  ];
  
  # ---------------------------------------------
  # SYSTEM WIDE PACKAGES
  # ---------------------------------------------
  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    #  vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    #  wget
    kdePackages.kate
    kdePackages.konsole
    qt5.qtwayland
    qt5.qtbase
    
    genSshKey
    gimp-with-plugins
    variety
    lolcat
    fortune
    figlet
    flatpak
    direnv
    duf
    megasync
    git
    # ---------------------------------------------------------------------
    # Archive Utilities
    # ---------------------------------------------------------------------
      atool     # a script for managing file archives of various types
                # provides: apack arepack als adiff atool aunpack acat
                #
                # examples: atool -x WPS-FONTS.zip    ==> this extracts the compressed file
                #           atool -l WPS-FONTS.zip    ==> this lists the contents of the compressed file
                #           atool -a name-your-compression.rar 1.pdf 2.pdf 3.sh    ==> this adds indovidual files to the compressed file

      gzip      # GNU zip compression program
                # provides: gunzip zmore zegrep zfgrep zdiff zcmp uncompress gzip znew zless zcat zforce gzexe zgrep

      lz4       # GNU zip compression program
                # provides: lz4c lz4 unlz4 lz4cat

      lzip      # A lossless data compressor based on the LZMA algorithm
                # provides: lzip

      lzo       # Real-time data (de)compression library

      lzop      # Fast file compressor
                # provides: lzop

      p7zip     # A new p7zip fork with additional codecs and improvements (forked from https://sourceforge.net/projects/p7zip/)
                # provides: 7zr 7z 7za

      rar       # Utility for RAR archives

      rzip      # Compression program
                # provides: rzip

      unzip     # An extraction utility for archives compressed in .zip format
                # provides: zipinfo unzipsfx zipgrep funzip unzip

      xz        # A general-purpose data compression software, successor of LZMA
                # provides: lzfgrep lzgrep lzma xzegrep xz unlzma lzegrep lzmainfo lzcat xzcat xzfgrep xzdiff
                #           lzmore xzgrep xzdec lzdiff xzcmp lzmadec xzless xzmore unxz lzless lzcmp

      zip       # Compressor/archiver for creating and modifying zipfiles
                # provides: zipsplit zipnote zip zipcloak

      zstd      # Zstandard real-time compression algorithm
                # provides: zstd pzstd zstdcat zstdgrep zstdless unzstd zstdmt

      # ---------------------------------------------------------------------
      # Multimedia Utilities
      # ---------------------------------------------------------------------
      audacity                        # Sound editor with graphical UI
      ffmpeg                          # A complete, cross-platform solution to record, convert and stream audio and video
                                      # provides: ffprobe ffmpeg
      ffmpegthumbnailer               # A lightweight video thumbnailer
      libdvdcss                       # A library for decrypting DVDs
      libdvdread                      # A library for reading DVDs
      libopus                         # Open, royalty-free, highly versatile audio codec
      libvorbis                       # Vorbis audio compression reference implementation
      mediainfo                       # Supplies technical and tag information about a video or audio file
      mediainfo-gui                   # Supplies technical and tag information about a video or audio file (GUI version)
      mpg123                          # Fast console MPEG Audio Player and decoder library
                                      # provides: out123 conplay mpg123-id3dump mpg123 mpg123-strip
      mplayer                         # A movie player that supports many video formats
                                      # provides: gmplayer mplayer mencoder
      mpv                             # General-purpose media player, fork of MPlayer and mplayer2
      ocamlPackages.gstreamer         # Bindings for the GStreamer library which provides functions for playning and manipulating multimedia streams
                                      # provides: mpv mpv_identify.sh umpv
      simplescreenrecorder            # A screen recorder for Linux
                                      # provides: ssr-glinject simplescreenrecorder
      video-trimmer                   # Trim videos quickly

      # ---------------------------------------------------------------------
      # Deduplicating archiver with compression and encryption softwar
      # ---------------------------------------------------------------------
      borgbackup                      # Deduplicating archiver with compression and encryption
                                      # provides: borgfs, borg

      restic                          # A backup program that is fast, efficient and secure
                                      # https://www.youtube.com/watch?v=MzJbSf7GQ1E

      restique                        # Restic GUI for Desktop/Laptop Backups
      
      # ---------------------------------------------------------------------
      # Code Search and Analysis:
      # ---------------------------------------------------------------------
      ripgrep                         # A utility that combines the usability of The Silver Searcher with the raw speed of grep
                                      # rg

      ripgrep-all                     # Ripgrep, but also search in PDFs, E-Books, Office documents, zip, tar.gz, and more
                                      # provides: rga-preproc rga

      # ---------------------------------------------------------------------
      # Utilities
      # ---------------------------------------------------------------------
      # graalvm17-ce                    # High-Performance Polyglot VM
      # mosh                            # Mobile shell (ssh replacement)
      # sublime4                        # Sophisticated text editor for code, markup and prose
      direnv                            # A shell extension that manages your environment
      nix-direnv                        # A fast, persistent use_nix implementation for direnv
      nixfmt-classic                    # An opinionated formatter for Nix
      # nix-linter                      # to check for several common mistakes or stylistic errors in Nix expressions, such as unused arguments, empty let blocks, etcetera.
      nixos-option
      vscode                            # Open source source code editor developed by Microsoft for Windows, Linux and macOS
      vscode-extensions.brettm12345.nixfmt-vscode
      vscode-extensions.mkhl.direnv
  ];  

  #---------------------------------------------------------------------
  # Allow unfree packages
  #---------------------------------------------------------------------
  environment.sessionVariables.NIXPKGS_ALLOW_UNFREE = "1";

  xdg.portal = {
    enable = true;
    xdgOpenUsePortal = true;
    lxqt = {
      enable = false;
      styles =
        with pkgs;
        with libsForQt5;
        [
          breeze-qt5
          catppuccin-kvantum
          qtcurve
          qtstyleplugin-kvantum
        ];
    };
    # Turn Wayland off
    wlr.enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-gtk
      xdg-desktop-portal-kde
      xdg-desktop-portal-wlr
    ];
  };
  system = {
    stateVersion = "24.11"; # Did you read the comment?
    copySystemConfiguration = true;
    autoUpgrade = {
      enable = true;
      operation = "boot";
      dates = "Mon 04:40";
      channel = "https://nixos.org/channels/nixos-unstable";
      allowReboot = false;
    };
  };
}
