#!/usr/bin/env bash

# Metadata
# ----------------------------------------------------------------------------
# AUTHOR="Tolga Erok"
# VERSION="1"
# DATE_CREATED="06/01/2025"
# Description: Script to remove previously created systemd services for CAKE qdisc.

# Define service names and file locations
SERVICE_NAME="apply-cake-qdisc.service"
SERVICE_NAME2="apply-cake-qdisc-wake.service"
SERVICE_FILE="/etc/systemd/system/$SERVICE_NAME"
SERVICE_FILE2="/etc/systemd/system/$SERVICE_NAME2"

YELLOW="\033[1;33m"
BLUE="\033[0;34m"
RED="\033[0;31m"
NC="\033[0m"

echo -e "${BLUE}Stopping and disabling existing services...${NC}"

# Stop the existing services if running
sudo systemctl stop $SERVICE_NAME
sudo systemctl stop $SERVICE_NAME2

# Disable the services
sudo systemctl disable $SERVICE_NAME
sudo systemctl disable $SERVICE_NAME2

echo -e "${BLUE}Removing service files...${NC}"

# Remove the systemd service files
sudo rm -f $SERVICE_FILE
sudo rm -f $SERVICE_FILE2

# Reload the systemd daemon to apply the changes
echo -e "${BLUE}Reloading systemd daemon...${NC}"
sudo systemctl daemon-reload

echo -e "${YELLOW}Old systemd services and configurations have been removed.${NC}"

# Check the status
sudo systemctl status $SERVICE_NAME --no-pager || echo -e "${RED}$SERVICE_NAME has been removed.${NC}"
sudo systemctl status $SERVICE_NAME2 --no-pager || echo -e "${RED}$SERVICE_NAME2 has been removed.${NC}"
