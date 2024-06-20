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

### Add custom kernel boot paramaters, i.e: mitigations to off
![image](https://github.com/tolgaerok/tolga-scripts/assets/110285959/7f330030-22d0-4eb1-bd42-a4edcee0c9a0)


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
