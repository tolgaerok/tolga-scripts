#!/bin/bash

# Tolga Erok
# 30/12/203

# Basic info

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
RESET='\033[0m'

# Check EarlyOOM statuss
earlyoom_status=$(systemctl is-active earlyoom 2>/dev/null)
echo -e "${YELLOW}EarlyOOM Status:${RESET} $earlyoom_status"

# EarlyOOM configuration file and argumants
earlyoom_conf="/etc/default/earlyoom"
echo -e "${YELLOW}EarlyOOM Configuration File:${RESET} $earlyoom_conf"
if [ -e "$earlyoom_conf" ]; then
    earlyoom_args=$(grep -E '^EARLYOOM_ARGS' $earlyoom_conf 2>/dev/null | cut -d= -f2-)
    echo -e "${YELLOW}EarlyOOM Arguments:${RESET} $earlyoom_args"
fi

# Check Zram module status
zram_module_status=$(lsmod | grep zram)
echo -e "${YELLOW}Zram Module Status:${RESET}"
echo "$zram_module_status"

# Check Zram devices
zram_devices=$(ls /dev/zram* 2>/dev/null)
echo -e "${YELLOW}Zram Devices:${RESET}"
echo "$zram_devices"

# Additional information about EarlyOOM
earlyoom_info=$(which earlyoom 2>/dev/null)
echo -e "${YELLOW}EarlyOOM Binary Location:${RESET} $earlyoom_info"

# Additional information about Zram configuration
zram_conf="/etc/systemd/zram-generator.conf"
echo -e "${YELLOW}Zram Configuration File:${RESET} $zram_conf"

# Output memory and swap information
echo -e "${YELLOW}Memory and Swap Information:${RESET}"
free -h
