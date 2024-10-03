#!/bin/bash
# Tolga Erok
# 14/1/2024


workgroup="WORKGROUP"

# colors
BRIGHT_BLUE='\033[1;34m'
BRIGHT_GREEN='\033[1;32m'
BRIGHT_YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${BRIGHT_BLUE}Querying NetBIOS names for:${NC} ${BRIGHT_GREEN}$workgroup${NC}"

# Perform NetBIOS name lookup for the specified workgroup and variations of case
for name in "$workgroup" "samba" "Samba" "SAMBA" "WORKGROUP" "workgroup"; do
    echo -e "${BRIGHT_YELLOW}NetBIOS Name:${NC} ${BRIGHT_GREEN}$name${NC}"
    nmblookup -S "$name"
    echo "----------------------------------------"
done

echo -e "${BRIGHT_BLUE}Script completed.${NC}"
