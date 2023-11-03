Tolga Erok
11/5/2023

The script performs the following tasks:

1. Defines two arrays: `INCLUDE_FOLDERS` containing the names of specific folders to be synced and `EXCLUDE_DIRS` specifying directories to be excluded.
2. Sets variables for the source directory (`SOURCE_DIR`), destination directory (`DEST_DIR`), username (`USERNAME`), password (`PASSWORD`), server IP address (`SERVER_IP`), and mount options (`MOUNT_OPTIONS`).
3. Checks if the source directory exists and creates it if it doesn't.
4. Checks if the source directory is already mounted and exits if it is.
5. Mounts an SMB share from the server to the source directory using the specified parameters.
6. If the mount operation fails, it displays an error message and exits.
7. Uses `rsync` to synchronize the specified folders from the source directory to the user's home directory (`DEST_DIR`).
8. Changes the ownership and permissions of the synchronized folders to the specified user.
9. Unmounts the SMB share from the source directory.

In summary, this script allows a user to sync specific folders from a server to their home directory using SMB protocol, ensuring the folders are up to date and preserving ownership and permissions.


Note:
Please be aware that while the script includes a step to create the `/mnt/smb-rsync` directory, it is advisable to exercise caution and manually create the mount point with the appropriate permissions beforehand. To manually create the mount point and set the permissions, please execute the following commands in your terminal:

sudo mkdir /mnt/smb-rsync
sudo chmod 777 /mnt/smb-rsync

These commands will create the directory and set the permissions to `777`, granting read, write, and execute permissions to all users.
