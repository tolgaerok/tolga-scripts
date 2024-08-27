# Wake monitors after suspend fix
### Tolga Erok
### 6 Aug 2024

#

A collection of scripts designed by `Tolga Erok` to address various system tasks, including a specific script to `wake monitors` after a system `suspend`. The script handles both `X11` and `Wayland` sessions, and is integrated with a `systemd service` to ensure it runs after login or suspend on Fedora 40.

Currently, I'm using Example `4` from `wake_monitor.sh` and Example `3` from the `systemd` service section. I hope these scripts and systemd configurations help others experiencing blank screen issues after suspend, especially with Nvidia setups like mine on Nvidia drivers 555xx.

#
Setting the display configurations directly is to first find out your monitor setup:


```bash
xrandr | grep ' connected'

```
Mine is
```bash
HDMI-0 connected primary 1920x1080+0+0 (normal left inverted right x axis y axis) 598mm x 336mm
DP-0 connected 1920x1080+1920+0 (normal left inverted right x axis y axis) 598mm x 336mm
```
#

Steps:

1. **Create the script**:  `sudo nano /usr/local/bin/wake_monitors.sh`

- EXAMPLE (1)
```bash
#!/bin/bash
# Tolga Erok
# Aug 6 2024
   
export DISPLAY=:0

# X11 on GNOME
xrandr --output HDMI-0 --auto --primary
xrandr --output DP-0 --auto --right-of HDMI-0
```

- EXAMPLE (2)
```bash
#!/bin/bash
# Tolga Erok
# Aug 6 2024
   
if [ "$XDG_SESSION_TYPE" = "x11" ]; then
export DISPLAY=:0   
   # X11 on GNOME
   xrandr --output HDMI-0 --auto --primary
   xrandr --output DP-0 --auto --right-of HDMI-0
  
elif [ "$XDG_SESSION_TYPE" = "wayland" ]; then
     if [ "$XDG_CURRENT_DESKTOP" = "GNOME" ]; then
       # GNOME on Wayland
       gsettings set org.gnome.desktop.interface enable-animations false
       sleep 0.1
       gsettings set org.gnome.desktop.interface enable-animations true
       # Restart GNOME Shell
       gnome-shell --replace &
   
elif [ "$XDG_CURRENT_DESKTOP" = "KDE" ]; then
       # KDE on Wayland
       kscreen-doctor output.HDMI-0.enable
       kscreen-doctor output.HDMI-0.position.0,0
       kscreen-doctor output.HDMI-0.primary
       kscreen-doctor output.DP-0.enable
       kscreen-doctor output.DP-0.position.1920,0
     fi
fi
   ```

- EXAMPLE (3)
```bash
#!/bin/bash
# Tolga Erok
# Aug 6 2024

# X11 display settings
handle_x11() {
  export DISPLAY=:0
  if [ "$XDG_CURRENT_DESKTOP" = "GNOME" ]; then
    # X11 on GNOME
    xrandr --output HDMI-0 --auto --primary
    xrandr --output DP-0 --auto --right-of HDMI-0

  elif [ "$XDG_CURRENT_DESKTOP" = "KDE" ]; then
    # X11 on KDE
    xrandr --output HDMI-0 --auto --primary
    xrandr --output DP-0 --auto --right-of HDMI-0
  fi
}

# Wayland display settings
handle_wayland() {
  if [ "$XDG_CURRENT_DESKTOP" = "GNOME" ]; then
    # GNOME on Wayland
    gsettings set org.gnome.desktop.interface enable-animations false
    sleep 0.1
    gsettings set org.gnome.desktop.interface enable-animations true
    # Restart GNOME Shell
    gnome-shell --replace &

  elif [ "$XDG_CURRENT_DESKTOP" = "KDE" ]; then
    # KDE on Wayland
    kscreen-doctor output.HDMI-0.enable
    kscreen-doctor output.HDMI-0.position.0,0
    kscreen-doctor output.HDMI-0.primary
    kscreen-doctor output.DP-0.enable
    kscreen-doctor output.DP-0.position.1920,0
  fi
}

# Main execution
if [ "$XDG_SESSION_TYPE" = "x11" ]; then
  handle_x11
elif [ "$XDG_SESSION_TYPE" = "wayland" ]; then
  handle_wayland
fi
```

- EXAMPLE (4)
```bash
#!/bin/bash
# Tolga Erok
# Aug 6 2024

export XAUTHORITY=$HOME/.Xauthority
log_file="/tmp/display_settings.log"

log() {
    echo "$(date) - $1" >> $log_file
}

handle_x11() {
    log "Setting X11 display settings"
    export DISPLAY=:0

    if [ "$XDG_CURRENT_DESKTOP" = "KDE" ]; then
        xrandr --output HDMI-0 --auto --primary
        xrandr --output DP-0 --auto --right-of HDMI-0
        log "X11 on KDE: HDMI-0 set as primary, DP-0 set right-of HDMI-0"
    fi
}

handle_wayland() {
    log "Setting Wayland display settings"

    if [ "$XDG_CURRENT_DESKTOP" = "KDE" ]; then
        kscreen-doctor output.HDMI-0.enable
        sleep 0.5
        kscreen-doctor output.HDMI-0.position.0,0
        sleep 0.5
        kscreen-doctor output.HDMI-0.primary
        sleep 0.5
        kscreen-doctor output.DP-0.enable
        sleep 0.5
        kscreen-doctor output.DP-0.position.1920,0
        log "Wayland on KDE: HDMI-0 and DP-0 configured"
    fi
}

log "Script execution started"
if [ "$XDG_SESSION_TYPE" = "x11" ]; then
    handle_x11
elif [ "$XDG_SESSION_TYPE" = "wayland" ]; then
    handle_wayland
else
    log "Unknown session type: $XDG_SESSION_TYPE"
fi
log "Script execution finished"
```
#

- Log ouput:

![image](https://github.com/user-attachments/assets/e4f3cea4-1ea6-4133-afdf-680547a0c06c)

#

Make the script executable:

```bash
sudo chmod +x /usr/local/bin/wake_monitors.sh
```
#
2. **Create the systemd service file**:  `sudo nano /etc/systemd/system/wake_monitors.service` 
- Change `User` to suite: `User=tolga`
   

   - EXAMPLE (1)
   ```ini
   [Unit]
   Description=Wake monitor(s) after login or suspend
   After=graphical.target suspend.target

   [Service]
   Type=oneshot
   ExecStart=/usr/local/bin/wake_monitors.sh
   User=tolga
   Environment=DISPLAY=:0

   [Install]
   WantedBy=graphical.target suspend.target
   ```

   - EXAMPLE (2)
   ```ini
   [Unit]
   Description=Wake monitor(s) after login or suspend
   After=graphical.target suspend.target

   [Service]
   Type=oneshot
   ExecStart=/usr/local/bin/wake_monitors.sh
   User=tolga
   Environment="DISPLAY=:0"
   Environment="XDG_SESSION_TYPE=wayland" 
   Environment="XDG_CURRENT_DESKTOP=GNOME" 

   [Install]
   WantedBy=graphical.target suspend.target
   ```

   - EXAMPLE (3)
   ```bash
   mkdir -p ~/.config/systemd/user/
   nano ~/.config/systemd/user/wake_monitors.service
   ```
   
   ```ini
   [Unit]
   Description=Wake monitor(s) after login
   After=graphical-session.target

   [Service]
   Type=oneshot
   ExecStartPre=/bin/sleep 5
   # ExecStart=/usr/bin/sudo -u $USER /usr/local/bin/wake_monitors.sh
   ExecStart=/usr/local/bin/wake_monitors.sh

   #Environment="DISPLAY=:0"
   #Environment="XDG_SESSION_TYPE=wayland"
   #Environment="XDG_CURRENT_DESKTOP=KDE" 

   [Install]
   WantedBy=default.target
   ```
   
3. **Enable and Start the Service**:
   

   ```bash
   sudo systemctl daemon-reload
   sudo systemctl enable wake_monitors.service
   sudo systemctl start wake_monitors.service
   systemctl --user status wake_monitors.service
   ```

# 
Technically, this systemd service file should run the script after logging in and after resuming from suspend.

Hope this helps!
