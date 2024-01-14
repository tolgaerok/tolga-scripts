#!/bin/bash

# Tolga Erok
# My personal Fedora 39 KDE tweaker
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
	echo -e "\n                  Tolga's SAMBA & WSDD setup script\n"
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

function remove_libreoffice() {
	echo ""
	read -p "Do you want to remove LibreOffice and its core components? (y/n): " answer

	if [ "$answer" != "y" ]; then
		echo "Aborted by user."
		return 1
	fi

	# Remove LibreOffice
	sudo dnf group remove libreoffice -y

	# Remove LibreOffice core
	sudo dnf remove libreoffice-core -y

	echo "LibreOffice and its core components have been removed."
	return 0
}

install_apps() {
	display_message "[${GREEN}✔${NC}]  Installing afew personal apps..."

	remove_libreoffice

	sudo dnf -y up
	sudo dnf -y autoremove
	sudo dnf -y clean all

	# Install Apps
	sudo dnf install rpmfusion-free-release-tainted
	sudo dnf install rpmfusion-nonfree-release-tainted
	sudo dnf --repo=rpmfusion-nonfree-tainted install "*-firmware"

	# Incase removed by libreoffice purge
	packages=(
		cjson-1.7.15-2.fc39.x86_64
		codec2-1.2.0-2.fc39.x86_64
		dbus-glib-0.112-6.fc39.x86_64
		gtk2-immodule-xim-2.24.33-15.fc39.x86_64
		gtk3-immodule-xim-3.24.39-1.fc39.x86_64
		ibus-gtk4-1.5.29~rc2-6.fc39.x86_64
		libXext-1.3.5-3.fc39.i686
		libfreeaptx-0.1.1-5.fc39.x86_64
		libgcab1-1.6-2.fc39.x86_64
		librabbitmq-0.13.0-3.fc39.x86_64
		librist-0.2.7-2.fc39.x86_64
		libvdpau-1.5-4.fc39.i686
		llvm16-libs-16.0.6-5.fc39.x86_64
		lpcnetfreedv-0.5-3.fc39.x86_64
		mbedtls-2.28.5-1.fc39.x86_64
		ostree-2023.8-2.fc39.x86_64
		pipewire-codec-aptx-1.0.0-1.fc39.x86_64
		xorg-x11-fonts-ISO8859-1-100dpi-7.5-36.fc39.noarch
	)

	for package in "${packages[@]}"; do
		sudo dnf install "$package" -y
	done

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

	# Audio
	[ -f /usr/bin/easyeffects ] && [ -f $HOME/.config/easyeffects/output/default.json ] && easyeffects -l default
	[ -f /usr/bin/pulseeffects ] && [ -f $HOME/.config/PulseEffects/output/default.json ] && pulseeffects -l default

	sudo dnf install -y PackageKit dconf-editor digikam direnv duf earlyoom espeak ffmpeg-libs figlet gedit gimp gimp-devel git gnome-font-viewer
	sudo dnf install -y grub-customizer kate libdvdcss libffi-devel lsd mpg123 neofetch openssl-devel p7zip p7zip-plugins pip python3 python3-pip
	sudo dnf install -y rhythmbox rygel shotwell sshpass sxiv timeshift unrar unzip cowsay fortune-mod

	# NOT SURE ABOUT THIS sudo dnf install -y sshfs fuse-sshfs

	sudo dnf install -y rsync openssh-server openssh-clients wsdd
	sudo dnf install -y variety virt-manager wget xclip zstd fd-find fzf gtk3 rygel
	sudo dnf install dnf5 dnf5-plugins

	# Configure fortune
	# If you want to display a specific fortune file or category, you can use the -e option followed by the file or category name. For example:
	# fortune -e art ascii-art bofh-excuses computers cookie definitions disclaimer drugs education fortunes humorists kernelnewbies knghtbrd law linux literature miscellaneous news people riddles science
	# or to see a list:
	# fortune -f

	sudo dnf install --assumeyes --best --allowerasing \
		flatpak neofetch nano htop zip un{zip,rar} tar ffmpeg ffmpegthumbnailer tumbler sassc \
		google-noto-{cjk,emoji-color}-fonts gtk-murrine-engine gtk2-engines ntfs-3g wget curl git openssh \
		libva-intel-driver intel-media-driver mozilla-ublock-origin easyeffects pulseeffects

	sudo dnf install -y 'google-roboto*' 'mozilla-fira*' fira-code-fonts

	# Execute rygel to start DLNA sharing
	/usr/bin/rygel-preferences

	# Install profile-sync: it to manage browser profile(s) in tmpfs and to periodically sync back to the physical disc (HDD/SSD)
	sudo dnf install profile-sync-daemon
	/usr/bin/profile-sync-daemon preview
	# sudo dnf remove profile-sync-daemon
	# psd profile located in $HOME/.config/psd/psd.conf

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

	sudo dnf swap -y libavcodec-free libavcodec-freeworld --allowerasing
	sudo dnf swap -y ffmpeg-free ffmpeg --allowerasing

	display_message "[${GREEN}✔${NC}]  Installing GUM"

	echo '[charm]
name=Charm
baseurl=https://repo.charm.sh/yum/
enabled=1
gpgcheck=1
gpgkey=https://repo.charm.sh/yum/gpg.key' | sudo tee /etc/yum.repos.d/charm.repo
	sudo yum install gum -y

	gum spin --spinner dot --title "GUM installed" -- sleep 2

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

	# Apply sysctl changes
	sudo udevadm control --reload-rules
	sudo udevadm trigger
	sudo sysctl --system
	sudo sysctl -p

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
	check_port22
	# sudo systemctl status sshd

	display_message "[${GREEN}✔${NC}]  Setup Web Service Discovery host daemon"

	echo ""
	echo "wsdd implements a Web Service Discovery host daemon. This enables (Samba) hosts, like your local NAS device, to be found by Web Service Discovery Clients like Windows."
	echo "It also implements the client side of the discovery protocol which allows to search for Windows machines and other devices implementing WSD. This mode of operation is called discovery mode."
	echo""

	gum spin --spinner dot --title " Standby, traffic for the following ports, directions and addresses must be allowed" -- sleep 2

	sudo firewall-cmd --add-rich-rule='rule family="ipv4" source address="239.255.255.250" port protocol="udp" port="3702" accept'
	sudo firewall-cmd --add-rich-rule='rule family="ipv6" source address="ff02::c" port protocol="udp" port="3702" accept'
	sudo firewall-cmd --add-rich-rule='rule family="ipv4" port protocol="udp" port="3702" accept'
	sudo firewall-cmd --add-rich-rule='rule family="ipv6" port protocol="udp" port="3702" accept'
	sudo firewall-cmd --add-rich-rule='rule family="ipv4" port protocol="tcp" port="5357" accept'
	sudo firewall-cmd --add-rich-rule='rule family="ipv6" port protocol="tcp" port="5357" accept'

	# Define the path to the wsdd service file
	SERVICE_FILE="/usr/lib/systemd/system/wsdd.service"

	# Define the path to the old sysconfig file
	OLD_SYSCONFIG_FILE="/etc/default/wsdd"

	# Define the path to the new sysconfig file
	NEW_SYSCONFIG_FILE="/etc/sysconfig/wsdd"

	# Check if EnvironmentFile line with old path exists in the service file
	if grep -q "EnvironmentFile=$OLD_SYSCONFIG_FILE" "$SERVICE_FILE"; then
		# Comment out the old EnvironmentFile line
		sudo sed -i "s|EnvironmentFile=$OLD_SYSCONFIG_FILE|#&|" "$SERVICE_FILE"

		# Add the new EnvironmentFile line directly under the commented old line
		sudo sed -i "\|#EnvironmentFile=$OLD_SYSCONFIG_FILE|a EnvironmentFile=$NEW_SYSCONFIG_FILE" "$SERVICE_FILE"
		gum spin --spinner dot --title " Standby, editind WSDD config" -- sleep 2

		# Reload systemd to apply changes
		sudo systemctl daemon-reload

		# Restart the wsdd service

		gum spin --spinner dot --title " Standby, restarting , reloading and getting wsdd status" -- sleep 2
		sudo systemctl enable wsdd.service
		sudo systemctl restart wsdd.service
		display_message "[${GREEN}✔${NC}]  WSDD setup complete"
		# systemctl status wsdd.service

		sleep 1

		echo "EnvironmentFile updated to $NEW_SYSCONFIG_FILE and service restarted."
		sleep 2
	else
		# Check if EnvironmentFile line with new path exists
		if grep -q "EnvironmentFile=$NEW_SYSCONFIG_FILE" "$SERVICE_FILE"; then
			echo "No changes needed. EnvironmentFile is already updated."
		else
			# Add the new EnvironmentFile line at the end of the [Service] section
			echo -e "\nEnvironmentFile=$NEW_SYSCONFIG_FILE" | sudo tee -a "$SERVICE_FILE" >/dev/null
			gum spin --spinner dot --title " Standby, editind WSDD config" -- sleep 2

			# Reload systemd to apply changes
			sudo systemctl daemon-reload

			# Restart the wsdd service
			gum spin --spinner dot --title " Standby, restarting , reloading and getting wsdd status" -- sleep 2
			sudo systemctl enable wsdd.service
			sudo systemctl restart wsdd.service
			display_message "[${GREEN}✔${NC}]  WSDD setup complete"
			# systemctl status wsdd.service

			sleep 1

			echo "EnvironmentFile added with path $NEW_SYSCONFIG_FILE and service restarted."
			sleep 2
		fi
	fi

	gum spin --spinner dot --title "Standby.." -- sleep 1

	display_message "[${GREEN}✔${NC}]  Setup KDE Wallet"
	gum spin --spinner dot --title "Standby.." -- sleep 1
	# Install Plasma related packages
	sudo dnf install -y \
		ksshaskpass

	mkdir -p ${HOME}/.config/autostart/
	mkdir -p ${HOME}/.config/environment.d/

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

	display_message "[${GREEN}✔${NC}]  Install vitualization group and set permissions"
	gum spin --spinner dot --title "Standby.." -- sleep 1
	# Install virtualization group
	sudo dnf install -y @virtualization

	# Enable libvirtd service
	sudo systemctl enable libvirtd

	# Add user to libvirt group
	sudo usermod -a -G libvirt ${USER}

	# Start earlyloom services
	display_message "[${GREEN}✔${NC}]  Starting earlyloom services"
	sudo systemctl start earlyoom
	sudo systemctl enable --now earlyoom
	echo ""
	gum spin --spinner dot --title "Restarting Earlyloom.." -- sleep 2.5
	display_message "[${GREEN}✔${NC}]  Checking earlyloom status service"

	# Check EarlyOOM status
	earlyoom_status=$(systemctl status earlyoom | cat)

	# Check if EarlyOOM is active and enabled
	if is_service_active earlyoom; then
		active_status="Active"
	else
		active_status="Inactive"
	fi

	if is_service_enabled earlyoom; then
		enabled_status=$(print_yellow "Enabled")
	else
		enabled_status="Disabled"
	fi

	# Get memory information
	mem_total=$(grep MemTotal /proc/meminfo | awk '{print $2}')
	swap_total=$(grep SwapTotal /proc/meminfo | awk '{print $2}')

	# Display information
	echo -e "EarlyOOM Status: $active_status"
	echo -e "Service Enablement: $enabled_status"
	echo -e "Total Memory: $mem_total KB"
	echo -e "Total Swap: $swap_total KB\n\n"
	gum spin --spinner dot --title "Standby.." -- sleep 1
	sudo journalctl -u earlyoom | grep sending
	gum spin --spinner dot --title "Standby.." -- sleep 3

	# Install fedora preload
	display_message "[${GREEN}✔${NC}]  Install fedora preload"
	sudo dnf copr enable atim/preload -y && sudo dnf install preload -y
	display_message "[${GREEN}✔${NC}]  Enable fedora preload service"
	sudo systemctl enable --now preload.service
	gum spin --spinner dot --title "Standby.." -- sleep 1.5

	# Install some fonts
	display_message "[${GREEN}✔${NC}]  Installing some fonts"
	sudo dnf install -y fontawesome-fonts powerline-fonts
	sudo mkdir -p ~/.local/share/fonts
	cd ~/.local/share/fonts && curl -fLO https://github.com/ryanoasis/nerd-fonts/raw/HEAD/patched-fonts/DroidSansMono/DroidSansMNerdFont-Regular.otf
	wget https://github.com/tolgaerok/fonts-tolga/raw/main/WPS-FONTS.zip
	unzip WPS-FONTS.zip -d /usr/share/fonts

	zip_file="Apple-Fonts-San-Francisco-New-York-master.zip"

	# Check if the ZIP file exists
	if [ -f "$zip_file" ]; then
		# Remove existing ZIP file
		sudo rm -f "$zip_file"
		echo "Existing ZIP file removed."
	fi

	# Download the ZIP file
	curl -LJO https://github.com/tolgaerok/Apple-Fonts-San-Francisco-New-York/archive/refs/heads/master.zip

	# Check if the download was successful
	if [ -f "$zip_file" ]; then
		# Unzip the contents to the system-wide fonts directory
		sudo unzip -o "$zip_file" -d /usr/share/fonts/

		# Update font cache
		sudo fc-cache -f -v

		# Remove the ZIP file
		rm "$zip_file"

		display_message "[${GREEN}✔${NC}] Apple fonts installed successfully."
		echo ""
		gum spin --spinner dot --title "Re-thinking... 1 sec" -- sleep 2
	else
		display_message "[${RED}✘${NC}] Download failed. Please check the URL and try again."
		gum spin --spinner dot --title "Stand-by..." -- sleep 2
	fi

	# Reloading Font
	sudo fc-cache -vf

	# Removing zip Files
	rm ./WPS-FONTS.zip
	sudo fc-cache -f -v

	sudo dnf install fontconfig-font-replacements -y --skip-broken && sudo dnf install fontconfig-enhanced-defaults -y --skip-broken

	sudo bash -c "$(curl -fsSL https://raw.githubusercontent.com/tolgaerok/tolga-scripts/main/Fedora39/San-Francisco-family/San-Francisco-family.sh)"

	# Install OpenRGB.
	display_message "[${GREEN}✔${NC}]  Installing OpenRGB"
	sudo modprobe i2c-dev && sudo modprobe i2c-piix4 && sudo dnf install openrgb -y

	# Install Docker
	display_message "[${GREEN}✔${NC}]  Installing Docker..this takes awhile"
	echo ""
	gum spin --spinner dot --title "If this is the first time installing docker, it usually takes VERY long" -- sleep 2
	sudo dnf install docker -y

	# Install Btrfs
	display_message "[${GREEN}✔${NC}]  Installing btrfs assistant.."
	package_url="https://kojipkgs.fedoraproject.org//packages/btrfs-assistant/1.8/2.fc39/x86_64/btrfs-assistant-1.8-2.fc39.x86_64.rpm"
	package_name=$(echo "$package_url" | awk -F'/' '{print $NF}')

	# Check if the package is installed
	if rpm -q "$package_name" >/dev/null; then
		display_message "[${RED}✘${NC}] $package_name is already installed."
		gum spin --spinner dot --title "Standby.." -- sleep 1
	else
		# Package is not installed, so proceed with the installation
		display_message "[${GREEN}✔${NC}]  $package_name is not installed. Installing..."
		sudo dnf install -y "$package_url"
		if [ $? -eq 0 ]; then
			display_message "[${GREEN}✔${NC}]  $package_name has been successfully installed."
			gum spin --spinner dot --title "Standby.." -- sleep 1
		else
			display_message "[${RED}✘${NC}] Failed to install $package_name."
			gum spin --spinner dot --title "Standby.." -- sleep 1
		fi
	fi

	# Install google
	display_message "[${GREEN}✔${NC}]  Installing Google chrome"
	if command -v google-chrome &>/dev/null; then
		display_message "[${RED}✘${NC}] Google Chrome is already installed. Skipping installation."
		gum spin --spinner dot --title "Standby.." -- sleep 1
	else
		# Install Google Chrome
		display_message "[${GREEN}✔${NC}]  Installing Google Chrome browser..."
		wget https://dl.google.com/linux/direct/google-chrome-stable_current_x86_64.rpm
		sudo dnf install -y ./google-chrome-stable_current_x86_64.rpm
		rm -f google-chrome-stable_current_x86_64.rpm
	fi

	# Download and install TeamViewer
	display_message "[${GREEN}✔${NC}]  Downloading && install TeamViewer"
	teamviewer_url="https://download.teamviewer.com/download/linux/teamviewer.x86_64.rpm?utm_source=google&utm_medium=cpc&utm_campaign=au%7Cb%7Cpr%7C22%7Cjun%7Ctv-core-download-sn%7Cfree%7Ct0%7C0&utm_content=Download&utm_term=teamviewer+download"
	teamviewer_location="/tmp/teamviewer.x86_64.rpm"
	download_and_install "$teamviewer_url" "$teamviewer_location" "teamviewer"

	# Download and install Visual Studio Code
	display_message "[${GREEN}✔${NC}]  Downloading && install Vscode"
	vscode_url="https://code.visualstudio.com/sha/download?build=stable&os=linux-rpm-x64"
	vscode_location="/tmp/vscode.rpm"
	download_and_install "$vscode_url" "$vscode_location" "code"

	# Install extra package
	display_message "[${GREEN}✔${NC}]  Installing Extra RPM packages"
	sudo dnf groupupdate -y sound-and-video
	sudo dnf group upgrade -y --with-optional Multimedia
	sudo dnf groupupdate -y sound-and-video --allowerasing --skip-broken
	sudo dnf groupupdate multimedia sound-and-video

	# Cleanup
	display_message "[${GREEN}✔${NC}]  Cleaning up downloaded /tmp folder"
	rm "$download_location"

	display_message "[${GREEN}✔${NC}]  Installing SAMBA and dependencies"

	# Install Samba and its dependencies
	sudo dnf install samba samba-client samba-common cifs-utils samba-usershares -y

	# Enable and start SMB and NMB services
	display_message "[${GREEN}✔${NC}]  SMB && NMB services started"
	sudo systemctl enable smb.service nmb.service
	sudo systemctl start smb.service nmb.service

	# Restart SMB and NMB services (optional)
	sudo systemctl restart smb.service nmb.service

	# Configure the firewall
	display_message "[${GREEN}✔${NC}]  Firewall Configured"
	sudo firewall-cmd --add-service=samba --permanent
	sudo firewall-cmd --add-service=samba
	sudo firewall-cmd --runtime-to-permanent
	sudo firewall-cmd --reload

	# Set SELinux booleans
	display_message "[${GREEN}✔${NC}]  SELINUX parameters set "
	sudo setsebool -P samba_enable_home_dirs on
	sudo setsebool -P samba_export_all_rw on
	sudo setsebool -P smbd_anon_write 1

	# Create samba user/group
	display_message "[${GREEN}✔${NC}]  Create smb user and group"
	read -r -p "Set-up samba user & group's
" -t 2 -n 1 -s

	# Prompt for the desired username for samba
	read -p $'\n'"Enter the USERNAME to add to Samba: " sambausername

	# Prompt for the desired name for samba
	read -p $'\n'"Enter the GROUP name to add username to Samba: " sambagroup

	# Add the custom group
	sudo groupadd $sambagroup

	# ensures that a home directory is created for the user
	sudo useradd -m $sambausername

	# Add the user to the Samba user database
	sudo smbpasswd -a $sambausername

	# enable or activate the Samba user account for login
	sudo smbpasswd -e $sambausername

	# Add the user to the specified group
	sudo usermod -aG $sambagroup $sambausername

	read -r -p "
Continuing..." -t 1 -n 1 -s

	# Configure custom samba folder
	read -r -p "Create and configure custom samba folder located at /home/fedora39
" -t 2 -n 1 -s

	sudo mkdir /home/fedora39
	sudo chgrp samba /home/fedora39
	sudo chmod 770 /home/fedora39
	sudo restorecon -R /home/fedora39

	# Create the sambashares group if it doesn't exist
	sudo groupadd -r sambashares

	# Create the usershares directory and set permissions
	sudo mkdir -p /var/lib/samba/usershares
	sudo chown $username:sambashares /var/lib/samba/usershares
	sudo chmod 1770 /var/lib/samba/usershares

	# Restore SELinux context for the usershares directory
	display_message "[${GREEN}✔${NC}]  Restore SELinux for usershares folder"
	sudo restorecon -R /var/lib/samba/usershares

	# Add the user to the sambashares group
	display_message "[${GREEN}✔${NC}]  Adding user to usershares"
	sudo gpasswd sambashares -a $username

	# Add the user to the sambashares group (alternative method)
	sudo usermod -aG sambashares $username

	# Restart SMB and NMB services (optional)
	display_message "[${GREEN}✔${NC}]  Restart SMB && NMB (samba) services"
	sudo systemctl restart smb.service nmb.service

	# Set up SSH Server on Host
	display_message "[${GREEN}✔${NC}]  Setup SSH and start service.."
	sudo systemctl enable sshd && sudo systemctl start sshd

	display_message "[${GREEN}✔${NC}]  Installation completed."
	gum spin --spinner dot --title "Standby.." -- sleep 3

	# Check for errors during installation
	if [ $? -eq 0 ]; then
		display_message "Apps installed successfully."
		gum spin --spinner dot --title "Standby.." -- sleep 2
	else
		display_message "[${RED}✘${NC}] Error: Unable to install Apps."
		gum spin --spinner dot --title "Standby.." -- sleep 2
	fi
}

# Template
# display_message "[${GREEN}✔${NC}]
# display_message "[${RED}✘${NC}]

# Reload the firewall for changes to take effect
sudo firewall-cmd --reload
gum spin --spinner dot --title "Reloading firewall" -- sleep 1.5

display_message "[${GREEN}✔${NC}] Firewall rules applied successfully, reloading system services."
gum spin --spinner dot --title "Reloading all services" -- sleep 1.5

# Start Samba manually
sudo systemctl start smb

# Configure Samba to start automatically on each boot and immediately start the service
sudo systemctl enable --now smb

# Check whether Samba is running
sudo systemctl status smb

# Restart Samba manually
sudo systemctl restart smb

# Start wsdd manually (depends on the smb service)
sudo systemctl start wsdd

# Configure wsdd to start automatically on each boot and immediately start the service
sudo systemctl enable --now wsdd

# Check whether wsdd is running
sudo systemctl status wsdd

# Restart wsdd and Samba
sudo systemctl restart wsdd smb

# Apply sysctl changes
sudo udevadm control --reload-rules
sudo udevadm trigger
sudo sysctl --system
sudo sysctl -p
