# Cake qdisc tweak
My script applies the CAKE qdisc with a bandwidth limit of 1 Gbit/s to both wlo1 and wlp3s0 interfaces


```script
#!/bin/bash
# Tolga Erok
# 2-6-24

# Define the interfaces
interfaces=("wlo1" "wlp3s0")

# Loop through each interface and apply CAKE qdisc
for interface in "${interfaces[@]}"; do
    echo "Configuring interface $interface..."
    sudo tc qdisc replace dev "$interface" root cake bandwidth 1Gbit
done

# Display the configured qdiscs
for interface in "${interfaces[@]}"; do
    echo "Qdisc configuration for $interface:"
    sudo tc qdisc show dev "$interface"
done

echo "Traffic control settings applied successfully."
```
