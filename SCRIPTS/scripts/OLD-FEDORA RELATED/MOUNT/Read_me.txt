Tolga Erok
14/5/2023

This script is designed to mount all directories under `/mnt` and `/media` points. Here is a brief summary of what the script does in a more human-readable format:

1. Defines a function named `mount_directory` to mount a specified directory.
2. Loops through all directories under `/mnt` and attempts to mount each directory using the `mount_directory` function. If a mount fails, it keeps track of the number of failed mounts.
3. Loops through all directories under `/media` and attempts to mount each directory using the `mount_directory` function. Again, it keeps track of the number of failed mounts.
4. Reloads the systemd daemon using the command `sudo systemctl daemon-reload`.
5. Checks if any mounts failed. If all mounts were successful, it prints "Mounting done." Otherwise, it prints "Unable to mount all directories."
6. Stops the NetworkManager service using `sudo systemctl stop NetworkManager.service`.
7. Starts the NetworkManager service using `sudo systemctl start NetworkManager.service`.
8. Waits for the network to be fully disabled for 2 seconds.
9. Exits the script with an exit code of 0.

To execute the script, you can follow these steps:
1. Create a new file with a ".sh" extension, for example, "mount_directories.sh".
2. Copy the script provided into the newly created file.
3. Save the file.
4. Open a terminal or command prompt.
5. Navigate to the directory where the script file is located using the 'cd' command.
6. Make the script file executable by running the command `chmod +x mount_directories.sh`.
7. Execute the script by running the command `./mount_directories.sh`.
8. The script will start executing, and you will see the output of each command being executed in the terminal or command prompt window.

Note:
Must be run in sudo
