#!/run/current-system/sw/bin/bash

# Tolga Erok
# 12/5/2023
# About:
#   Personal RSYNC script that only rsyncs selected folders listed in INCLUDE_FOLDERS variables
#   excluding ALL hidden files and folders from //192.168.0.3/LinuxData/HOME/tolga into /home/tolga
#
# Version: 1.2
#
# Change log:
#   Added "Music" into INCLUDE_FOLDERS variables
# Corrected wrong permissions and group created on /home/tolga when transferred back into home folder:
#   Added sudo chown -R tolga:tolga "$DEST_DIR/$folder"
#   Added sudo chmod -R u+rwx "$DEST_DIR/$folder"

# set variables
INCLUDE_FOLDERS=(
    "Desktop"
    "Documents"
    "Downloads"
    "Music"
    "Pictures"
    "Public"
    "Templates"
    "Videos"
)
EXCLUDE_DIRS=(
    ".cache"
)

SOURCE_DIR="/mnt/smb-rsync"
DEST_DIR="/home/tolga"
USERNAME="XXX"            # Add user-name
PASSWORD="XXX"            # Add password
SERVER_IP="xxx.xxx.x.x"   # Add IP address of destination
MOUNT_OPTIONS="username=$USERNAME,password=$PASSWORD,uid=$USER,gid=$(id -g),file_mode=0777,dir_mode=0777"

# create mount point if it doesn't exist
if [ ! -d "$SOURCE_DIR" ]; then
  sudo mkdir -p "$SOURCE_DIR"
fi

# check if already mounted
if mountpoint -q "$SOURCE_DIR"; then
  echo "Mount point already in use: $SOURCE_DIR"
  exit 1
fi

# mount smb share
sudo mount -t cifs "//$SERVER_IP/LinuxData/HOME/$USERNAME" "$SOURCE_DIR" -o "$MOUNT_OPTIONS"

# check if mount was successful
if [ $? -ne 0 ]; then
  echo "Failed to mount SMB share"
  exit 1
fi

# rsync
for folder in "${INCLUDE_FOLDERS[@]}"; do
  rsync -avz --exclude="${EXCLUDE_DIRS[@]}" "$SOURCE_DIR/$folder/" "$DEST_DIR/$folder/"
  sudo chown -R "$USERNAME:users" "$DEST_DIR/$folder"  #  Change users in "$USERNAME:users" to your user name (root, fred, sleepy_joe_biden etc)
  sudo chmod -R 0777 "$DEST_DIR/$folder"
done

# unmount smb share
sudo umount "$SOURCE_DIR"












