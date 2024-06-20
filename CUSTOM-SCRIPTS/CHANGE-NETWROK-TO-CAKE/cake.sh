#!/bin/bash
# Tolga Erok
# 2-6-24

# Colors for output
YELLOW="\033[1;33m"
BLUE="\033[0;34m"
RED="\033[0;31m"
NC="\033[0m" # No Color

# Function to apply CAKE qdisc to an interface
apply_cake_qdisc() {
    local interface=$1
    local bandwidth=$2
    echo -e "${BLUE}Configuring interface ${interface} with bandwidth ${bandwidth}...${NC}"
    if sudo tc qdisc replace dev "$interface" root cake bandwidth "$bandwidth"; then
        echo -e "${YELLOW}Successfully configured CAKE qdisc on ${interface} with bandwidth ${bandwidth}.${NC}"
    else
        echo -e "${RED}Failed to configure CAKE qdisc on ${interface}.${NC}"
    fi
}

# Get a list of all network interfaces (excluding irrelevant ones)
interfaces=$(ip link show | awk -F: '$0 !~ "lo|virbr|docker|^[^0-9]"{print $2;getline}')

# Define bandwidth (adjust as needed or set dynamically)
default_bandwidth="1Gbit"

# Apply CAKE qdisc to each interface
for interface in $interfaces; do
    apply_cake_qdisc "$interface" "$default_bandwidth"
done

# Display the configured qdiscs
for interface in $interfaces; do
    echo -e "${BLUE}Qdisc configuration for ${interface}:${NC}"
    sudo tc qdisc show dev "$interface"
done

# Add net.core.default_qdisc = cake to /etc/sysctl.conf if it doesn't exist
sysctl_conf="/etc/sysctl.conf"
if grep -qxF 'net.core.default_qdisc = cake' "$sysctl_conf"; then
    echo -e "${YELLOW}net.core.default_qdisc is already set to cake in ${sysctl_conf}.${NC}"
else
    echo 'net.core.default_qdisc = cake' | sudo tee -a "$sysctl_conf"
    echo -e "${YELLOW}Added net.core.default_qdisc = cake to ${sysctl_conf}.${NC}"
fi

# Apply the sysctl settings
if sudo sysctl -p; then
    echo -e "${YELLOW}sysctl settings applied successfully.${NC}"
else
    echo -e "${RED}Failed to apply sysctl settings.${NC}"
fi

echo -e "${YELLOW}Traffic control settings applied successfully.${NC}"
echo -e "${YELLOW}net.core.default_qdisc set to cake in /etc/sysctl.conf.${NC}"

# Verification Step
for interface in $interfaces; do
    echo -e "${BLUE}Verifying qdisc configuration for ${interface}:${NC}"
    qdisc_output=$(sudo tc qdisc show dev "$interface")
    if echo "$qdisc_output" | grep -q 'cake'; then
        echo -e "${YELLOW}CAKE qdisc is active on ${interface}.${NC}"
    else
        echo -e "${RED}CAKE qdisc is NOT active on ${interface}.${NC}"
    fi
    echo "$qdisc_output"
done
