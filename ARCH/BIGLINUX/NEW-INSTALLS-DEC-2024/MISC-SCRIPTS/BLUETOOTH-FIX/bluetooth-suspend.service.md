
# Pre-Suspend Service

- Create /etc/systemd/system/disable-bluetooth-before-sleep.service

```bash
[Unit]
Description=Disable Bluetooth before suspend - TOLGA EROK
Before=sleep.target

[Service]
Type=oneshot
ExecStart=/usr/bin/rfkill block bluetooth

[Install]
WantedBy=sleep.target
```

# Post-Resume Service

    Create /etc/systemd/system/enable-bluetooth-after-resume.service

```bash
[Unit]
Description=Enable Bluetooth after resume - TOLGA EROK
After=suspend.target

[Service]
Type=oneshot
ExecStartPre=/bin/sleep 5
ExecStart=/usr/sbin/rfkill unblock bluetooth

[Install]
WantedBy=suspend.target
```

## Enable the Services

Run the following commands:

    sudo systemctl enable disable-bluetooth-before-sleep.service
    sudo systemctl enable enable-bluetooth-after-resume.service
    sudo systemctl start disable-bluetooth-before-sleep.service
    sudo systemctl start enable-bluetooth-after-resume.service
    sudo systemctl daemon-reload

## Test Suspend and Resume

After enabling the services, suspend your system and resume it. Verify the status of Bluetooth with:

    rfkill list bluetooth

## Verify Logs

Inspect the logs for each service to ensure they are triggered appropriately:

    journalctl -u disable-bluetooth-before-sleep.service --no-pager
    journalctl -u enable-bluetooth-after-resume.service --no-pager

## Verify status

    sudo systemctl status disable-bluetooth-before-sleep.service --no-pager
    sudo systemctl status enable-bluetooth-after-resume.service --no-pager
















[Unit]
Description=Disable Bluetooth before going to sleep
Before=suspend.target hibernate.target hybrid-sleep.target suspend-then-hibernate.target
StopWhenUnneeded=yes

[Service]
Type=oneshot
RemainAfterExit=yes

ExecStart=/usr/bin/rfkill block bluetooth
ExecStop=/usr/bin/rfkill unblock bluetooth

[Install]
WantedBy=suspend.target hibernate.target hybrid-sleep.target suspend-then-hibernate.target

# sudo nano /etc/systemd/system/disable-bluetooth-before-sleep.service