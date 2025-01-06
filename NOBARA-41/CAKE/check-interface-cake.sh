#!/bin/bash

# Get the interface name
# interface=$(ip link show | awk -F: '/wlp|wlo|wlx/ && !/NO-CARRIER/ {gsub(/^[ \t]+|[ \t]+$/, "", $2); print $2; exit}')
# interface=\$(ip link show | awk -F: '\$0 ~ /wlp|wlo|wlx/ && \$0 !~ /NO-CARRIER/ {gsub(/^[ \\t]+|[ \\t]+$/, \"\", \$2); print \$2; exit}')
interface=$(ip link show | awk -F: '$0 ~ "^[2-9]:|^[1-9][0-9]: " && $0 ~ "UP" && $0 !~ "LOOPBACK|NO-CARRIER" {gsub(/^[ \t]+|[ \t]+$/, "", $2); print $2; getline}')

# Get the qdisc status 
output=$(sudo tc qdisc show dev "$interface")

# Define color codes
GREEN="\033[1;32m"
RED="\033[1;31m"
RESET="\033[0m"

# Check if 'cake' is present in the output
if echo "$output" | grep -q 'cake'; then
    echo -e "\\n${GREEN}Interface $interface is working after suspend${RESET}\\n"
else
    echo -e "\\n${RED}Interface $interface did NOT work after suspend${RESET}\\n"
fi

sudo systemctl status apply-cake-qdisc-wake.service --no-pager
