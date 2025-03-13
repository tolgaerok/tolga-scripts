#!/bin/bash
# tolga erok
# 13/3/25
# beta

# set -e  # Exit on error
export DBUS_SESSION_BUS_ADDRESS=unix:path=/run/dbus/system_bus_socket

LOG_FILE="/var/log/tolga-auto-ping-samba.log"
echo "Starting Samba Auto-Ping Script at $(date)" >>"$LOG_FILE"

echo "Creating Samba Auto-Ping Script by Tolga Erok..."

# Create the script
# ------------------------------------- #
cat <<'EOF' | sudo tee /usr/local/bin/tolga-auto-ping-samba.sh >/dev/null
#!/bin/bash

LOG_FILE="/var/log/tolga-auto-ping-samba.log"

echo "Scanning shares..." >> "$LOG_FILE"

# Start the timer
START_TIME=$(date +%s)

# discover and ping Samba shares using Avahi && find all devices advertising Samba services
SHARES=$(avahi-browse -rt _smb._tcp | awk -F';' '/^=/ {print $8}' | sort -u)

# Ping each host
for share in $SHARES; do
    ping -c 1 -W 1 "$share" > /dev/null 2>&1
    echo "Pinged: $share" >> "$LOG_FILE"  # Log each ping
done

END_TIME=$(date +%s)
TIME_TAKEN=$((END_TIME - START_TIME))

# scan is complete and show the time taken
echo "Scan Complete: Shares scanned in $TIME_TAKEN seconds at $(date)." >> "$LOG_FILE"
EOF

# Make the script executable
sudo chmod +x /usr/local/bin/tolga-auto-ping-samba.sh

echo "Creating Systemd Service..."

# Create the systemd service
# ------------------------------------- #
cat <<'EOF' | sudo tee /etc/systemd/system/tolga-auto-ping-samba.service >/dev/null
[Unit]
Description=Automatically Ping Samba Shares - Tolga Erok
After=network-online.target avahi-daemon.service
Wants=network-online.target avahi-daemon.service

[Service]
Environment=DISPLAY=:0
Type=oneshot
ExecStart=/usr/local/bin/tolga-auto-ping-samba.sh
RemainAfterExit=yes
StandardOutput=journal
StandardError=journal
EOF

echo "Creating Systemd Timer..."

# Create the timer
cat <<'EOF' | sudo tee /etc/systemd/system/tolga-auto-ping-samba.timer >/dev/null
[Unit]
Description=Scan and ping for Samba shares - Tolga Erok

[Timer]
OnBootSec=10s
OnUnitActiveSec=30s
Unit=tolga-auto-ping-samba.service

[Install]
WantedBy=timers.target
EOF

# Reload systemd and start services
echo "Reloading systemd and enabling the timer..."
sudo systemctl daemon-reload
sudo systemctl enable --now tolga-auto-ping-samba.timer
sudo systemctl start tolga-auto-ping-samba.timer

# Verification commands
echo "Checking status of the timer..."
sudo systemctl status tolga-auto-ping-samba.timer

echo "Checking logs for the timer..."
sudo journalctl -u tolga-auto-ping-samba.timer --no-pager | tail -n 20

echo "Checking logs for the service..."
sudo journalctl -u tolga-auto-ping-samba.service --no-pager | tail -n 20

echo "Setup complete! The script will now automatically scan and ping Samba shares."
