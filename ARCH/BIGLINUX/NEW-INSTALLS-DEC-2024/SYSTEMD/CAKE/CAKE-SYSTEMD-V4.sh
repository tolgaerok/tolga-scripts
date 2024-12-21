#!/usr/bin/env bash

# Author: Tolga Erok
# Date: 2024-10-19
# Description: Systemd script to force CAKE onto any active network interface.

# Colors (using tput for better compatibility)
YELLOW=$(tput setaf 3)
BLUE=$(tput setaf 4)
RED=$(tput setaf 1)
NC=$(tput sgr0)

# Detect active network interface (uplink or wireless) and trim leading/trailing spaces
INTERFACE=$(ip -o link show | awk '$6 == "UP" && $0 !~ /LO|NO-CARRIER/ {gsub(/^[ \t]+|[ \t]+$/, "", $2); print $2; exit}')

if [ -z "$INTERFACE" ]; then
  echo -e "${RED}No active network interface found. Exiting.${NC}"
  exit 1
fi

echo -e "${BLUE}Detected active network interface: ${INTERFACE}${NC}"

# Service configuration
SERVICE_NAME="apply-cake-qdisc.service"
SERVICE_FILE="/etc/systemd/system/${SERVICE_NAME}"

# Create systemd service file
echo -e "${BLUE}Creating systemd service file at ${SERVICE_FILE}...${NC}"
sudo tee "$SERVICE_FILE" > /dev/null <<EOF
[Unit]
Description=Apply CAKE qdisc to ${INTERFACE}
After=network-online.target
Wants=network-online.target

[Service]
Type=oneshot
ExecStart=/sbin/tc qdisc replace dev ${INTERFACE} root cake bandwidth 1Gbit
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
EOF

# Reload systemd daemon
echo -e "${BLUE}Reloading systemd daemon...${NC}"
sudo systemctl daemon-reload

# Start and enable the service
echo -e "${BLUE}Starting the service...${NC}"
sudo systemctl start "$SERVICE_NAME"
echo -e "${BLUE}Enabling the service to start at boot...${NC}"
sudo systemctl enable "$SERVICE_NAME"

# Verify qdisc configuration
echo -e "${BLUE}Verifying qdisc configuration for ${INTERFACE}:${NC}"
sudo tc qdisc show dev "$INTERFACE"

echo -e "${YELLOW}CAKE qdisc should be applied to ${INTERFACE} now.${NC}"

# Detailed qdisc status and service status
echo -e "${BLUE}Detailed qdisc status for ${INTERFACE}:${NC}"
sudo tc -s qdisc show dev "$INTERFACE"
echo
echo -e "${BLUE}Systemd service status:${NC}"
sudo systemctl status "$SERVICE_NAME"

# Add alias to .bashrc (using >> to append, not overwrite)
ALIAS="cake2='interface=\$(ip -o link show | awk \"\$6 == \"UP\" && \$0 !~ /LO|NO-CARRIER/ {gsub(/^[ \t]+|[ \t]+$/, \"\", \$2); print \$2; exit}\"); sudo systemctl daemon-reload && sudo systemctl restart apply-cake-qdisc.service && sudo tc -s qdisc show dev \$interface && sudo systemctl status apply-cake-qdisc.service'"
if ! grep -q "^${ALIAS%%=*}" ~/.bashrc; then
  echo -e "${BLUE}Adding alias 'cake2' to ~/.bashrc...${NC}"
  echo "$ALIAS" >> ~/.bashrc
  echo -e "${YELLOW}Alias 'cake2' added to ~/.bashrc. You can use it to quickly apply CAKE settings.${NC}"
fi
