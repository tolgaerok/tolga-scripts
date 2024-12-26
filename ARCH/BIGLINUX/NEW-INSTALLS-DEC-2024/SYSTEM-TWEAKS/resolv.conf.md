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

# Restart NetworkManager
sudo systemctl restart NetworkManager

echo "DNS updated and NetworkManager restarted."

```

