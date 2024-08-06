# Wake monitors after suspend fix
### Tolga Erok
### 6 Aug 2024

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

   # Set the displays with the correct configuration
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
     # X11
     xrandr --output HDMI-0 --auto --primary
     xrandr --output DP-0 --auto --right-of HDMI-0
   
   elif [ "$XDG_SESSION_TYPE" = "wayland" ]; then
     if [ "$XDG_CURRENT_DESKTOP" = "GNOME" ]; then
       # GNOME on Wayland
       gsettings set org.gnome.desktop.interface enable-animations false
       sleep 0.5
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
  
   Make the script executable:

   ```bash
   sudo chmod +x /usr/local/bin/wake_monitors.sh
   ```

2. **Create the systemd service file**:  `sudo nano /etc/systemd/system/wake_monitors.service` 
- Change `User` to suite: `User=tolga`
   
   ### SYSTEMD service

   ```ini
   [Unit]
   Description=Wake monitors after login or resume
   After=graphical.target suspend.target

   [Service]
   Type=oneshot
   ExecStart=/usr/local/bin/wake_monitors.sh
   User=tolga
   Environment=DISPLAY=:0

   [Install]
   WantedBy=graphical.target suspend.target
   ```

3. **Enable and Start the Service**:
   

   ```bash
   sudo systemctl daemon-reload
   sudo systemctl enable wake_monitors.service
   sudo systemctl start wake_monitors.service
   ```

# 
Technically, this systemd service file should run the script after logging in and after resuming from suspend.

Hope this helps!
