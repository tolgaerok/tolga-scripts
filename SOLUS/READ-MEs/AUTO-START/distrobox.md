### create script in home directory
- this is for KDE

save in home directory as `start_megasync.sh`

```bash
#!/bin/bash
# export to the correct display session for KDE (X11/Wayland)
if [ "$XDG_SESSION_TYPE" = "wayland" ]; then
    export XDG_RUNTIME_DIR="/run/user/$(id -u)"
    export WAYLAND_DISPLAY="wayland-0"
else
    export DISPLAY=":0"
fi

# Launch MEGAsync inside distrobox (change to suit)
distrobox-enter --name f40 -- megasync &
```



### create autostart.desktop
- create in `~/.config/autostart/megasync.desktop`

```bash
[Desktop Entry]
Type=Application
Exec=/home/tolga/start_megasync.sh
Hidden=false
NoDisplay=false
X-KDE-Autostart-enabled=true
Name=MEGAsync
```

  



### make them executable

```bash
chmod +x ~/.config/autostart/megasync.desktop
chmod +x /home/tolga/start_megasync.sh
```
