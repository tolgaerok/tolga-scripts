#!/bin/bash
#####################################################################################################################################
#   Unmount > All                                                                                                                   #
#   Tolga Erok
#   May 29, 2023
#
#   This script un-mounts all mount points located under the /mnt directories.
#   It uses a function called "umount_directory" to un-mount each directory individually.
#   The script provides feedback on the success or failure of each un-mount operation.
#   At the end, it displays a summary indicating if all directories were successfully un-mounted or not.
#   It waits for 3 seconds before exiting.
#   Function to un-mount a directory...
#                                                                                                                                   #
#####################################################################################################################################
echo -e "\033[34m" # Set text color to blue
echo "Unmounting all mount points"
echo -e "\033[1;37m"

# Function to unmount a directory
unmount_directory() {
    local dir="$1"

    # Unmount the directory forcefully
    sudo umount -lf "$dir"

    # Check if unmounting was successful
    if mountpoint -q "$dir"; then
        echo "Unmount of $dir failed"
        return 1
    fi

    return 0
}

# Unmount all mounted filesystems under /mnt
while IFS= read -r mount_point; do
    unmount_directory "$mount_point"
done < <(sudo mount | awk '$3 ~ /^\/mnt/ {print $3}')

# Unmount all mounted filesystems under /media
while IFS= read -r mount_point; do
    unmount_directory "$mount_point"
done < <(sudo mount | awk '$3 ~ /^\/media/ {print $3}')

# Check if any unmounts failed
if sudo mount | grep -E '^/mnt/|^/media/' >/dev/null; then
    echo "Unable to unmount all filesystems under /mnt and /media"
else
    echo -e "\033[1;33mUnmounting done.\033[0m"

    # Prompt the user to choose whether to suspend
    read -rp "Do you want to suspend the system? (y/n): " choice
    case "$choice" in
    [yY])
        # Suspend the system
        echo -e "\033[34mSuspending system...\033[0m"
        sleep 2 # Add a short delay before suspend to ensure messages are displayed
        sudo systemctl suspend
        ;;
    *)
        echo "System not suspended."
        ;;
    esac
fi

exit 0
