# My personal systemd flatpak updater 

* Tolga Erok
* 24-2-24

### Create flatpak-update.service

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
