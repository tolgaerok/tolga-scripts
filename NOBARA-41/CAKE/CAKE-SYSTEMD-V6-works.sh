#!/usr/bin/env bash
# Metadata
# ---------------------------------------------------------------------------
# AUTHOR="Tolga Erok"
# VERSION="6.2"
# DATE_CREATED="06/01/2025"
# DATE_MODIFIED="10/01/2025"

# Variables
YELLOW="\033[1;33m"
BLUE="\033[0;34m"
RED="\033[0;31m"
NC="\033[0m"

# Detect any active network interface (uplink or wireless) and trim leading/trailing spaces
interface=$(ip link show | awk -F: '$0 ~ "^[2-9]:|^[1-9][0-9]: " && $0 ~ "UP" && $0 !~ "LOOPBACK|NO-CARRIER" {gsub(/^[ \t]+|[ \t]+$/, "", $2); print $2; exit}')

if [ -z "$interface" ]; then
    echo -e "${RED}No active network interface found. Exiting.${NC}"
    exit 1
fi

echo -e "${BLUE}Detected active network interface: ${interface}${NC}"

# Variables for CAKE Qdisc settings and service files
BANDWIDTH="1Gbit"
SERVICE_NAME="apply-cake-qdisc.service"
SERVICE_NAME2="apply-cake-qdisc-wake.service"
SERVICE_FILE="/etc/systemd/system/$SERVICE_NAME"
SERVICE_FILE2="/etc/systemd/system/$SERVICE_NAME2"

# Apply CAKE Qdisc settings to the active interface
apply_cake_qdisc() {
    echo "Applying CAKE Qdisc to $interface..."
    sudo tc qdisc replace dev "$interface" root cake bandwidth "$BANDWIDTH" diffserv4 triple-isolate nonat nowash ack-filter split-gso rtt 10ms raw overhead 18
    echo "CAKE Qdisc applied to $interface."
}

# Create systemd service file to apply CAKE settings on boot
create_service_file() {
    echo "Creating systemd service file at $SERVICE_FILE..."
    sudo tee "$SERVICE_FILE" >/dev/null <<EOF
[Unit]
Description=Apply CAKE Qdisc to $interface at boot - TOLGA EROK VERSION 6.2
After=network.target

[Service]
Type=oneshot
ExecStart=/bin/bash -c 'interface=\$(ip link show | awk -F: '\''\$0 ~ "wlp|wlo|wlx" && \$0 !~ "NO-CARRIER" {gsub(/^[ \t]+|[ \t]+$/, "", \$2); print \$2; exit}'\''); if [ -n "\$interface" ]; then sudo tc qdisc replace dev "\$interface" root cake bandwidth 1Gbit diffserv4 triple-isolate nonat nowash ack-filter split-gso rtt 10ms raw overhead 18; fi'
RemainAfterExit=true

[Install]
WantedBy=multi-user.target
EOF
}

# Create systemd wake service file to reapply CAKE settings after suspend/wake
create_wake_service_file() {
    echo "Creating systemd wake service file at $SERVICE_FILE2..."
    sudo tee "$SERVICE_FILE2" >/dev/null <<EOF
[Unit]
Description=Reapply CAKE Qdisc TO $interface when network interface is reinitialized (suspend/wake) - TOLGA EROK VERSION 6.2
After=suspend.target

[Service]
Type=oneshot
ExecStart=/bin/bash -c 'interface=\$(ip link show | awk -F: '\''\$0 ~ "wlp|wlo|wlx" && \$0 !~ "NO-CARRIER" {gsub(/^[ \t]+|[ \t]+$/, "", \$2); print \$2; exit}'\''); if [ -n "\$interface" ]; then sudo tc qdisc replace dev "\$interface" root cake bandwidth 1Gbit diffserv4 triple-isolate nonat nowash ack-filter split-gso rtt 10ms raw overhead 18; fi'
RemainAfterExit=true

[Install]
WantedBy=suspend.target
EOF
}

# Reload systemd and start the services
reload_and_start_services() {
    echo "Reloading systemd daemon..."
    sudo systemctl daemon-reload || {
        echo -e "${RED}Failed to reload systemd daemon. Exiting.${NC}"
        exit 1
    }

    echo "Starting and enabling services..."
    sudo systemctl start "$SERVICE_NAME" || {
        echo -e "${RED}Failed to start $SERVICE_NAME. Exiting.${NC}"
        exit 1
    }
    sudo systemctl enable "$SERVICE_NAME" || {
        echo -e "${RED}Failed to enable $SERVICE_NAME. Exiting.${NC}"
        exit 1
    }

    sudo systemctl start "$SERVICE_NAME2" || {
        echo -e "${RED}Failed to start $SERVICE_NAME2. Exiting.${NC}"
        exit 1
    }
    sudo systemctl enable "$SERVICE_NAME2" || {
        echo -e "${RED}Failed to enable $SERVICE_NAME2. Exiting.${NC}"
        exit 1
    }
}

# Main function
main() {
    apply_cake_qdisc
    create_service_file
    create_wake_service_file
    reload_and_start_services
    echo -e "${BLUE}Services created and started successfully.${NC}"
}

# Run the main function
main

if ! grep -q "alias restart-cake=" "$HOME/.bashrc"; then
    echo -e "\n\033[1;33mAlias 'restart-cake' not found. Adding it to .bashrc...\033[0m"
    echo "alias restart-cake='sudo systemctl daemon-reload && \
    sudo systemctl start apply-cake-qdisc.service && \
    sudo systemctl start apply-cake-qdisc-wake.service && \
    sudo systemctl enable apply-cake-qdisc.service && \
    sudo systemctl enable apply-cake-qdisc-wake.service && \
    sudo systemctl status apply-cake-qdisc.service --no-pager && \
    echo \"\" && \
    echo \"|-----------------------------------------------------------------------------------------------------|\" && \
    echo \"\" && \
    sudo systemctl status apply-cake-qdisc-wake.service --no-pager'" >>"$HOME/.bashrc"
    echo -e "\n\033[1;33mAlias 'restart-cake' added to .bashrc.\033[0m"
else
    echo -e "\n\033[1;33mAlias 'restart-cake' already exists in .bashrc. Skipping.\033[0m"
fi

interface=$(ip link show | awk -F: '$0 ~ "wlp|wlo|wlx" && $0 !~ "NO-CARRIER" {gsub(/^[ \t]+|[ \t]+$/, "", $2); print $2; exit}')
if [ -n "$interface" ]; then
    echo "Detected wireless interface: $interface"
    tc_command="sudo tc qdisc replace dev \"$interface\" root cake bandwidth 1Gbit diffserv4 triple-isolate nonat nowash ack-filter split-gso rtt 10ms raw overhead 18"
    echo "Executing: $tc_command"
    eval $tc_command

    echo
    echo "Active configuration for $interface:"
    echo "┌───────────────────────────────────────────────────────────────────────────────────────────────┐"
    sudo tc qdisc show dev "$interface"
    echo "└───────────────────────────────────────────────────────────────────────────────────────────────┘"
else
    echo "No active wireless interface found."
fi
