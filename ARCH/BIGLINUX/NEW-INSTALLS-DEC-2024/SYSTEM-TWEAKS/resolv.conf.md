# Google DNS server addition && update immediately

```bash

#!/bin/bash
# Tolga Erok
# 27/12/24

# DNS entries
DNS1="nameserver 8.8.8.8"
DNS2="nameserver 8.8.4.4"

# Temp file for deduplication
TEMP_FILE="/tmp/resolv.conf"

# Backup original resolv.conf
BACKUP_FILE="/etc/resolv.conf.bak"
sudo cp /etc/resolv.conf "$BACKUP_FILE"
echo "Backup created at $BACKUP_FILE"

# Add DNS entries if missing
sudo grep -q "$DNS1" /etc/resolv.conf || echo "$DNS1" | sudo tee -a /etc/resolv.conf > /dev/null
sudo grep -q "$DNS2" /etc/resolv.conf || echo "$DNS2" | sudo tee -a /etc/resolv.conf > /dev/null

# Remove duplicates
sudo awk '!seen[$0]++' /etc/resolv.conf > "$TEMP_FILE"

# Replace original resolv.conf with deduplicated content
sudo mv "$TEMP_FILE" /etc/resolv.conf

# check NetworkManager is running
echo "Ensuring NetworkManager is active..."
if ! nmcli general status | grep -q "running"; then
  echo "NetworkManager is not running. Starting NetworkManager..."
  sudo systemctl start NetworkManager
else
  echo "NetworkManager is already active."
fi

# Restart NetworkManager
echo "Restarting NetworkManager..."
sudo systemctl restart NetworkManager
sleep 5  

# Set DNS for the first active Wi-Fi connection
ACTIVE_CONNECTION=$(nmcli -t -f NAME,TYPE con show --active | grep -i 'wifi' | cut -d: -f1)

if [ -n "$ACTIVE_CONNECTION" ]; then
  echo "Setting DNS for active connection: $ACTIVE_CONNECTION"
  sudo nmcli con mod "$ACTIVE_CONNECTION" ipv4.dns "8.8.8.8 8.8.4.4"
  sudo nmcli con mod "$ACTIVE_CONNECTION" ipv4.ignore-auto-dns yes
  echo "DNS updated for $ACTIVE_CONNECTION."
else
  echo "No active Wi-Fi connection found to update DNS."
fi

# Final DNS settings check
echo "Final resolv.conf:"
cat /etc/resolv.conf
nmcli dev show | grep 'IP4.DNS'
dig @8.8.8.8 google.com
nslookup google.com



```

