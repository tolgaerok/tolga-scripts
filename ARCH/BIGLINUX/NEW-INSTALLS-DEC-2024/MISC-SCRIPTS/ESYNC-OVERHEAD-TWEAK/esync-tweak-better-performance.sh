#!/usr/bin/env bash

# Metadata
# ----------------------------------------------------------------------------
AUTHOR="Tolga Erok"
VERSION="1"
DATE_CREATED="22/12/2024"

# Configuration to tweak overall system performance for wine/proton or workstation
# ----------------------------------------------------------------------------------

# limits
SOFT_LIMIT=1024
HARD_LIMIT=1048576

# update systemd configuration
update_systemd_config() {
    local config_file="$1"
    local pattern="DefaultLimitNOFILE=${SOFT_LIMIT}:${HARD_LIMIT}"

    if grep -q "^DefaultLimitNOFILE=" "$config_file"; then
        echo "Found existing DefaultLimitNOFILE entry in $config_file. Updating..."
        sudo sed -i "s/^DefaultLimitNOFILE=.*/$pattern/" "$config_file"
    else
        echo "Adding DefaultLimitNOFILE entry to $config_file..."
        echo "$pattern" | sudo tee -a "$config_file" >/dev/null
    fi
}

# system-wide
echo "Updating system-wide limits..."
update_systemd_config /etc/systemd/system.conf
update_systemd_config /etc/systemd/user.conf

# Reload systemd
echo "Reloading systemd configuration..."
sudo systemctl daemon-reexec

# Apply limits
echo "Applying session limits..."
ulimit -Sn $SOFT_LIMIT
ulimit -Hn $HARD_LIMIT

# Verify in a clean environment
echo "Verifying configuration in a clean environment..."
env -i bash --norc --noprofile -c "
    echo -n 'Soft limit (clean env): '; ulimit -Sn
    echo -n 'Hard limit (clean env): '; ulimit -Hn
"

# Display the final configuration
echo "Final configuration:"
grep DefaultLimitNOFILE /etc/systemd/system.conf /etc/systemd/user.conf

echo "Tweak completed successfully!"
