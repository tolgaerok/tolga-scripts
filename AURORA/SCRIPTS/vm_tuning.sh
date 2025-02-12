#!/bin/bash
# Tolga erok
# Aurora tweaks
# 18/12/2024

# ----------------------------------------------------------------------------------------------- #

# Check if required paths are available
if [ ! -d "/sys/kernel/mm" ]; then
  echo "Error: /sys/kernel/mm is missing, required for transparent hugepages tuning."
  exit 1
fi

if [ ! -f "/proc/sys/vm/compaction_proactiveness" ]; then
  echo "Error: /proc/sys/vm/compaction_proactiveness is missing."
  exit 1
fi

# VM Tuning Parameters
echo "Applying VM tuning parameters..."

# Apply VM tuning parameters
echo 0 > /proc/sys/vm/compaction_proactiveness
echo 10 > /proc/sys/vm/swappiness
echo 0x0005 > /proc/sys/vm/lru_gen_enabled
echo 0 > /proc/sys/vm/zone_reclaim_mode
echo madvise > /sys/kernel/mm/transparent_hugepage/enabled
echo advise > /sys/kernel/mm/transparent_hugepage/shmem_enabled
echo never > /sys/kernel/mm/transparent_hugepage/defrag
echo 0 > /sys/kernel/mm/khugepaged/defrag
echo 1 > /proc/sys/vm/page_lock_unfairness
echo 1 > /proc/sys/kernel/sched_autogroup_enabled
echo 3000 > /proc/sys/kernel/sched_cfs_bandwidth_slice_us
echo 3000000 > /proc/sys/kernel/sched/base_slice_ns
echo 500000 > /proc/sys/kernel/sched/migration_cost_ns
echo 8 > /proc/sys/kernel/sched/nr_migrate

echo "VM tuning parameters applied."

# Create a systemd service to reapply these settings on boot
echo "Creating systemd service to reapply settings on boot..."

cat > /etc/systemd/system/99-tune-vm.service <<EOF
[Unit]
Description=Apply VM Tuning Parameters

[Service]
Type=oneshot
ExecStart=/bin/bash -c 'echo 0 > /proc/sys/vm/compaction_proactiveness; echo 10 > /proc/sys/vm/swappiness; echo 0x0005 > /proc/sys/vm/lru_gen_enabled; echo 0 > /proc/sys/vm/zone_reclaim_mode; echo madvise > /sys/kernel/mm/transparent_hugepage/enabled; echo advise > /sys/kernel/mm/transparent_hugepage/shmem_enabled; echo never > /sys/kernel/mm/transparent_hugepage/defrag; echo 0 > /sys/kernel/mm/khugepaged/defrag; echo 1 > /proc/sys/vm/page_lock_unfairness; echo 1 > /proc/sys/kernel/sched_autogroup_enabled; echo 3000 > /proc/sys/kernel/sched_cfs_bandwidth_slice_us; echo 3000000 > /proc/sys/kernel/sched/base_slice_ns; echo 500000 > /proc/sys/kernel/sched/migration_cost_ns; echo 8 > /proc/sys/kernel/sched/nr_migrate'
RemainAfterExit=true

[Install]
WantedBy=multi-user.target
EOF

echo "Systemd service created."

# Enable and start the service
echo "Enabling and starting systemd service..."

systemctl daemon-reload
systemctl enable 99-tune-vm.service
systemctl start 99-tune-vm.service

echo "Service enabled and started."

# Recheck the applied settings
echo "Rechecking updated values..."
compaction_proactiveness=$(cat /proc/sys/vm/compaction_proactiveness)
swappiness=$(cat /proc/sys/vm/swappiness)
lru_gen_enabled=$(cat /proc/sys/vm/lru_gen_enabled)
zone_reclaim_mode=$(cat /proc/sys/vm/zone_reclaim_mode)
transparent_hugepage_enabled=$(cat /sys/kernel/mm/transparent_hugepage/enabled)
transparent_hugepage_shmem_enabled=$(cat /sys/kernel/mm/transparent_hugepage/shmem_enabled)
transparent_hugepage_defrag=$(cat /sys/kernel/mm/transparent_hugepage/defrag)
khugepaged_defrag=$(cat /sys/kernel/mm/khugepaged/defrag)
page_lock_unfairness=$(cat /proc/sys/vm/page_lock_unfairness)
sched_autogroup_enabled=$(cat /proc/sys/kernel/sched_autogroup_enabled)
sched_cfs_bandwidth_slice_us=$(cat /proc/sys/kernel/sched_cfs_bandwidth_slice_us)
base_slice_ns=$(cat /proc/sys/kernel/sched/base_slice_ns)
migration_cost_ns=$(cat /proc/sys/kernel/sched/migration_cost_ns)
nr_migrate=$(cat /proc/sys/kernel/sched/nr_migrate)

echo "Current VM Tuning Settings:"
echo "compaction_proactiveness: $compaction_proactiveness"
echo "swappiness: $swappiness"
echo "lru_gen_enabled: $lru_gen_enabled"
echo "zone_reclaim_mode: $zone_reclaim_mode"
echo "transparent_hugepage_enabled: $transparent_hugepage_enabled"
echo "transparent_hugepage_shmem_enabled: $transparent_hugepage_shmem_enabled"
echo "transparent_hugepage_defrag: $transparent_hugepage_defrag"
echo "khugepaged_defrag: $khugepaged_defrag"
echo "page_lock_unfairness: $page_lock_unfairness"
echo "sched_autogroup_enabled: $sched_autogroup_enabled"
echo "sched_cfs_bandwidth_slice_us: $sched_cfs_bandwidth_slice_us"
echo "base_slice_ns: $base_slice_ns"
echo "migration_cost_ns: $migration_cost_ns"
echo "nr_migrate: $nr_migrate"

echo "Done."

# curl -sL https://raw.githubusercontent.com/tolgaerok/solus/main/PERSONAL-SCRIPTS/IO-SCHEDULER/io-scheduler.sh | sudo bash

# Create the systemd service file for setting the I/O scheduler
echo "[Unit]
Description=Set I/O Scheduler on boot

[Service]
Type=simple
ExecStart=/bin/bash -c 'echo kyber | sudo tee /sys/block/sda/queue/scheduler; printf \"I/O Scheduler set to: \"; cat /sys/block/sda/queue/scheduler'

[Install]
WantedBy=default.target" | sudo tee /etc/systemd/system/io-scheduler.service

# Reload systemd, enable, and start the service
sudo systemctl daemon-reload
sudo systemctl enable io-scheduler.service
sudo systemctl start io-scheduler.service
sudo systemctl status io-scheduler.service

# ----------------------------------------------------------------------------------------------- #

# curl -sL https://raw.githubusercontent.com/tolgaerok/solus/main/PERSONAL-SCRIPTS/NETWORK-RELATED/make-cake-systemD-V3-LAPTOP.sh | sudo bash

YELLOW="\033[1;33m"
BLUE="\033[0;34m"
RED="\033[0;31m"
NC="\033[0m"

# Detect any active network interface (uplink or wireless) and trim leading/trailing spaces
interface=$(ip link show | awk -F: '$0 ~ "^[2-9]:|^[1-9][0-9]: " && $0 ~ "UP" && $0 !~ "LOOPBACK|NO-CARRIER" {gsub(/^[ \t]+|[ \t]+$/, "", $2); print $2; exit}')

if [ -z "$interface" ]; then
    echo -e "${RED}No active network interface found. Exiting.${NC}"
    exit 1
fi

echo -e "${BLUE}Detected active network interface: ${interface}${NC}"

SERVICE_NAME="apply-cake-qdisc.service"
SERVICE_FILE="/etc/systemd/system/$SERVICE_NAME"

echo -e "${BLUE}Creating systemd service file at ${SERVICE_FILE}...${NC}"
sudo bash -c "cat > $SERVICE_FILE" <<EOF
[Unit]
Description=Apply CAKE qdisc to $interface
After=network-online.target
Wants=network-online.target

[Service]
Type=oneshot
ExecStart=/sbin/tc qdisc replace dev $interface root cake bandwidth 1Gbit
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
EOF

echo -e "${BLUE}Reloading systemd daemon...${NC}"
sudo systemctl daemon-reload

echo -e "${BLUE}Starting the service...${NC}"
sudo systemctl start $SERVICE_NAME

echo -e "${BLUE}Enabling the service to start at boot...${NC}"
sudo systemctl enable $SERVICE_NAME

echo -e "${BLUE}Verifying qdisc configuration for ${interface}:${NC}"
sudo tc qdisc show dev "$interface"

echo -e "${YELLOW}CAKE qdisc should be applied to ${interface} now.${NC}"

# Show detailed qdisc status for the interface
sudo tc -s qdisc show dev "$interface"

# Check the status of the systemd service
sudo systemctl status apply-cake-qdisc.service

# Add alias to .bashrc for easier access
echo "alias cake2='interface=\$(ip link show | awk -F: '\''\$0 ~ \"wlp|wlo|wlx\" && \$0 !~ \"NO-CARRIER\" {gsub(/^[ \\t]+|[ \\t]+$/, \"\", \$2); print \$2; exit}'\''); sudo systemctl daemon-reload && sudo systemctl restart apply-cake-qdisc.service && sudo tc -s qdisc show dev \$interface && sudo systemctl status apply-cake-qdisc.service'" | sudo tee -a /home/$(whoami)/.bashrc

echo -e "${YELLOW}Alias 'cake2' added to .bashrc. You can use it to quickly apply CAKE settings.${NC}"

# ----------------------------------------------------------------------------------------------- #

# Variables for the Samba Share
SHARE_DIR="/var/home/tolga/Aurora41"
USER="tolga"
GROUP="tolga"
SHARE_NAME="Aurora41"
SMB_CONF="/etc/samba/smb.conf"

# Ensure Samba is installed
if ! command -v smbd &> /dev/null; then
    echo "Samba is not installed. Installing..."
    sudo dnf install -y samba
fi

# Enable home directories for Samba
echo "Enabling home directories for Samba..."
sudo setsebool -P samba_enable_home_dirs on

# Configure permissions for the share
echo "Setting up permissions for $SHARE_DIR..."
sudo chown -R "$USER:$GROUP" "$SHARE_DIR"
sudo chmod -R 0775 "$SHARE_DIR"
sudo chcon -t samba_share_t "$SHARE_DIR"

# Add Samba share configuration to smb.conf
echo "Adding $SHARE_NAME share configuration to Samba..."
if ! grep -q "$SHARE_NAME" "$SMB_CONF"; then
    echo "[$SHARE_NAME]
    comment = Personal Drive(s)
    path = $SHARE_DIR
    read only = No
    browseable = Yes
    valid users = $USER
    create mask = 0775
    directory mask = 0775" | sudo tee -a "$SMB_CONF"
else
    echo "$SHARE_NAME already exists in $SMB_CONF"
fi

# Restart Samba services
echo "Restarting Samba service..."
sudo systemctl restart smbd

# Open necessary ports in the firewall
if command -v firewall-cmd &> /dev/null; then
    echo "Opening Samba ports in the firewall..."
    sudo firewall-cmd --add-service=samba --permanent
    sudo firewall-cmd --reload
else
    echo "Firewall not detected. Skipping port configuration."
fi

# Verify Samba service
echo "Verifying Samba service status..."
sudo systemctl status smbd

# Feedback
echo "Samba share '$SHARE_NAME' setup completed successfully."

