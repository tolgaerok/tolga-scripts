Tolga Erok
11/5/2023

The script is a personal RSYNC script that synchronizes selected folders from a local directory to a remote destination. It excludes hidden files and folders. Here's a summary of its functionality:

1. Unmounts all `/mnt` points, reloads the daemon, and `fstab`.
2. Sets variables for the source directory, destination directory, username, password, server IP, and mount options.
3. Mounts the SMB share using the specified parameters.
4. If the mount operation fails, it displays an error message and exits.
5. Performs synchronization using `rsync` for each folder listed in the `INCLUDE_FOLDERS` variable, excluding directories specified in `EXCLUDE_DIRS`.
6. Reloads the daemon, `fstab`, and mounts all filesystems specified in `fstab` using `mount -a`.


Note:
Please be aware that the script does not include a step to create the `/mnt/smb-rsync` directory, it is advisable to exercise caution and manually create the mount point with the appropriate permissions beforehand. To manually create the mount point and set the permissions, please execute the following commands in your terminal:

sudo mkdir /mnt/smb-rsync
sudo chmod 777 /mnt/smb-rsync

These commands will create the directory and set the permissions to `777`, granting read, write, and execute permissions to all users.
