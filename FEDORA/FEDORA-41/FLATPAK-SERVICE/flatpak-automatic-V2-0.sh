#!/bin/bash
# Author: Tolga Erok
# Date:   16/3/2025
# Version: 2.0

# Configs
SERVICE_FILE="/etc/systemd/system/flatpak-update.service"
TIMER_FILE="/etc/systemd/system/flatpak-update.timer"

# Check if the script is run as root
if [ "$EUID" -ne 0 ]; then
    echo "Please run as root: sudo $0"
    exit 1
fi

# Check if flatpak is installed
if ! command -v flatpak &>/dev/null; then
    echo "Error: Flatpak is not installed."
    exit 1
fi

# systemd service file
echo "[Unit]
Description=Tolga's Flatpak Automatic Update V2.0
Documentation=man:flatpak(1)
Wants=network-online.target
After=network-online.target

[Service]
Type=oneshot
ExecStart=/usr/bin/flatpak update -y

[Install]
WantedBy=multi-user.target" | tee "$SERVICE_FILE" >/dev/null

# systemd timer file
echo "[Unit]
Description=Tolga's Flatpak Automatic Update Trigger V2.0
Documentation=man:flatpak(1)

[Timer]
OnBootSec=15s
OnCalendar=*-*-* 00/6:00:00
Persistent=true

[Install]
WantedBy=timers.target" | tee "$TIMER_FILE" >/dev/null

# Reload systemd
systemctl daemon-reload
systemctl enable --now flatpak-update.timer

# status of both with no pager!
echo -e "\nFlatpak update service status:"
systemctl status flatpak-update.service --no-pager

echo -e "\nFlatpak update timer status:"
systemctl status flatpak-update.timer --no-pager

echo -e "\nNext scheduled Flatpak update:"
systemctl list-timers --no-pager | grep flatpak-update
