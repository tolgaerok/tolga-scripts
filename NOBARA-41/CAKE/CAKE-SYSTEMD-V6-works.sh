#!/usr/bin/env bash
# Metadata
# ----------------------------------------------------------------------------
# AUTHOR="Tolga Erok"
# VERSION="6"
# DATE_CREATED="06/01/2025"

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

# interface="wlp2s0"
BANDWIDTH="1Gbit"
SERVICE_NAME="apply-cake-qdisc.service"
SERVICE_NAME2="apply-cake-qdisc-wake.service"
SERVICE_FILE="/etc/systemd/system/$SERVICE_NAME"
SERVICE_FILE2="/etc/systemd/system/$SERVICE_NAME2"

# Apply CAKE Qdisc settings
apply_cake_qdisc() {
    sudo tc qdisc replace dev "$interface" root cake bandwidth "$BANDWIDTH" diffserv4 triple-isolate nonat nowash ack-filter split-gso rtt 10ms raw overhead 18
    echo "CAKE Qdisc applied to $interface."
}

# Create service file to apply CAKE settingss
create_service_file() {
    echo "Creating systemd service file at $SERVICE_FILE..."
    sudo bash -c "cat <<EOF > $SERVICE_FILE
[Unit]
Description=Apply CAKE Qdisc to $interface at boot - TOLGA EROK VERSION 6
After=network.target

[Service]
Type=oneshot
ExecStart=/usr/sbin/tc qdisc replace dev $interface root cake bandwidth $BANDWIDTH diffserv4 triple-isolate nonat nowash ack-filter split-gso rtt 10ms raw overhead 18
RemainAfterExit=true

[Install]
WantedBy=multi-user.target
EOF"
}

# Create wake service file to reapply CAKE settings after suspend/wake
create_wake_service_file() {
    echo "Creating systemd wake service file at $SERVICE_FILE2..."
    sudo bash -c "cat <<EOF > $SERVICE_FILE2
[Unit]
Description=Reapply CAKE Qdisc when network interface is reinitialized (suspend/wake) - TOLGA EROK VERSION 6
After=suspend.target

[Service]
Type=oneshot
ExecStart=/usr/sbin/tc qdisc replace dev $interface root cake bandwidth $BANDWIDTH diffserv4 triple-isolate nonat nowash ack-filter split-gso rtt 10ms raw overhead 18
RemainAfterExit=true

[Install]
WantedBy=suspend.target
EOF"
}

# Reload systemd and start services
reload_and_start_services() {
    echo "Reloading systemd daemon..."
    sudo systemctl daemon-reload
    echo "Starting and enabling services..."
    sudo systemctl start $SERVICE_NAME
    sudo systemctl enable $SERVICE_NAME
    sudo systemctl start $SERVICE_NAME2
    sudo systemctl enable $SERVICE_NAME2
}

# Main function to apply settings
main() {
    apply_cake_qdisc
    create_service_file
    create_wake_service_file
    reload_and_start_services
    echo "Services created and started successfully."
}

# Run the main function
main
