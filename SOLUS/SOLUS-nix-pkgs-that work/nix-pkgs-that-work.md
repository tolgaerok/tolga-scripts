# ----------      Solus related       ------------ ###
 - Tolga Erok
 - 8/1/2024

### ------------------------------------------------ ###
### Various nix packages to work on solus
### ------------------------------------------------ ###

    export NIXPKGS_ALLOW_UNFREE=1 && nix-env -iA nixpkgs.wpsoffice
    export NIXPKGS_ALLOW_UNFREE=1 && nix-env -iA nixpkgs.anydesk


### ------------------------------------------------ ###
### Akonadi for calender and etc to work on solus
### ------------------------------------------------ ###
  
    nix-env -iA nixpkgs.libsForQt5.akonadi
    nix-env -iA nixpkgs.libsForQt5.akonadi
    nix-env -iA nixpkgs.libsForQt5.akonadi-calendar
    nix-env -iA nixpkgs.libsForQt5.akonadi-calendar
    nix-env -iA nixpkgs.libsForQt5.akonadi-calendar-tools
    nix-env -iA nixpkgs.libsForQt5.akonadi-contacts
    nix-env -iA nixpkgs.libsForQt5.akonadi-import-wizard
    nix-env -iA nixpkgs.libsForQt5.akonadi-notes
    nix-env -iA nixpkgs.libsForQt5.akonadi-search
  # nix-env -iA nixpkgs.libsForQt5.akonadi-mime
  # nix-env -iA nixpkgs.libsForQt5.merkuro

### ------------------------------------------------ ###
### Fortune and DUF
### ------------------------------------------------ ###
    
    nix-env -iA nixpkgs.fortune
    export NIXPKGS_ALLOW_UNFREE=1 && nix-env -iA nixpkgs.megasync 

### ------------------------------------------------ ###
### BASHRC, must add in order for fortune to work
### ------------------------------------------------ ###
    
    alias solus='sudo mount -a && sudo systemctl daemon-reload && sudo udevadm control --reload-rules && sudo udevadm trigger && sudo sysctl --system'

    # Check if the system is Solus
    if [ -f "/usr/bin/eopkg" ]; then
        # Solus system
        export PATH="/home/tolga/.nix-profile/bin:$PATH"
        FORTUNE_COMMAND="/home/tolga/.nix-profile/bin/fortune"
    else
        # Other distro
        FORTUNE_COMMAND="fortune"
    fi

    # Display a fortune message when opening a new Bash session
    echo "" && $FORTUNE_COMMAND && echo ""

### ------------------------------------------------ ###
### MegaSync desktop icon
### ------------------------------------------------ ###
    
    # Location
    /home/tolga/.local/share/applications/

    # Create megasync.desktop && add
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
    X-GNOME-Autostart-Delay=60
