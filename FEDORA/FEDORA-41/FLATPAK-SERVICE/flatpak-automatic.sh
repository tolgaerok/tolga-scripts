#!/bin/bash
# Author: Tolga Erok
# Date: 18/2/2025

# Define service and timer file paths
SERVICE_FILE="/etc/systemd/system/flatpak-update.service"
TIMER_FILE="/etc/systemd/system/flatpak-update.timer"

# Ensure the script is run as root
if [ "$EUID" -ne 0 ]; then
    echo "Please run as root: sudo $0"
    exit 1
fi

# Ensure flatpak is installed
if ! command -v flatpak &>/dev/null; then
    echo "Error: Flatpak is not installed."
    exit 1
fi

# Create the systemd service file
echo "[Unit]
Description=Tolgas Flatpak Automatic Update
Documentation=man:flatpak(1)
Wants=network-online.target
After=network-online.target

[Service]
Type=oneshot
ExecStart=/usr/bin/flatpak update -y

[Install]
WantedBy=multi-user.target" | tee "$SERVICE_FILE" >/dev/null

# Create the systemd timer file
echo "[Unit]
Description=Tolgas Flatpak Automatic Update Trigger
Documentation=man:flatpak(1)

[Timer]
# Check every 6HRS
OnBootSec=5m
OnCalendar=0/6:00:00
Persistent=true

[Install]
WantedBy=timers.target" | tee "$TIMER_FILE" >/dev/null

# Reload systemd to recognize the new service and timer
systemctl daemon-reload

# Enable and start the service
systemctl enable --now flatpak-update.service

# Enable and start the timer
systemctl enable --now flatpak-update.timer

# Show the status of both with no pager
echo -e "\nFlatpak update service status:"
systemctl status flatpak-update.service --no-pager

echo -e "\nFlatpak update timer status:"
systemctl status flatpak-update.timer --no-pager

echo -e "\nNext scheduled Flatpak update:"
systemctl list-timers --no-pager | grep flatpak-update
