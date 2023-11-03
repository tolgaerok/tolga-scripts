#!/bin/bash

# Directory to save the test files
output_directory="/home/tolga/Videos/"

# Function to perform write test
perform_write_test() {
    local smb_version="$1"
    local ip_address="$2"
    local test_file="${output_directory}testfile_smb_${smb_version}_${ip_address}"
    # Replace "your_write_test_command" with the actual write test command
    dd if=/dev/zero of="$test_file" bs=10M count=10
}

# Function to perform read test
perform_read_test() {
    local smb_version="$1"
    local ip_address="$2"
    local test_file="${output_directory}testfile_smb_${smb_version}_${ip_address}"
    # Replace "your_read_test_command" with the actual read test command
    cat "$test_file" > /dev/null
}

# Test targets with IP range
targets=("NT1" "SMB2" "SMB2_02" "SMB2_10" "SMB2_22" "SMB2_24" "SMB3" "SMB3_00" "SMB3_02" "SMB3_10" "SMB3_11")
ip_range=("192.168.0.1" "192.168.0.20")

# Perform tests for each target and IP
for smb_version in "${targets[@]}"; do
    for ip_address in "${ip_range[@]}"; do
        echo "Testing write performance with SMB version $smb_version to IP $ip_address..."
        perform_write_test "$smb_version" "$ip_address"

        if [ $? -eq 0 ]; then
            echo "Write test successful for SMB version $smb_version to IP $ip_address"
        else
            echo "Error: Write test failed for SMB version $smb_version to IP $ip_address"
        fi

        echo "Testing read performance with SMB version $smb_version from IP $ip_address..."
        perform_read_test "$smb_version" "$ip_address"

        if [ $? -eq 0 ]; then
            echo "Read test successful for SMB version $smb_version from IP $ip_address"
        else
            echo "Error: Read test failed for SMB version $smb_version from IP $ip_address"
        fi
    done
done
