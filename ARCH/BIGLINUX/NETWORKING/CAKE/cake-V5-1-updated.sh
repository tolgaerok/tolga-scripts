#!/usr/bin/env bash

# Metadata
# ----------------------------------------------------------------------------
# AUTHOR="Tolga Erok"
# VERSION="V5.1"
# DATE_CREATED="16/3/2025"
# Description: Systemd script to force CAKE onto any active network interface.

YELLOW="\033[1;33m"
BLUE="\033[0;34m"
RED="\033[0;31m"
NC="\033[0m"

# Detect pkg manager
if command -v dnf &>/dev/null; then
    PM="dnf"
    INSTALL_CMD="sudo dnf install -y"
    elif command -v pacman &>/dev/null; then
    PM="pacman"
    INSTALL_CMD="sudo pacman -Sy --needed"
else
    echo -e "${RED}Unsupported distribution. Exiting...${NC}"
    exit 1
fi

# Check that `tc` (iproute2) is installed
if ! command -v tc &>/dev/null; then
    echo -e "${YELLOW}tc command not found, installing iproute2/iproute-tc...${NC}"
    if [ "$PM" = "dnf" ]; then
        $INSTALL_CMD iproute-tc
        elif [ "$PM" = "pacman" ]; then
        $INSTALL_CMD iproute2
    fi
fi

# check for any active networking interface (uplink or wireless)
interface=$(ip link show | awk -F: '$0 ~ "^[2-9]:|^[1-9][0-9]: " && $0 ~ "UP" && $0 !~ "LOOPBACK|NO-CARRIER" {gsub(/^[ \t]+|[ \t]+$/, "", $2); print $2; exit}')

if [ -z "$interface" ]; then
    echo -e "${RED}No active network interface found. Exiting.${NC}"
    exit 1
fi

echo -e "${BLUE}Detected active network interface: ${interface}${NC}"

SERVICE_NAME="apply-cake-qdisc.service"
SERVICE_FILE="/etc/systemd/system/$SERVICE_NAME"
SERVICE_NAME2="apply-cake-qdisc-wake.service"
SERVICE_FILE2="/etc/systemd/system/$SERVICE_NAME2"

echo -e "${BLUE}Creating systemd service file at ${SERVICE_FILE}...${NC}"
sudo bash -c "cat > $SERVICE_FILE" <<EOF
[Unit]
Description=Tolga's V5.1 of applying CAKE qdisc to a dynamic network interface
After=network-online.target
Wants=network-online.target

[Service]
Type=oneshot
ExecStart=/bin/bash -c 'interface=\$(ip link show | awk -F: '\''\$0 ~ \"wlp|wlo|wlx\" && \$0 !~ \"NO-CARRIER\" {gsub(/^[ \t]+|[ \t]+$/, \"\", \$2); print \$2; exit}'\''); if [ -n \"\$interface\" ]; then sudo tc qdisc replace dev \$interface root cake bandwidth 1Gbit; fi'
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
EOF

echo -e "${BLUE}Creating systemd service file at ${SERVICE_FILE2}...${NC}"
sudo bash -c "cat > $SERVICE_FILE2" <<EOF
[Unit]
Description=Re-apply Tolga's V5.1 CAKE qdisc when network is reinitialized (suspend/wake)
After=suspend.target

[Service]
Type=oneshot
ExecStart=/bin/bash -c 'interface=\$(ip link show | awk -F: '\''\$0 ~ \"wlp|wlo|wlx\" && \$0 !~ \"NO-CARRIER\" {gsub(/^[ \t]+|[ \t]+$/, \"\", \$2); print \$2; exit}'\''); if [ -n \"\$interface\" ]; then sudo tc qdisc replace dev \$interface root cake bandwidth 1Gbit; fi'

[Install]
WantedBy=suspend.target
EOF

echo -e "${BLUE}Reloading systemd daemon...${NC}"
sudo systemctl daemon-reload

echo -e "${BLUE}Starting the service...${NC}"
sudo systemctl start $SERVICE_NAME

echo -e "${BLUE}Enabling the service to start at boot...${NC}"
sudo systemctl enable $SERVICE_NAME

echo -e "${BLUE}Verifying qdisc configuration for ${interface}:${NC}"
sudo tc qdisc show dev "$interface"

echo -e "${YELLOW}CAKE qdisc should be applied to ${interface} now.${NC}"

# display qdisc status for the interface
sudo tc -s qdisc show dev "$interface"

# Check status of the systemd service
sudo systemctl status apply-cake-qdisc.service --no-pager

# Add alias to .bashrc for easier access
echo "alias cake2='interface=\$(ip link show | awk -F: '\''\$0 ~ \"wlp|wlo|wlx\" && \$0 !~ \"NO-CARRIER\" {gsub(/^[ \t]+|[ \t]+$/, \"\", \$2); print \$2; exit}'\''); sudo systemctl daemon-reload && sudo systemctl restart apply-cake-qdisc.service && sudo tc -s qdisc show dev \$interface && sudo systemctl status apply-cake-qdisc.service --no-pager && sudo systemctl status apply-cake-qdisc-wake.service --no-pager'" >>~/.bashrc

echo -e "${YELLOW}Alias 'cake2' added to .bashrc. You can use it to quickly apply CAKE settings.${NC}"

# Reload ALL systemd daemon and enable Tolga's V5.1 CAKE services
sudo systemctl daemon-reload
sudo systemctl start apply-cake-qdisc.service
sudo systemctl start apply-cake-qdisc-wake.service
sudo systemctl enable apply-cake-qdisc.service
sudo systemctl enable apply-cake-qdisc-wake.service

# Check the status of Tolga's V5.1 systemd CAKE services
sudo systemctl status apply-cake-qdisc.service --no-pager
sudo systemctl status apply-cake-qdisc-wake.service --no-pager
