#!/bin/bash

# Tolga Erok
# My personal Fedora 39 KDE networking tweaker
# 18/11/2023

# Run from remote location:
# sudo bash -c "$(curl -fsSL https://raw.githubusercontent.com/tolgaerok/tolga-scripts/main/Fedora39/TolgaFedora39.sh)"

#  ¯\_(ツ)_/¯
#    █████▒▓█████ ▓█████▄  ▒█████   ██▀███   ▄▄▄
#  ▓██   ▒ ▓█   ▀ ▒██▀ ██▌▒██▒  ██▒▓██ ▒ ██▒▒████▄
#  ▒████ ░ ▒███   ░██   █▌▒██░  ██▒▓██ ░▄█ ▒▒██  ▀█▄
#  ░▓█▒  ░ ▒▓█  ▄ ░▓█▄   ▌▒██   ██░▒██▀▀█▄  ░██▄▄▄▄██
#  ░▒█░    ░▒████▒░▒████▓ ░ ████▓▒░░██▓ ▒██▒ ▓█   ▓██▒
#   ▒ ░    ░░ ▒░ ░ ▒▒▓  ▒ ░ ▒░▒░▒░ ░ ▒▓ ░▒▓░ ▒▒   ▓▒█░
#   ░       ░ ░  ░ ░ ▒  ▒   ░ ▒ ▒░   ░▒ ░ ▒░  ▒   ▒▒ ░
#   ░ ░       ░    ░ ░  ░ ░ ░ ░ ▒    ░░   ░   ░   ▒
#   ░  ░      ░    ░ ░     ░              ░  ░   ░

# https://github.com/massgravel/Microsoft-Activation-Scripts

clear

# Check if the script is run as root
if [ "$EUID" -ne 0 ]; then
	echo "Please run this script as root or using sudo."
	exit 1
fi

[ ${UID} -eq 0 ] && read -p "Username for this script: " user && export user || export user="$USER"

# Assign a color variable based on the RANDOM number
RED='\e[1;31m'
GREEN='\e[1;32m'
YELLOW='\e[1;33m'
BLUE='\e[1;34m'
CYAN='\e[1;36m'
WHITE='\e[1;37m'
ORANGE='\e[1;93m'
NC='\e[0m'
YELLOW='\e[1;33m'
NC='\e[0m'

echo '[charm]
name=Charm
baseurl=https://repo.charm.sh/yum/
enabled=1
gpgcheck=1
gpgkey=https://repo.charm.sh/yum/gpg.key' | sudo tee /etc/yum.repos.d/charm.repo

sudo yum install gum -y
clear

# Function to display messages
display_message() {
	clear
	echo -e "\n                  Tolga's Networking tweaks\n"
	echo -e "\e[34m|--------------------\e[33m Currently configuring:\e[34m-------------------|"
	echo -e "|${YELLOW}==>${NC}  $1"
	echo -e "\e[34m|--------------------------------------------------------------|\e[0m"
	echo ""
	gum spin --spinner dot --title "Stand-by..." -- sleep 1
}

# Function to check and display errors
check_error() {
	if [ $? -ne 0 ]; then
		display_message "[${RED}✘${NC}] Error occurred !!"
		# Print the error details
		echo "Error details: $1"
		gum spin --spinner dot --title "Stand-by..." -- sleep 8
	fi
}

# Template
# display_message "[${GREEN}✔${NC}]
# display_message "[${RED}✘${NC}]

install_apps() {
	display_message "[${GREEN}✔${NC}]  Installing afew personal apps..."

	sudo dnf -y up

	sudo dnf -y autoremove
	sudo dnf -y clean all

	# Essential Packages
	if [ -f /usr/bin/nala ]; then
		sudo nala install --assume-yes \
			flatpak neofetch nano htop zip un{zip,rar} tar ffmpeg ffmpegthumbnailer tumbler sassc \
			fonts-noto gtk2-engines-murrine gtk2-engines-pixbuf ntfs-3g wget curl git openssh-client \
			intel-media-va-driver i965-va-driver webext-ublock-origin-firefox

	elif [ -f /usr/bin/dnf ]; then
		sudo dnf install --assumeyes --best --allowerasing \
			flatpak neofetch nano htop zip un{zip,rar} tar ffmpeg ffmpegthumbnailer tumbler sassc \
			google-noto-{cjk,emoji-color}-fonts gtk-murrine-engine gtk2-engines ntfs-3g wget curl git openssh \
			libva-intel-driver intel-media-driver mozilla-ublock-origin easyeffects pulseeffects
	fi

	sudo dnf install -y PackageKit dconf-editor git libffi-devel lsd openssl-devel pip python3 python3-pip rygel sshpass fortune-mod
	sudo dnf install -y rsync openssh-server openssh-clients wsdd wget xclip zstd fd-find fzf gtk3
	# NOT SURE ABOUT THIS sudo dnf install -y sshfs fuse-sshfs

	sudo dnf install --assumeyes --best --allowerasing \
		flatpak neofetch nano htop zip un{zip,rar} tar ffmpeg ffmpegthumbnailer tumbler sassc \
		google-noto-{cjk,emoji-color}-fonts gtk-murrine-engine gtk2-engines ntfs-3g wget curl git openssh \
		libva-intel-driver intel-media-driver mozilla-ublock-origin easyeffects pulseeffects

	# Execute rygel to start DLNA sharing
	/usr/bin/rygel-preferences

	## Networking packages
	sudo dnf -y install iptables iptables-services nftables

	## System utilities
	sudo dnf -y install bash-completion busybox crontabs ca-certificates curl dnf-plugins-core dnf-utils gnupg2 nano screen ufw unzip vim wget zip

	## Programming and development tools
	sudo dnf -y install autoconf automake bash-completion git libtool make pkg-config python3 python3-pip

	## Additional libraries and dependencies
	sudo dnf -y install bc binutils haveged jq libsodium libsodium-devel PackageKit qrencode socat

	## Miscellaneous
	sudo dnf -y install dialog htop net-tools

	## Make a backup of the original sysctl.conf file
	display_message "[${GREEN}✔${NC}]  Tweaking network settings"

	cp $SYS_PATH /etc/sysctl.conf.bak

	echo
	yellow_msg 'Default sysctl.conf file Saved. Directory: /etc/sysctl.conf.bak'
	echo
	gum spin --spinner dot --title "Stand-by..." -- sleep 1

	echo
	yellow_msg 'Optimizing the Network...'
	echo
	gum spin --spinner dot --title "tweaking network" -- sleep 3

	sed -i -e '/fs.file-max/d' \
		-e '/net.core.default_qdisc/d' \
		-e '/net.core.netdev_max_backlog/d' \
		-e '/net.core.optmem_max/d' \
		-e '/net.core.somaxconn/d' \
		-e '/net.core.rmem_max/d' \
		-e '/net.core.wmem_max/d' \
		-e '/net.core.rmem_default/d' \
		-e '/net.core.wmem_default/d' \
		-e '/net.ipv4.tcp_rmem/d' \
		-e '/net.ipv4.tcp_wmem/d' \
		-e '/net.ipv4.tcp_congestion_control/d' \
		-e '/net.ipv4.tcp_fastopen/d' \
		-e '/net.ipv4.tcp_fin_timeout/d' \
		-e '/net.ipv4.tcp_keepalive_time/d' \
		-e '/net.ipv4.tcp_keepalive_probes/d' \
		-e '/net.ipv4.tcp_keepalive_intvl/d' \
		-e '/net.ipv4.tcp_max_orphans/d' \
		-e '/net.ipv4.tcp_max_syn_backlog/d' \
		-e '/net.ipv4.tcp_max_tw_buckets/d' \
		-e '/net.ipv4.tcp_mem/d' \
		-e '/net.ipv4.tcp_mtu_probing/d' \
		-e '/net.ipv4.tcp_notsent_lowat/d' \
		-e '/net.ipv4.tcp_retries2/d' \
		-e '/net.ipv4.tcp_sack/d' \
		-e '/net.ipv4.tcp_dsack/d' \
		-e '/net.ipv4.tcp_slow_start_after_idle/d' \
		-e '/net.ipv4.tcp_window_scaling/d' \
		-e '/net.ipv4.tcp_ecn/d' \
		-e '/net.ipv4.ip_forward/d' \
		-e '/net.ipv4.udp_mem/d' \
		-e '/net.ipv6.conf.all.disable_ipv6/d' \
		-e '/net.ipv6.conf.all.forwarding/d' \
		-e '/net.ipv6.conf.default.disable_ipv6/d' \
		-e '/net.unix.max_dgram_qlen/d' \
		-e '/vm.min_free_kbytes/d' \
		-e '/vm.swappiness/d' \
		-e '/vm.vfs_cache_pressure/d' \
		"$SYS_PATH"

	display_message "[${GREEN}✔${NC}]  Previous settings deleted"
	gum spin --spinner dot --title "Re-accessing, stanby" -- sleep 2

	## Add new parameteres. Read More: https://github.com/hawshemi/Linux-Optimizer/blob/main/files/sysctl.conf

	cat <<EOF >>"$SYS_PATH"
# System Reload Command
# --------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# Command to reload system configurations:
# --------------------------------------------------------------------------------------------------------------------------------------------------------------------------

# alias tolga-sysctl-reload="sudo udevadm control --reload-rules && sudo udevadm trigger && sudo sysctl --system && sysctl -p"

# About These Settings
# --------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# These configurations aim to optimize various aspects of the Linux system, including network performance, file systems, and kernel behavior. The tweaks are inspired by configurations from RHEL,
# Fedora, Solus, Mint, and Windows Server. Adjustments have been made based on personal experimentation and preferences.
# Keep in mind that before applying these tweaks, it's recommended to test in a controlled environment and monitor system behavior.
#
# Tolga Erok

# Linux System Optimization
# --------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# Network
# --------------------------------------------------------------------------------------------------------------------------------------------------------------------------

#-net.ipv4.conf.all.rp_filter = 0                          # Disable source route verification for all interfaces
#-vm.unprivileged_userfaultfd = 1                          # Enable unprivileged userfaultfd
fs.aio-max-nr = 1048576                                   # Defines the maximum number of asynchronous I/O requests that can be in progress at a given time.
fs.file-max = 67108864                                    # Maximum number of file handles the kernel can allocate. Default: 67108864
fs.inotify.max_user_watches = 524288                      # Sets the maximum number of file system watches, enhancing file system monitoring capabilities. Default: 8192, Tweaked: 524288
fs.suid_dumpable=2                                        # Set SUID_DUMPABLE flag. 0 means not core dump, 1 means core dump, and 2 means core dump with setuid
kernel.core_pattern=|/usr/lib/systemd/systemd-coredump %P %u %g %s %t %c %h
kernel.core_uses_pid = 1                                  # Append the PID to the core filename
kernel.nmi_watchdog = 0                                   # Disable NMI watchdog
kernel.panic = 5                                          # Reboot after 5 seconds on kernel panic. Default: 0
kernel.pid_max = 4194304                                  # Allows a large number of processes and threads to be managed. Default: 32768, Tweaked: 4194304
kernel.pty.max = 24000                                    # Maximum number of pseudo-terminals (PTYs) in the system
kernel.sched_autogroup_enabled = 0                        # Disable automatic task grouping for better server performance
kernel.sysrq = 1                                          # Enable SysRQ for rebooting the machine properly if it freezes. [Source](https://oglo.dev/tutorials/sysrq/index.html)
kernel.unprivileged_bpf_disabled = 1                      # Disable unprivileged BPF
net.core.default_qdisc = fq_codel
net.core.netdev_max_backlog = 32768                       # Maximum length of the input queue of a network device
net.core.optmem_max = 65536                               # Maximum ancillary buffer size allowed per socket
net.core.rmem_default = 1048576                           # Default socket receive buffer size
net.core.rmem_max = 16777216                              # Maximum socket receive buffer size
net.core.somaxconn = 65536                                # Maximum listen queue backlog
net.core.wmem_default = 1048576                           # Default socket send buffer size
net.core.wmem_max = 16777216                              # Maximum socket send buffer size

# --------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# IPv4 Network Configuration
# --------------------------------------------------------------------------------------------------------------------------------------------------------------------------

net.ipv4.conf.*.promote_secondaries = 1                   # Promote secondary addresses when the primary address is removed
net.ipv4.conf.*.rp_filter = 2                             # Enable source route verification
net.ipv4.conf.all.secure_redirects = 0                    # Disable acceptance of secure ICMP redirected packets
net.ipv4.conf.all.send_redirects = 0                      # Disable sending of all IPv4 ICMP redirected packets
net.ipv4.conf.default.accept_redirects = 0                # Disable acceptance of all ICMP redirected packets (default)
net.ipv4.conf.default.promote_secondaries = 1             # Promote secondary addresses when the primary address is removed
net.ipv4.conf.default.rp_filter = 2                       # Enable source route verification
net.ipv4.conf.default.secure_redirects = 0                # Disable acceptance of secure ICMP redirected packets (default)
net.ipv4.conf.default.send_redirects = 0                  # Disable sending of all IPv4 ICMP redirected packets (default)
net.ipv4.ip_forward = 1                                   # Enable IP forwarding
net.ipv4.tcp_congestion_control = westwood
net.ipv4.tcp_dsack = 1                                    # Enable Delayed SACK
net.ipv4.tcp_ecn = 1                                      # Enable Explicit Congestion Notification (ECN)
net.ipv4.tcp_fastopen = 3                                 # Enable TCP Fast Open with a queue of 3
net.ipv4.tcp_fin_timeout = 25                             # Time to hold socket in FIN-WAIT-2 state (seconds)
net.ipv4.tcp_keepalive_intvl = 30                         # Time between individual TCP keepalive probes (seconds)
net.ipv4.tcp_keepalive_probes = 5                         # Number of TCP keepalive probes
net.ipv4.tcp_keepalive_time = 300                         # Time before sending TCP keepalive probes (seconds)
net.ipv4.tcp_max_orphans = 819200                         # Maximum number of TCP sockets not attached to any user file handle
net.ipv4.tcp_max_syn_backlog = 20480                      # Maximum length of the listen queue for accepting new TCP connections
net.ipv4.tcp_max_tw_buckets = 1440000                     # Maximum number of TIME-WAIT sockets
net.ipv4.tcp_mem = 65536 1048576 16777216                 # TCP memory allocation limits
net.ipv4.tcp_mtu_probing = 1                              # Enable Path MTU Discovery
net.ipv4.tcp_notsent_lowat = 16384                        # Minimum amount of data in the send queue below which TCP will send more data
net.ipv4.tcp_retries2 = 8                                 # Number of times TCP retransmits unacknowledged data segments for the second SYN on a connection initiation
net.ipv4.tcp_rmem = 8192 1048576 16777216                 # TCP read memory allocation for network sockets
net.ipv4.tcp_sack = 1                                     # Enable Selective Acknowledgment (SACK)
net.ipv4.tcp_slow_start_after_idle = 0                    # Disable TCP slow start after idle
net.ipv4.tcp_window_scaling = 1                           # Enable TCP window scaling
net.ipv4.tcp_wmem = 8192 1048576 16777216                 # TCP write memory allocation for network sockets
net.ipv4.udp_mem = 65536 1048576 16777216                 # UDP memory allocation limits

# --------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# IPv6 Network Configuration
# --------------------------------------------------------------------------------------------------------------------------------------------------------------------------

net.ipv6.conf.all.accept_redirects = 0                    # Disable acceptance of all ICMP redirected packets for IPv6
net.ipv6.conf.all.disable_ipv6 = 0                        # Enable IPv6
net.ipv6.conf.all.forwarding = 1                          # Enable IPv6 packet forwarding
net.ipv6.conf.default.accept_redirects = 0                # Disable acceptance of all ICMP redirected packets for IPv6 (default)
net.ipv6.conf.default.disable_ipv6 = 0                    # Enable IPv6

# --------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# UNIX Domain Socket
# --------------------------------------------------------------------------------------------------------------------------------------------------------------------------

net.unix.max_dgram_qlen = 50                              # Maximum length of the UNIX domain socket datagram queue

# --------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# Virtual Memory Management
# --------------------------------------------------------------------------------------------------------------------------------------------------------------------------

vm.dirty_background_bytes = 474217728                     # Set dirty background bytes for optimized performance (adjusted for SSD).
vm.dirty_background_ratio = 5                             # Percentage of system memory at which background writeback starts
vm.dirty_bytes = 742653184                                # Set dirty bytes for optimized performance (adjusted for SSD).
vm.dirty_expire_centisecs = 3000                          # Set the time at which dirty data is old enough to be eligible for writeout (6000 centiseconds). Adjusted for SSD.
vm.dirty_ratio = 80                                       # Set the ratio of dirty memory at which a process is forced to write out dirty data (10%). Adjusted for SSD.
vm.dirty_writeback_centisecs = 300                        # Set the interval between two consecutive background writeback passes (500 centiseconds).
vm.extfrag_threshold = 100                                # Fragmentation threshold for the kernel
vm.max_map_count=2147483642                               # Define the maximum number of memory map areas a process may have
vm.min_free_kbytes = 65536                                # Minimum free kilobytes
vm.mmap_min_addr = 65536                                  # Minimum address allowed for a user-space mmap
vm.page-cluster = 0                                       # Disable page clustering for filesystems
vm.swappiness = 10                                        # Swappiness parameter (tendency to swap out unused pages)
vm.vfs_cache_pressure = 50                                # Controls the tendency of the kernel to reclaim the memory used for caching of directory and inode objects
fs.file-max = 67108864                                    # Maximum number of file handles the kernel can allocate (Default: 67108864)
EOF

	# To Do For NVME ssd
	#block.sd*/queue/nr_requests=4096
	#block.sd*/queue/scheduler=bfq
	#block.sd*/queue/nr_requests=4096
	#block.sd*/queue/read_ahead_kb=1024
	#block.sd*/queue/add_random=1
	#block.nvme*/queue/scheduler=mq-deadline
	#block.nvme*/queue/scheduler=bfq
	#3block.nvme*/queue/iosched/low_latency=0
	#block.nvme*/queue/iosched/low_latency=1
	#block.nvme*/queue/nr_requests=2048
	#block.nvme*/queue/read_ahead_kb=1024
	#block.nvme*/queue/add_random=1
	#kernel.nmi_watchdog=0
	#block.{sd,mmc,nvme,0}*/queue/iosched/slice_idle=0

	display_message "[${GREEN}✔${NC}]  Adding New network settings"

	sudo systemctl restart systemd-sysctl

	echo ""
	gum spin --spinner dot --title "Restarting systemd custom settings.." -- sleep 4

	echo
	green_msg 'Network is Optimized.'
	echo
	gum spin --spinner dot --title "Starting SSH..." -- sleep 3

	# Start and enable SSH
	sudo systemctl start sshd
	sudo systemctl enable sshd
	display_message "[${GREEN}✔${NC}]  Checking SSh port"
	gum spin --spinner dot --title "Stand-by..." -- sleep 2	

	# Use the KDE Wallet to store ssh key passphrases
	# https://wiki.archlinux.org/title/KDE_Wallet#Using_the_KDE_Wallet_to_store_ssh_key_passphrases
	tee ${HOME}/.config/autostart/ssh-add.desktop <<EOF
[Desktop Entry]
Exec=ssh-add -q
Name=ssh-add
Type=Application
EOF

	tee ${HOME}/.config/environment.d/ssh_askpass.conf <<EOF
SSH_ASKPASS='/usr/bin/ksshaskpass'
GIT_ASKPASS=ksshaskpass
SSH_ASKPASS=ksshaskpass
SSH_ASKPASS_REQUIRE=prefer
EOF	

display_message "[${GREEN}✔${NC}] Networking rules applied successfully, reloading system services."
gum spin --spinner dot --title "Reloading all services" -- sleep 1.5

# Apply sysctl changes
sudo udevadm control --reload-rules
sudo udevadm trigger
sudo sysctl --system
sudo sysctl -p
