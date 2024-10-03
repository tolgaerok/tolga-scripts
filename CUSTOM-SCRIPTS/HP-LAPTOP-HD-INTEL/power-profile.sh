#!/bin/bash

# Tolga Erok
# 11-3-2024

# Converted nixos file to fedora equivalent

# Install required packages
sudo dnf install -y acpi cpufrequtils cpupower-gui ethtool powertop tlp

# Laptop configuration
sudo tee -a /etc/udev/rules.d/99-power.rules <<EOF
ACTION=="add", SUBSYSTEM=="usb", TEST=="power/control", ATTR{power/control}="auto"   # autosuspend USB devices
ACTION=="add", SUBSYSTEM=="pci", TEST=="power/control", ATTR{power/control}="auto"   # autosuspend PCI devices
ACTION=="add", SUBSYSTEM=="net", NAME=="enp*", RUN+="/sbin/ethtool -s \$name wol d" # disable Ethernet Wake-on-LAN
EOF

# Xserver configuration
sudo tee -a /etc/X11/xorg.conf.d/50-libinput.conf <<EOF
Section "InputClass"
    Identifier "libinput touchpad catchall"
    MatchIsTouchpad "on"
    MatchDevicePath "/dev/input/event*"
    Driver "libinput"
    Option "Tapping" "false"
    Option "NaturalScrolling" "true"
    Option "ScrollMethod" "twofinger"
    Option "DisableWhileTyping" "true"
    Option "ClickMethod" "clickfinger"
EndSection
EOF

# Update microcode when available
sudo grubby --update-kernel=ALL --args="microcode_update=$(lscpu | grep 'Vendor ID' | awk '{print tolower($3)}')"

# Additional kernel parameters
# Should look like: GRUB_CMDLINE_LINUX="i915.enable_dc=4 i915.enable_fbc=1 i915.enable_guc=2 i915.enable_psr=1 i915.disable_power_well=1 iwlmvm.power_scheme=3 iwlwifi.power_save=1 iwlwifi.uapsd_disable=1 iwlwifi.power_level=5 snd_hda_intel.power_save=1 snd_hda_intel.power_save_controller=Y intel_pstate=disable"

sudo grubby --update-kernel=ALL --args="i915.enable_dc=4 i915.enable_fbc=1 i915.enable_guc=2 i915.enable_psr=1 i915.disable_power_well=1"
sudo grubby --update-kernel=ALL --args="iwlmvm.power_scheme=3"
sudo grubby --update-kernel=ALL --args="iwlwifi.power_save=1 iwlwifi.uapsd_disable=1 iwlwifi.power_level=5"
sudo grubby --update-kernel=ALL --args="snd_hda_intel.power_save=1 snd_hda_intel.power_save_controller=Y"
sudo grubby --update-kernel=ALL --args="intel_pstate=disable"

# Hardware video acceleration
sudo dnf install -y libva-intel-driver intel-gmmlib intel-media-driver libvdpau-va-gl vulkan-validation-layers

# Power management
sudo tee -a /etc/NetworkManager/conf.d/power-save.conf <<EOF
[connection]
wifi.powersave = 3
EOF

# TLP configuration
sudo dnf install -y tlp
sudo tee -a /etc/tlp.conf <<EOF
DISK_DEVICES="nvme0n1 nvme1n1 sda sdb"
AHCI_RUNTIME_PM_ON_AC=on
AHCI_RUNTIME_PM_ON_BAT=on
CPU_BOOST_ON_AC=1
CPU_BOOST_ON_BAT=0
CPU_ENERGY_PERF_POLICY_ON_AC=ondemand
CPU_ENERGY_PERF_POLICY_ON_BAT=ondemand
CPU_MAX_PERF_ON_AC=99
CPU_MAX_PERF_ON_BAT=75
CPU_MIN_PERF_ON_BAT=75
CPU_SCALING_GOVERNOR_ON_AC=performance
CPU_SCALING_GOVERNOR_ON_BAT=powersave
NATACPI_ENABLE=1
RUNTIME_PM_ON_AC=on
RUNTIME_PM_ON_BAT=on
SCHED_POWERSAVE_ON_BAT=1
SOUND_POWER_SAVE_ON_AC=0
SOUND_POWER_SAVE_ON_BAT=1
START_CHARGE_THRESH_BAT0=40
STOP_CHARGE_THRESH_BAT0=80
TPACPI_ENABLE=1
TPSMAPI_ENABLE=1
WOL_DISABLE=Y
EOF

# Enable TLP
sudo systemctl enable tlp
sudo systemctl start tlp

# Enable brightness control
sudo tee -a /etc/udev/rules.d/81-backlight.rules <<EOF
SUBSYSTEM=="backlight", ACTION=="add", RUN+="/bin/chgrp video /sys/class/backlight/%k/brightness"
SUBSYSTEM=="backlight", ACTION=="add", RUN+="/bin/chmod g+w /sys/class/backlight/%k/brightness"
EOF

# Reboot for changes to take effect
sudo reboot
