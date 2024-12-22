    sudo nano /etc/systemd/system/apply-cake-qdisc.service
    sudo systemctl daemon-reload
    sudo systemctl start apply-cake-qdisc.service
    sudo systemctl enable apply-cake-qdisc.service
    sudo systemctl status apply-cake-qdisc.service --no-pager

#

[Unit]
Description=Apply CAKE Qdisc
After=network.target

[Service]
Type=oneshot
ExecStart=/bin/bash -c "interface=\$(ip link show | awk -F: '\$0 ~ \"wlp|wlo|wlx\" && \$0 !~ \"NO-CARRIER\" {gsub(/^[ \\t]+|[ \\t]+$/, \"\", \$2); print \$2; exit}'); \
    tc qdisc add dev \$interface root cake; \
    tc -s qdisc show dev \$interface"
ExecReload=/bin/bash -c "interface=\$(ip link show | awk -F: '\$0 ~ \"wlp|wlo|wlx\" && \$0 !~ \"NO-CARRIER\" {gsub(/^[ \\t]+|[ \\t]+$/, \"\", \$2); print \$2; exit}'); \
    tc qdisc replace dev \$interface root cake; \
    tc -s qdisc show dev \$interface"
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
