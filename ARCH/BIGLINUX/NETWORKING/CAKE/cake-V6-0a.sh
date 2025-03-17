#!/usr/bin/env bash

# Metadata
# ----------------------------------------------------------------------------
# AUTHOR="Tolga Erok"
# VERSION="V6.0a"
# DATE_CREATED="17/3/2025"
# Description: Systemd script to force CAKE onto any active network interface.

YELLOW="\033[1;33m"
BLUE="\033[0;34m"
RED="\033[0;31m"
NC="\033[0m"

# Detect package manager
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

# Check and install `tc` (iproute package for either manjaro or fedora)
if ! command -v tc &>/dev/null; then
    echo -e "${YELLOW}tc command not found, installing iproute...${NC}"
    if [ "$PM" = "dnf" ]; then
        sudo dnf install -y iproute
    else
        sudo pacman -Sy --needed iproute2
    fi
    hash -r
fi

# Detect active network interface (wired or wireless, non-loopback)
interface=$(ip -o link show | awk -F': ' '
    $2 ~ /wlp|wlo|wlx|eth|eno/ && /UP/ && !/NO-CARRIER/ {print $2; exit}')

if [ -z "$interface" ]; then
    echo -e "${RED}No active network interface found. Exiting.${NC}"
    exit 1
fi

echo -e "${BLUE}Detected active network interface: ${interface}${NC}"

# Systemd service names
SERVICE_NAME="tolga-apply-cake-qdisc.service"
SERVICE_FILE="/etc/systemd/system/$SERVICE_NAME"
SERVICE_NAME2="tolga-apply-cake-qdisc-wake.service"
SERVICE_FILE2="/etc/systemd/system/$SERVICE_NAME2"

# Create systemd service for CAKE after boot
echo -e "${BLUE}Creating systemd service file at ${SERVICE_FILE}...${NC}"
sudo bash -c "cat > $SERVICE_FILE" <<EOF
[Unit]
Description=Tolga's V6.0a CAKE qdisc for $interface at boot
After=network-online.target
Wants=network-online.target

[Service]
Type=oneshot
ExecStart=/bin/bash -c "interface=\$(ip link show | awk -F': ' '/wlp|wlo|wlx|eth|eno/ && /UP/ && !/NO-CARRIER/ {print \$2; exit}'); if [ -n \"\$interface\" ]; then sudo tc qdisc replace dev \"\$interface\" root cake bandwidth 1Gbit diffserv4 triple-isolate nonat nowash ack-filter split-gso rtt 10ms raw overhead 18; fi"
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
EOF

# Create systemd service for suspend/wake
echo -e "${BLUE}Creating systemd service file at ${SERVICE_FILE2}...${NC}"
sudo bash -c "cat > $SERVICE_FILE2" <<EOF
[Unit]
Description=Re-apply Tolga's V6.0a CAKE qdisc to $interface after suspend/wake
After=suspend.target

[Service]
Type=oneshot
ExecStart=/bin/bash -c "interface=\$(ip link show | awk -F': ' '/wlp|wlo|wlx|eth|eno/ && /UP/ && !/NO-CARRIER/ {print \$2; exit}'); if [ -n \"\$interface\" ]; then sudo tc qdisc replace dev \"\$interface\" root cake bandwidth 1Gbit diffserv4 triple-isolate nonat nowash ack-filter split-gso rtt 10ms raw overhead 18; fi"

[Install]
WantedBy=suspend.target
EOF

# Reload systemd and enable services
echo -e "${BLUE}Reloading systemd daemon and enabling services...${NC}"
sudo systemctl daemon-reload
sudo systemctl enable tolga-apply-cake-qdisc.service
sudo systemctl start tolga-apply-cake-qdisc.service
sudo systemctl enable tolga-apply-cake-qdisc-wake.service
sudo systemctl start tolga-apply-cake-qdisc-wake.service

echo -e "${BLUE}Verifying qdisc configuration for ${interface}:${NC}"
sudo tc qdisc show dev "$interface"
echo -e "${YELLOW}CAKE qdisc should be applied to ${interface} now.${NC}"
sudo tc -s qdisc show dev "$interface"

# systemd service statuses
sudo systemctl status tolga-apply-cake-qdisc.service --no-pager
sudo systemctl status tolga-apply-cake-qdisc-wake.service --no-pager

# Add to .bashrc for quick CAKE
set +H
echo -e "\n# Apply CAKE qdisc easily - Tolga Erok\nfunction cake() {" >>$HOME/.bashrc
echo "  interface=\$(ip link show | awk -F': ' '/wlp|wlo|wlx|eth|eno/ && /UP/ && !/NO-CARRIER/ {print \$2; exit}')" >>$HOME/.bashrc
echo "  sudo systemctl daemon-reload" >>$HOME/.bashrc
echo "  sudo systemctl restart tolga-apply-cake-qdisc.service" >>$HOME/.bashrc
echo "  sudo tc -s qdisc show dev \$interface" >>$HOME/.bashrc
echo "  sudo systemctl status tolga-apply-cake-qdisc.service --no-pager" >>$HOME/.bashrc
echo "  sudo systemctl status tolga-apply-cake-qdisc-wake.service --no-pager" >>$HOME/.bashrc
echo "}" >>$HOME/.bashrc

echo 'alias cake-status="sudo systemctl status tolga-apply-cake-qdisc.service --no-pager && sudo systemctl status tolga-apply-cake-qdisc-wake.service --no-pager"' >>~/.bashrc

echo -e "${YELLOW}Function 'cake' and 'cake-status' added to .bashrc. Restart your shell or run 'source ~/.bashrc' to use it.${NC}"
source ~/.bashrc
