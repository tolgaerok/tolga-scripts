

### Add custom kernel boot paramaters, i.e: mitigations to off
![image](https://github.com/tolgaerok/tolga-scripts/assets/110285959/7f330030-22d0-4eb1-bd42-a4edcee0c9a0)

![image](https://github.com/tolgaerok/tolga-scripts/assets/110285959/dccae40a-70a5-4609-8b7d-ddcb090bfb79)



- Custom clr linux kernel paramaters

```bash
https://www.kernel.org/doc/Documentation/admin-guide/kernel-parameters.txt
```

- Decide what you want then

```bash
sudo gedit /etc/kernel/cmdline.d/mitigations.conf
```
- add

```bash
mitigations=off
```

- save and exit
- Then

```bash
cd /etc/kernel/cmdline.d/
```

- and
  
```bash
sudo chmod 777 mitigations.conf
```

```bash
sudo clr-boot-manager update
```

- Reboot system and check whether new pboot parameters have been added by running:

```bash
cat /proc/cmdline
```

#

## SCRIPT

```bash
#!/bin/bash
# Tolga Erok
# Jun 21 - 2024
# Personal Solus kernel parameter add-ins

# My personal kernel parameter string
KERNEL_PARAMS="io_delay=none rootdelay=0 threadirqs irqaffinity noirqdebug iomem=relaxed mitigations=off zswap.enabled=1 zswap.compressor=lz4 zswap.max_pool_percent=10 zswap.zpool=zsmalloc"

# Personal conf file to be created
KERNEL_PARAMS_FILE="/etc/kernel/cmdline.d/custom-kernel-parm.conf"

# Check if the file custom-kernel-parm.conf exists
if [ ! -f "$KERNEL_PARAMS_FILE" ]; then

    # If file custom-kernel-parm.conf doesn't exist, create it and add kernel parameters
    echo "$KERNEL_PARAMS" | sudo tee "$KERNEL_PARAMS_FILE" >/dev/null
    echo "Kernel parameters added to $KERNEL_PARAMS_FILE."

else
    # If file custom-kernel-parm.conf exists, check if parameters are already present
    if grep -q "$KERNEL_PARAMS" "$KERNEL_PARAMS_FILE"; then
        echo "Kernel parameters are already present in $KERNEL_PARAMS_FILE."
    else
        # Append KERNEL_PARAMS varible / parameters if not already present
        echo "$KERNEL_PARAMS" | sudo tee -a "$KERNEL_PARAMS_FILE" >/dev/null
        echo "Kernel parameters appended to $KERNEL_PARAMS_FILE."
    fi
fi

# Change file permissions to 777
sudo chmod 777 "$KERNEL_PARAMS_FILE"

# Update Solus clr-boot-manager
sudo clr-boot-manager update

# Have to reboot
echo "Kernel parameters updated. YOU MUST REBBOT to see changes"
echo "After reboot, in terminal, type:"
echo "cat /proc/cmdline"
echo
echo "You should see something similar to mine:"
echo
echo "initrd=\EFI\com.solus-project\initrd-com.solus-project.current.6.8.12-293 root=PARTUUID=da153e7e-871c-4e58-baee-d755786b0d63 quiet splash rw nvidia-drm.modeset=1 nvidia.NVreg_PreserveVideoMemoryAllocations=1 nvidia.NVreg_TemporaryFilePath=/var/tmp io_delay=none rootdelay=0 threadirqs irqaffinity noirqdebug iomem=relaxed mitigations=off zswap.enabled=1 zswap.compressor=lz4 zswap.max_pool_percent=10 zswap.zpool=zsmalloc"

```

#

### Turn on systemD / grub menu at boot

```bash
sudo clr-boot-manager set-timeout 3
sudo clr-boot-manager update
```
#

### Speed up boot especially for Nvidia or in general by turning Off Wayland and use X11

```bash
sudo tee /etc/gdm/custom.conf > /dev/null <<EOF
[daemon]
WaylandEnable=true
AutomaticLoginEnable=false
EOF
```

#
