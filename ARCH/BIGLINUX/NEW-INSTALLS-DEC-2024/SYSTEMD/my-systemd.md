![alt text](image-2.png)

![alt text](image-1.png)

![alt text](image-3.png)

> - alias my-systemd="$HOME/my-systemd.sh"

``` js
#!/bin/bash
# Create the systemd restart script and alias it in .bashrc

# Define the script file path
script_file="$HOME/my-systemd.sh"

# Create the script with the necessary content
cat <<'EOF' > "$script_file"
#!/bin/bash
# tolga erok
# 30/12/24

# Script to restart my custom systemd services and show their status
clear

# Check systemd service status without pager and restart
echo -e "Restarting systemd services...\n"
sudo systemctl daemon-reload

# Restart flatpak-update.service and then check status
echo -e "\nRestarting flatpak-update.service..."
sudo systemctl restart flatpak-update.service || echo "Failed to restart flatpak-update.service"
echo -e "Status of flatpak-update.service:"
systemctl status flatpak-update.service --no-pager || echo "flatpak-update.service not found or failed"

# Restart flatpak-update.timer and then check status
echo -e "\nRestarting flatpak-update.timer..."
sudo systemctl restart flatpak-update.timer || echo "Failed to restart flatpak-update.timer"
echo -e "Status of flatpak-update.timer:"
systemctl status flatpak-update.timer --no-pager || echo "flatpak-update.timer not found or failed"

# Restart systemd-resolved service and check its status
echo -e "\nRestarting systemd-resolved service..."
sudo systemctl restart systemd-resolved || echo "Failed to restart systemd-resolved"
echo -e "\nStatus of systemd-resolved:"
systemd-resolve --status || echo "systemd-resolved status failed"

# Restart Samba and related services, then check their status
echo -e "\nRestarting samba services..."
sudo systemctl restart smb.service || echo "Failed to restart smb.service"
echo -e "Status of smb.service:"
systemctl status smb.service --no-pager || echo "smb.service not found or failed"

sudo systemctl restart nmb.service || echo "Failed to restart nmb.service"
echo -e "Status of nmb.service:"
systemctl status nmb.service --no-pager || echo "nmb.service not found or failed"

sudo systemctl restart wsdd.service || echo "Failed to restart wsdd.service"
echo -e "Status of wsdd.service:"
systemctl status wsdd.service --no-pager || echo "wsdd.service not found or failed"

sleep 5

# Restart clear_temp_slowdowns_after_sleep.service and check its status
echo -e "\nRestarting clear_temp_slowdowns_after_sleep.service..."
sudo systemctl restart clear_temp_slowdowns_after_sleep.service || echo "Failed to restart clear_temp_slowdowns_after_sleep.service"
echo -e "Status of clear_temp_slowdowns_after_sleep.service:"
sudo systemctl status clear_temp_slowdowns_after_sleep.service --no-pager || echo "clear_temp_slowdowns_after_sleep.service not found"

# Restart clear_temp_slowdowns_at_boot.service and check its status
echo -e "\nRestarting clear_temp_slowdowns_at_boot.service..."
sudo systemctl restart clear_temp_slowdowns_at_boot.service || echo "Failed to restart clear_temp_slowdowns_at_boot.service"
echo -e "Status of clear_temp_slowdowns_at_boot.service:"
sudo systemctl status clear_temp_slowdowns_at_boot.service --no-pager || echo "clear_temp_slowdowns_at_boot.service not found"

# Cron jobs
echo -e "\nCron jobs:"
crontab -l || echo "No cron jobs found."

# Restart apply-cake-qdisc-wake.service and check its status
echo -e "\nRestarting apply-cake-qdisc-wake.service..."
sudo systemctl restart apply-cake-qdisc-wake.service || echo "Failed to restart apply-cake-qdisc-wake.service"
echo -e "Status of apply-cake-qdisc-wake.service:"
sudo systemctl status apply-cake-qdisc-wake.service --no-pager || echo "apply-cake-qdisc-wake.service not found"

# Restart disable-bluetooth-before-sleep.service and check its status
echo -e "\nRestarting disable-bluetooth-before-sleep.service..."
sudo systemctl restart disable-bluetooth-before-sleep.service || echo "Failed to restart disable-bluetooth-before-sleep.service"
echo -e "Status of disable-bluetooth-before-sleep.service:"
sudo systemctl status disable-bluetooth-before-sleep.service --no-pager || echo "disable-bluetooth-before-sleep.service not found"

# Restart enable-bluetooth-after-resume.service and check its status
echo -e "\nRestarting enable-bluetooth-after-resume.service..."
sudo systemctl restart enable-bluetooth-after-resume.service || echo "Failed to restart enable-bluetooth-after-resume.service"
echo -e "Status of enable-bluetooth-after-resume.service:"
sudo systemctl status enable-bluetooth-after-resume.service --no-pager || echo "enable-bluetooth-after-resume.service not found"

echo -e "\nSystem status checks and restarts completed."
EOF

# Make the script executable
chmod +x "$script_file"

# Add alias to .bashrc if not already present
echo -e "\nAdding alias to .bashrc..."
if ! grep -q "my-systemd" "$HOME/.bashrc"; then
    echo "alias my-systemd='$HOME/my-systemd.sh'" >> "$HOME/.bashrc"
    echo "Alias 'my-systemd' added to .bashrc."
else
    echo "Alias 'my-systemd' already exists in .bashrc."
fi

echo -e "\nSetup complete. You can now use 'my-systemd' to run the script."


```

![alt text](image.png)