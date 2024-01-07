#!/bin/bash
# Tolga Erok
# 7/1/2024
# Solus tweaks

# Remote:
# sudo bash -c "$(curl -fsSL https://raw.githubusercontent.com/tolgaerok/tolga-scripts/main/SOLUS/solus-tweak.sh)"

#    ██████  ▒█████   ██▓     █    ██   ██████
#  ▒██    ▒ ▒██▒  ██▒▓██▒     ██  ▓██▒▒██    ▒
#  ░ ▓██▄   ▒██░  ██▒▒██░    ▓██  ▒██░░ ▓██▄
#    ▒   ██▒▒██   ██░▒██░    ▓▓█  ░██░  ▒   ██▒
#  ▒██████▒▒░ ████▓▒░░██████▒▒▒█████▓ ▒██████▒▒
#  ▒ ▒▓▒ ▒ ░░ ▒░▒░▒░ ░ ▒░▓  ░░▒▓▒ ▒ ▒ ▒ ▒▓▒ ▒ ░
#  ░ ░▒  ░ ░  ░ ▒ ▒░ ░ ░ ▒  ░░░▒░ ░ ░ ░ ░▒  ░ ░
#  ░  ░  ░  ░ ░ ░ ▒    ░ ░    ░░░ ░ ░ ░  ░  ░
#        ░      ░ ░      ░  ░   ░           ░
#

# Function to detect the Linux distribution
detect_distro() {
    if [ -f "/etc/solus-release" ]; then
        echo "solus"
    elif [ -f "/etc/fedora-release" ]; then
        echo "fedora"
    else
        echo "unknown"
    fi
}

# Function to apply tweaks for Solus
apply_solus_tweaks() {

    clear 
    
    # Install lsd dependencies
    sudo eopkg up
    sudo eopkg it lsd

    # Check zram
    if [ -e /dev/zram0 ]; then
        echo
        echo "Zram is active."
    else
        echo
        echo "Zram is not active."
    fi

    echo
    
    # Check zswap parameters
    zswap_enabled=$(cat /sys/module/zswap/parameters/enabled)
    echo "zswap.enabled = $zswap_enabled"
    echo "Checking zswap status"
    if [ "$zswap_enabled" = "Y" ]; then
        echo "Zswap is active."
        echo
    else
        echo "Zswap is not active."
        echo
    fi

    # Create sysctl configuration file
    echo 'net.ipv4.tcp_congestion_control = westwood' | sudo tee /etc/sysctl.d/99-custom.conf

    # Create udev rule for I/O scheduler
    echo 'ACTION=="add|change", KERNEL=="sda", ATTR{queue/scheduler}="none"' | sudo tee /etc/udev/rules.d/60-scheduler.rules

    # Enable zswap in clr-boot-manager configuration
    # echo 'zswap.enabled=1' | sudo tee -a /etc/kernel/cmdline

    # Apply sysctl changes
    sudo udevadm control --reload-rules
    sudo udevadm trigger
    sudo sysctl --system

    # Update clr-boot-manager
    sudo clr-boot-manager update

    echo
    cat /sys/block/sda/queue/scheduler
    echo 
    sysctl net.ipv4.tcp_congestion_control
    echo 
    echo "Solus configuration files created and changes applied. You may need to reboot for the changes to take effect."
}

# Function to apply tweaks for Fedora
apply_fedora_tweaks() {
    # Create sysctl configuration file, old nixos trick
    echo 'net.ipv4.tcp_congestion_control = westwood' | sudo tee /etc/sysctl.d/99-custom.conf

    # Create udev rule for I/O scheduler
    echo 'ACTION=="add|change", KERNEL=="sda", ATTR{queue/scheduler}="none"' | sudo tee /etc/udev/rules.d/60-scheduler.rules

    # Apply sysctl changes
    sudo sysctl --system

    # Check zram
    ls /dev/zram*

    # Check zswap parameters, from fedora 39
    zswap_enabled=$(cat /sys/module/zswap/parameters/enabled)
    echo "zswap.enabled = $zswap_enabled"
    echo "Checking zswap status"
    if [ "$zswap_enabled" = "Y" ]; then
        echo "Zswap is active."
    else
        echo "Zswap is not active."
    fi

    # Detect whether BIOS or UEFI is used, old RHEL trick
    if [ -d /sys/firmware/efi ]; then
        # UEFI
        grub_command="grub-mkconfig"
    else
        # BIOS
        grub_command="grub2-mkconfig"
    fi

    # Update GRUB configuration
    sudo $grub_command -o /boot/grub2/grub.cfg 

    echo "Fedora configuration files created and changes applied. You may need to reboot for the changes to take effect."
}

# Main script

# Detect the distribution
distro=$(detect_distro)

# Apply tweaks based on the detected distribution
case $distro in
"solus")
    apply_solus_tweaks
    ;;
"fedora")
    apply_fedora_tweaks
    ;;
*)
    echo "Unsupported or unknown Linux distribution."
    ;;
esac

# Notes: from fedora && nixos
# sudo bash -c 'echo "westwood" > /proc/sys/net/ipv4/tcp_congestion_control'
# sudo echo mq-deadline | sudo tee /sys/block/sda/queue/scheduler

# /usr/lib/sysctl.d/70-zram.conf is where zram settings are found
