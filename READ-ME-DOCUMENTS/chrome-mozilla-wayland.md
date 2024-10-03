# Make chrome, mozzilla, Caprine and system perform better (user and system wide varibles) under Wayland && Nvidia
### Fedora 40 KDE
- User `./bashrc`

```bash
###---------- Nvidia session ----------###
export LIBVA_DRIVER_NAME=nvidia
export WLR_NO_HARDWARE_CURSORS=1
export __GLX_VENDOR_LIBRARY_NAME=nvidia
export __GL_SHADER_CACHE=1
export __GL_THREADED_OPTIMIZATION=1

export CHROME_ENABLE_WAYLAND=1
export CLUTTER_BACKEND=wayland
export MOZ_ENABLE_WAYLAND=1
export QT_QPA_PLATFORM=wayland
export XDG_SESSION_TYPE=wayland
```

- then `source ~/.bashrc`

#### Persistence
- Edit
  
```bash
sudo nano /etc/environment
```

- Add:

```bash
__GL_THREADED_OPTIMIZATION=1
__GL_SHADER_CACHE=1
__GLX_VENDOR_LIBRARY_NAME=nvidia
LIBVA_DRIVER_NAME=nvidia
WLR_NO_HARDWARE_CURSORS=1

CLUTTER_BACKEND=wayland
QT_QPA_PLATFORM=wayland
XDG_SESSION_TYPE=wayland
CHROME_ENABLE_WAYLAND=1
MOZ_ENABLE_WAYLAND=1


# KWIN_DRM_NO_AMS=1
# KWIN_FORCE_SW_CURSOR=1
```

### Launch Chrome with Wayland Support:

- Locate the `.desktop` file for Google Chrome. It's usually located in `/usr/share/applications/google-chrome.desktop` or `~/.local/share/applications/google-chrome.desktop`
- Look for the Exec= line and append the flags to the end of the line.

```bash
sudo nano /usr/share/applications/google-chrome.desktop
```

- It should look something like this:

```bash
Exec=/usr/bin/google-chrome-stable %U
```
- change to 
```bash
Exec=/usr/bin/google-chrome-stable --enable-features=UseOzonePlatform --ozone-platform=wayland %U
```

- Update Desktop Database:
  
```bash
sudo update-desktop-database
```

### Enable Experimental Wayland Support in Flatpak:
- Flatpak has experimental support for running applications on the Wayland display server. To enable this experimental support, you need to set an environment variable for Flatpak.

```bash
sudo flatpak override --env=QT_QPA_PLATFORM=wayland com.sindresorhus.caprine
```









