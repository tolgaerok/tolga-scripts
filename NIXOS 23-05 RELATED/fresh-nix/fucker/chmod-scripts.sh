#!/bin/bash

# Get the current working directory
folder="$(pwd)"

# Find all files ending with the .sh extension inside the folder
find "$folder" -type f -name "*.sh" -exec chmod +x {} \;

