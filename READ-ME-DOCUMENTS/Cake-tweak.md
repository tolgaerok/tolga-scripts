# Cake qdisc tweak
My script applies the CAKE qdisc with a bandwidth limit of 1 Gbit/s to both wlo1 and wlp3s0 interfaces

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

# Define the interfaces on system (wifi)
interfaces=("wlo1" "wlp3s0")

# Apply CAKE qdisc to each interface
for interface in "${interfaces[@]}"; do
    echo "Configuring interface $interface..."
    sudo tc qdisc replace dev "$interface" root cake bandwidth 1Gbit
done

# Display the configured qdiscs
for interface in "${interfaces[@]}"; do
    echo "Qdisc configuration for $interface:"
    sudo tc qdisc show dev "$interface"
done

# Add net.core.default_qdisc = cake to /etc/sysctl.conf if it doesn't exist
sysctl_conf="/etc/sysctl.conf"
grep -qxF 'net.core.default_qdisc = cake' "$sysctl_conf" || echo 'net.core.default_qdisc = cake' | sudo tee -a "$sysctl_conf"

# Apply the sysctl settings
sudo sysctl -p

echo "Traffic control settings applied successfully."
echo "net.core.default_qdisc set to cake in /etc/sysctl.conf."

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
