#!/bin/bash

# Function to trim a partition and display trim information
trim_partition() {
    local partition="$1"
    echo "Trimming $partition"
    sudo fstrim "$partition"
    local trim_info=$(sudo fstrim -v "$partition")
    echo "$trim_info"
    echo
}

# Trim the root partition (/) if it exists
if [ -d "/" ]; then
    trim_partition "/"
fi

# Trim the home partition (/home) if it exists
if [ -d "/home" ]; then
    trim_partition "/home"
fi

# Trim the swap partition if it exists
swap_partition=$(sudo swapon --show=NAME -s | tail -n 1)
if [ -n "$swap_partition" ]; then
    echo "Trimming swap partition: $swap_partition"
    sudo swapoff "$swap_partition"
    sudo fstrim -v "$swap_partition"
    sudo swapon "$swap_partition"
    echo
fi
