#!/bin/bash
# tolga erok

# curl -sL https://raw.githubusercontent.com/tolgaerok/solus/main/PERSONAL-SCRIPTS/IO-SCHEDULER/io-scheduler.sh | sudo bash

# Create the systemd service file for setting the I/O scheduler
echo "[Unit]
Description=Set I/O Scheduler on boot for SSD / NVME

[Service]
Type=simple
ExecStart=/bin/bash -c 'echo none | sudo tee /sys/block/sda/queue/scheduler; printf \"I/O Scheduler set to: \"; cat /sys/block/sda/queue/scheduler'

[Install]
WantedBy=default.target" | sudo tee /etc/systemd/system/io-scheduler.service

# Reload systemd, enable, and start the service
sudo systemctl daemon-reload
sudo systemctl enable io-scheduler.service
sudo systemctl start io-scheduler.service
sudo systemctl status io-scheduler.service