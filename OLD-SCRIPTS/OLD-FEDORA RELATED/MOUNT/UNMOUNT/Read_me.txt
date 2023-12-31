Tolga Erok
11/4/2023


This script is designed to unmount all mounted filesystems under the directories /mnt and /media and then disable and re-enable the network. Here is a brief summary in a more simplified and concise form:

1. Define a function called "unmount_directory" that unmounts a given directory and checks if the unmounting was successful.
2. Loop through all mounted filesystems under the /mnt directory and unmount them using the "unmount_directory" function.
3. Loop through all mounted filesystems under the /media directory and unmount them using the "unmount_directory" function.
4. Check if any unmounts failed and display an appropriate message.
5. If all unmounts were successful, display a message indicating the completion of unmounting.
6. Disable the network by stopping the NetworkManager service.
7. Wait for a brief moment to ensure the network is fully disabled.
8. Enable the network by starting the NetworkManager service.
9. Exit the script with a success status code.

In summary, the script unmounts mounted filesystems, ensures the network is disabled, and then re-enables it.

Note:
Must be run in sudo
