### Tolga Erok
    - network tweaks v5
    - 23/12/2024


## Create service
    sudo nano /etc/systemd/system/apply-cake-qdisc.service


# Configuration for DYNAMIC CAKE systemd service

```bash
[Unit]
Description=Tolga's V2 of applying CAKE qdisc to a dynamic network interface - Version 2
After=network-online.target
Wants=network-online.target

[Service]
Type=oneshot
ExecStart=/bin/bash -c 'interface=$(ip link show | awk -F: '\''$0 ~ "wlp|wlo|wlx" && $0 !~ "NO-CARRIER" {gsub(/^[ \t]+|[ \t]+$/, "", $2); print $2; exit}'\''); if [ -n "$interface" ]; then sudo tc qdisc replace dev $interface root cake bandwidth 1Gbit; fi'
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
```

# Enable and start service  
    sudo systemctl daemon-reload
    sudo systemctl start apply-cake-qdisc.service
    sudo systemctl enable apply-cake-qdisc.service
    sudo systemctl status apply-cake-qdisc.service --no-pager

# Original
```bash
[Unit]
Description=KingTolga says: Apply CAKE qdisc to wlp4s0 - Version 1
After=network-online.target
Wants=network-online.target

[Service]
Type=oneshot
ExecStart=/sbin/tc qdisc replace dev wlp4s0 root cake bandwidth 1Gbit
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
```