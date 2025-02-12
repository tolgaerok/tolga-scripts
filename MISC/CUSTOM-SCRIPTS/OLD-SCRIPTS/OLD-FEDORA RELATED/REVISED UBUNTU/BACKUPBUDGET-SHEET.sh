#!/bin/bash

# Set the source and destination file paths
source_path="/home/tolga/Documents/[ BUDGET 2023 ]/MAINBUDGETv10-1-2023.xlsx"
dest_path="/mnt/linux-data/BACKUP-TEST/"

# Get the current date and time in the format of DD-MM-YYYY_HH-MM-SS
# datetime=$(date +'%d-%m-%Y_%H-%M-%S')
datetime=$(date +'%a - %b %d - %Y - %I-%M-%S %p')

# Extract the year, month, and day from the current date
year=$(date +'%Y')
month=$(date +'%b')
day=$(date +'%a %d')

# Create the destination directory if it doesn't exist
mkdir -p "$dest_path/$year/$month/$day"

# Create the destination filename with the current date and time appended to it
filename="MAINBUDGETv10-1-2023-BACKUP_$datetime.xlsx"

# Copy the source file to the destination folder with the new filename
cp "$source_path" "$dest_path/$year/$month/$day/$filename"

if [ $? -eq 0 ]; then
    # Change the file permissions to tolga:tolga and give full access
    chmod 777 "$dest_path/$year/$month/$day/$filename"
    chown tolga:tolga "$dest_path/$year/$month/$day/$filename"

    # Change group permission to tolga and others to full access
    chmod g+rw "$dest_path/$year/$month/$day/$filename"
    chgrp tolga "$dest_path/$year/$month/$day/$filename"

    # Display a message to confirm that the copy has been completed
    echo "File copied successfully to $dest_path/$year/$month/$day/$filename"
else
    # Display an error message and ask to try again
    echo "Error: File copy failed. Do you want to try again? (y/n)"
    read answer

    if [ "$answer" == "y" ]; then
        # Run the script again
        bash /home/tolga/Documents/"BACKUP BUDGET-SHEET.sh"
    else
        # Exit the script
        exit 1
    fi
fi

# Wait for 3 seconds before exiting
sleep 3
