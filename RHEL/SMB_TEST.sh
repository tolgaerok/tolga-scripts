#!/bin/bash

# Function to perform write test
# Function to perform write test
perform_write_test() {
    # Replace "your_write_test_command" with the actual write test command
    dd if=/dev/zero of=testfile bs=10M count=100
}


# Function to perform read test
# Function to perform read test
perform_read_test() {
    # Replace "your_read_test_command" with the actual read test command
    cat testfile > /dev/null
}


# Define test targets
# targets=("192.168.0.3 NT1" "192.168.0.3 CORE" "192.168.0.3 COREPLUS" "192.168.0.3 SMB2" "192.168.0.3 SMB2_02" "192.168.0.3 SMB2_10" "192.168.0.3 SMB2_22" "192.168.0.3 SMB2_24" "192.168.0.10 NT1" "192.168.0.10 CORE" "192.168.0.10 COREPLUS" "192.168.0.10 SMB2" "192.168.0.10 SMB2_02" "192.168.0.10 SMB2_10" "192.168.0.10 SMB2_22" "192.168.0.10 SMB2_24")

# Test targets
targets=("192.168.0.1 (NT1)" "192.168.0.1 (SMB2)" "192.168.0.1 (SMB2_02)" "192.168.0.1 (SMB2_10)" "192.168.0.1 (SMB2_22)" "192.168.0.1 (SMB2_24)" "192.168.0.1 (SMB3)" "192.168.0.1 (SMB3_00)" )


# Perform tests for each target
for target in "${targets[@]}"; do
    echo "Testing write performance to $target   ..."
    perform_write_test

    if [ $? -eq 0 ]; then
        echo "Write test successful for $target"
    else
        echo "Error: Write test failed for $target"
    fi

    echo "Testing read performance from $target     ..."
    perform_read_test

    if [ $? -eq 0 ]; then
        echo "Read test successful from $target"
    else
        echo "Error: Read test failed from $target"
    fi
done
