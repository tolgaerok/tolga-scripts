# My personal systemd flatpak updater

* Tolga Erok
* 24-2-24

Overall, this systemd unit configuration defines a timer unit responsible for updating Flatpaks on the system. It specifies that the timer should trigger every 4 minutes, persists across system reboots, and is activated when the timers.target is reached during system startup or operation.

## Create flatpak-update.service

location:

```bash
sudo nano /etc/systemd/system/flatpak-update.service
```

```bash
[Unit]
Description=Update Flatpaks
[Service]
Type=oneshot
ExecStart=/usr/bin/flatpak update -y
[Install]
WantedBy=default.target
```

### Create flatpak-update.timer

location:

```bash
sudo nano /etc/systemd/system/flatpak-update.timer
```

```bash
[Unit]
Description=Update Flatpaks
[Timer]
OnCalendar=*:0/4
Persistent=true
[Install]
WantedBy=timers.target
```

### Enable and start services

```bash
systemctl enable flatpak-update.service && systemctl enable flatpak-update.timer
systemctl start flatpak-update.service && systemctl start flatpak-update.timer
systemctl status flatpak-update.service
systemctl status flatpak-update.timer
```
