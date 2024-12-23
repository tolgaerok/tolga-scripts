#!/usr/bin/env bash

# Metadata
# ----------------------------------------------------------------------------
# AUTHOR="Tolga Erok"
# VERSION=""
# DATE_CREATED="23/12/2024"
# Description: Create script, make executable and echo into user bashrc.
# Purpose: to check CAKE works after suspend.

# Configuration
# ----------------------------------------------------------------------------

echo "#!/bin/bash

interface=\$(ip link show | awk -F: '\$0 ~ \"wlp|wlo|wlx\" && \$0 !~ \"NO-CARRIER\" {gsub(/^[ \t]+|[ \t]+$/, \"\", \$2); print \$2; exit}')
output=\$(sudo tc qdisc show dev \$interface)

if echo \"\$output\" | grep -q 'cake'; then
    echo \"Interface \$interface is working after suspend\"
else
    echo \"Interface \$interface did NOT work after suspend\"
fi" >~/check-interface.sh

# Make it executable
chmod +x ~/check-interface.sh
echo 'alias check2="~/check-interface.sh"' >>~/.bashrc
