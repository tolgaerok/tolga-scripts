#!/usr/bin/env bash

# Metadata
# ----------------------------------------------------------------------------
# AUTHOR="Tolga Erok"
# VERSION="1"
# DATE_CREATED="23/12/2024"
# Description: Create script, make executable and echo into user bashrc.
# Purpose: To check if CAKE works after suspend.

# Configuration
# ----------------------------------------------------------------------------

# Write the check-interface.sh script
echo "#!/bin/bash

# Get the interface name
interface=\$(ip link show | awk -F: '\$0 ~ /wlp|wlo|wlx/ && \$0 !~ /NO-CARRIER/ {gsub(/^[ \\t]+|[ \\t]+$/, \"\", \$2); print \$2; exit}')

# Get the qdisc status for the interface
output=\$(sudo tc qdisc show dev \"\$interface\")

# Define color codes
GREEN=\"\033[1;32m\"
RED=\"\033[1;31m\"
RESET=\"\033[0m\"

# Check if 'cake' is present in the output
if echo \"\$output\" | grep -q 'cake'; then
    echo -e \"\\n\${GREEN}Interface \$interface is working after suspend\${RESET}\\n\"
else
    echo -e \"\\n\${RED}Interface \$interface did NOT work after suspend\${RESET}\\n\"
fi
sudo systemctl status apply-cake-qdisc-wake.service --no-pager
" >~/check-interface.sh

# Make it executable
chmod +x ~/check-interface.sh

# Add alias to .bashrc
echo 'alias check2="~/check-interface.sh"' >>~/.bashrc
