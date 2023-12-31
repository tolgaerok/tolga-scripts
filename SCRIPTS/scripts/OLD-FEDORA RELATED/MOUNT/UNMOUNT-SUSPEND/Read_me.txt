Tolga Erok
16/5/2023


This script is designed to unmount all mounted filesystems under the directories /mnt and /media, and then suspend the system. Here's a short and simple summary of what the script does in a fluent human tech style:

1. The script defines a function called "unmount_directory" to unmount a given directory.
2. It loops through all mounted filesystems under /mnt and unmounts each one using the "unmount_directory" function.
3. It then loops through all mounted filesystems under /media and unmounts each one using the same function.
4. After unmounting all filesystems, it checks if any unmounts failed. If there are still mounted filesystems under /mnt or /media, it displays an error message.
5. If all unmounts were successful, it displays a message indicating that the unmounting process is done.
6. It then proceeds to disable the network by stopping the NetworkManager service.
7. Finally, it suspends the system using the "systemctl suspend" command.
8. The script exits with a status code of 0, indicating successful execution.

Note:
Run in sudo
