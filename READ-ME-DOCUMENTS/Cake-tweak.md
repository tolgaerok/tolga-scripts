# Cake qdisc tweak
My script applies the CAKE qdisc with a bandwidth limit of 1 Gbit/s to both wlo1 and wlp3s0 interfaces

![image](https://github.com/tolgaerok/tolga-scripts/assets/110285959/78b10e56-6b0c-44cc-9f50-6731201fabd3)


Why Use CAKE Qdisc?

- Reduces Latency (Bufferbloat)
        CAKE helps keep internet latency low, even when your network is busy, by controlling how much data is buffered.

- Fair Traffic Distribution
        CAKE ensures that all devices and applications get a fair share of the network bandwidth. It doesn't let one device or application hog the connection.

- Automatic Optimization
        CAKE automatically adjusts its settings to optimize network performance, requiring less manual tuning compared to older methods.

- Easy Bandwidth Management
        CAKE makes it simple to set bandwidth limits and prioritize important traffic, ensuring critical applications run smoothly.

Summary

- Lower Latency: Less lag during high traffic.
- Fairness: Even distribution of bandwidth.
- Simpler Setup: Easier to configure and manage.

# CODE
```script
#!/bin/bash
# Tolga Erok
# 2-6-24

# Define the interfaces on the system (wifi)
interfaces=("wlo1" "wlp3s0")

# Colors for output
YELLOW="\033[1;33m"
BLUE="\033[0;34m"
RED="\033[0;31m"
NC="\033[0m" # No Color

# Apply CAKE qdisc to each interface
for interface in "${interfaces[@]}"; do
    echo -e "${BLUE}Configuring interface ${interface}...${NC}"
    if sudo tc qdisc replace dev "$interface" root cake bandwidth 1Gbit; then
        echo -e "${YELLOW}Successfully configured CAKE qdisc on ${interface}.${NC}"
    else
        echo -e "${RED}Failed to configure CAKE qdisc on ${interface}.${NC}"
    fi
done

# Display the configured qdiscs
for interface in "${interfaces[@]}"; do
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
for interface in "${interfaces[@]}"; do
    echo -e "${BLUE}Verifying qdisc configuration for ${interface}:${NC}"
    qdisc_output=$(sudo tc qdisc show dev "$interface")
    if echo "$qdisc_output" | grep -q 'cake'; then
        echo -e "${YELLOW}CAKE qdisc is active on ${interface}.${NC}"
    else
        echo -e "${RED}CAKE qdisc is NOT active on ${interface}.${NC}"
    fi
    echo "$qdisc_output"
done


```
Usage:

- Save the script to a file, e.g., `apply_cake_qdisc.sh`

Make the script executable:

```bash
chmod +x apply_cake_qdisc.sh
```
- Run the script:

```bash
./apply_cake_qdisc.sh
```

This script will ensure that the CAKE qdisc is applied to the specified wireless interface's and that the default qdisc is set to CAKE in the `sysctl.conf` file. 
