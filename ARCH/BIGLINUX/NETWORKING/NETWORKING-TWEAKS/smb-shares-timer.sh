#!/bin/bash
# Tolga Erok
# 13/3/25
# Beta version: 3.0.1

# set -e  # Exit on error
export DBUS_SESSION_BUS_ADDRESS=unix:path=/run/dbus/system_bus_socket

LOG_FILE="/var/log/tolga-auto-ping-samba.log"
echo "Starting Samba Auto-Ping Script at $(date)" >>"$LOG_FILE"

echo "Creating Samba Auto-Ping Script by Tolga Erok..."

# Create the script
# ------------------------------------- #
cat <<'EOF' | sudo tee /usr/local/bin/tolga-auto-ping-samba.sh >/dev/null
#!/bin/bash
# Tolga Erok
# 13/3/25

LOG_FILE="/var/log/tolga-auto-ping-samba.log"
echo "Scanning shares started at $(date)" >> "$LOG_FILE"

# Start the timer
START_TIME=$(date +%s)

# List of my SMB shares on my QNAP
shares=(
    "//jack-sparrow.local/Public"
    "//jack-sparrow.local/MY-QNAP"
)

# Mount each QNAP share
for share in "${shares[@]}"; do
    share_name=$(basename "$share")
    mount_point="/mnt/$share_name" 

    # Log 
    MOUNT_START=$(date +%s)
    echo "Attempting to mount $share to $mount_point" >> "$LOG_FILE"

    # Check if share is already mounted
    if mount | grep "$mount_point" > /dev/null; then
        echo "$share is already mounted at $mount_point" >> "$LOG_FILE"
    else
        # Create a mount point if not present
        sudo mkdir -p "$mount_point"
        
        # mount the share
        sudo mount -t cifs "$share" "$mount_point" -o credentials=/etc/samba/credentials,vers=3.0
        
        if [ $? -eq 0 ]; then
            echo "Successfully mounted $share to $mount_point" >> "$LOG_FILE"
        else
            echo "Failed to mount $share to $mount_point" >> "$LOG_FILE"
        fi
    fi

    # Log end of mounting
    MOUNT_END=$(date +%s)
    MOUNT_TIME=$((MOUNT_END - MOUNT_START))
    echo "Mounting $share took $MOUNT_TIME seconds" >> "$LOG_FILE"
done

END_TIME=$(date +%s)
TIME_TAKEN=$((END_TIME - START_TIME))
TIME_FORMATTED=$(date -u -d @${TIME_TAKEN} +"%H:%M:%S")

# Log time taken for the entire scan/mnt
echo "Scan Complete: Shares scanned in $TIME_FORMATTED at $(date)." >> "$LOG_FILE"
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
