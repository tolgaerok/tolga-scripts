## Personal Earlyloom service to kick in at 15% of RAM usage

* Tolga Erok
* 25-2-24

1. **Create or edit the service file:**

   Open a terminal and run the following command to create/edit the service file:

   ```bash
   sudo nano /etc/systemd/system/earlyoom.service
   ```

2. **Add the following configuration to the file:**

   ```plaintext
   [Unit]
   Description=Early OOM Daemon
   Documentation=man:earlyoom(1)
   ConditionPathExists=/proc/sys/vm/overcommit_memory

   [Service]
   Environment=EARLYOOM_ARGS="-r 0 -m 15 -M 1000000 --prefer '^(Web Content|Isolated Web Co)$' --avoid '^(dnf|packagekitd|gnome-shell|gnome-session-c|gnome-session-b|lightdm|sddm|sddm-helper|gdm|gdm-wayland-ses|gdm-session-wor|gdm-x-session|Xorg|Xwayland|systemd|systemd-logind|dbus-daemon|dbus-broker|cinnamon|cinnamon-sessio|kwin_x11|kwin_wayland|plasmashell|ksmserver|plasma_session|startplasma-way|xfce4-session|mate-session|marco|lxqt-session|openbox|cryptsetup)$'"

   ExecStart=/usr/bin/earlyoom $EARLYOOM_ARGS
   Restart=on-failure
   RestartSec=5s

   [Install]
   WantedBy=multi-user.target
   ```

3. **Save and close the file:**

   

4. **Reload systemd to apply changes:**

   Run the following command to reload systemd:

   ```bash
   sudo systemctl daemon-reload
   ```

5. **Enable the service to start at boot:**

   Run the following command to enable the service:

   ```bash
   sudo systemctl enable earlyoom.service
   ```

6. **Start the service immediately:**

   Run the following command to start the service:

   ```bash
   sudo systemctl start earlyoom.service
   ```

7. **Verify the service status:**

   You can check the status of the service to ensure it's running correctly:

   ```bash
   sudo systemctl status earlyoom.service
   ```

## Additional instructions to edit the EarlyOOM configuration file located in 

`/etc/default/earlyoom`:

1. **Open the EarlyOOM configuration file for editing:**

   Run the following command in the terminal to open the configuration file:

   ```bash
   sudo nano /etc/default/earlyoom
   ```

2. **Adjust the memory limit:**

   Find the line that sets the memory limit (`-m` option) and change it to your desired value. For example, to set it to 15%, modify the line to:

   ```plaintext
   EARLYOOM_ARGS="-r 0 -m 15 -M 1000000 --prefer '^(Web Content|Isolated Web Co)$' --avoid '^(dnf|packagekitd|gnome-shell|gnome-session-c|gnome-session-b|lightdm|sddm|sddm-helper|gdm|gdm-wayland-ses|gdm-session-wor|gdm-x-session|Xorg|Xwayland|systemd|systemd-logind|dbus-daemon|dbus-broker|cinnamon|cinnamon-sessio|kwin_x11|kwin_wayland|plasmashell|ksmserver|plasma_session|startplasma-way|xfce4-session|mate-session|marco|lxqt-session|openbox|cryptsetup)$'"
   ```

3. **Save and close the file and restart service:**

   ```bash
   sudo systemctl enable --now earlyoom
   sudo systemctl daemon-reload 
   sudo systemctl stop earlyoom.service && sudo systemctl start earlyoom.service && sudo systemctl restart earlyoom.service && sudo systemctl enable earlyoom.service && sudo systemctl status earlyoom.service
   sudo systemctl enable earlyoom.service   # Enable the service to start at boot
   sudo systemctl start earlyoom.service    # Start the service immediately
   ```

That's it! The EarlyOOM configuration file has been edited to adjust the memory limit. Make sure the value matches the one you've set in the systemd service file.

The Early OOM Daemon service should now be configured, enabled to start at boot, and running on your system.
