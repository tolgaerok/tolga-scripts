#!/bin/bash
# tolga erok
# 13/3/25
# beta

set -e # Exit on error

echo "🔴 Stopping and disabling the Tolga's Samba auto-ping timer and service..."

# Stop systemd timer and service
sudo systemctl stop tolga-auto-ping-samba.timer
sudo systemctl disable tolga-auto-ping-samba.timer
sudo systemctl stop tolga-auto-ping-samba.service
sudo systemctl disable tolga-auto-ping-samba.service

# Remove the systemd service and timer files
echo "🗑 Removing systemd files..."
sudo rm -f /etc/systemd/system/tolga-auto-ping-samba.timer
sudo rm -f /etc/systemd/system/tolga-auto-ping-samba.service

# Remove the My Samba auto-ping script
echo "🗑 Removing the Samba auto-ping script..."
sudo rm -f /usr/local/bin/tolga-auto-ping-samba.sh

# Reload systemd to apply changes
echo "🔄 Reloading systemd..."
sudo systemctl daemon-reload
sudo systemctl reset-failed

echo "📜 Checking for remaining logs..."
sudo journalctl --vacuum-time=1s
sudo journalctl --rotate
sudo journalctl --flush
sudo journalctl --vacuum-size=1M
sudo journalctl --vacuum-files=1

# Double check removal
echo "✅ Checking removal..."
if systemctl list-timers --all | grep -q "tolga-auto-ping-samba.timer"; then
    echo "❌ Timer is still present. Something went wrong dick whacker."
else
    echo "✅ Timer successfully removed."
fi

if systemctl list-units --all | grep -q "tolga-auto-ping-samba.service"; then
    echo "❌ Service is still present. Something went wrong dick-whacker."
else
    echo "✅ Service successfully removed."
fi

echo "🎉 Tolga's Samba auto-ping setup has been completely removed."
