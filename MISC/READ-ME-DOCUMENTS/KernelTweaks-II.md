# Kernel Tweaks II

Tolga Erok

31/12/2023

```bash
## Make a backup of the original sysctl.conf file
display_message "[${GREEN}✔${NC}]  Tweaking network settings"
```
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
 
```bash 
# --------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#   Old Nixos Tweaks, to suit (28GB system)
# --------------------------------------------------------------------------------------------------------------------------------------------------------------------------
kernel.sysrq = 1                         # Enable SysRQ for rebooting the machine properly if it freezes. [Source](https://oglo.dev/tutorials/sysrq/index.html)
vm.dirty_background_bytes = 474217728    # 128 MB + 300 MB + 400 MB = 828 MB (rounded to 474217728)
vm.dirty_bytes = 742653184               # 384 MB + 300 MB + 400 MB = 1084 MB (rounded to 742653184)

# --------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#   Nobara Tweaks
# --------------------------------------------------------------------------------------------------------------------------------------------------------------------------
fs.aio-max-nr = 1000000                  # Defines the maximum number of asynchronous I/O requests that can be in progress at a given time. 1048576
fs.inotify.max_user_watches = 524288     # Sets the maximum number of file system watches, enhancing file system monitoring capabilities. Default: 8192  TWEAKED: 524288
kernel.panic = 5                         # Reboot after 5 seconds on kernel panic Default: 0
kernel.pid_max = 32768                   # Allows a large number of processes and threads to be managed Default: 32768 TWEAKED: 4194304

# --------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#   SSD tweaks: Adjust settings for an SSD to optimize performance.
# --------------------------------------------------------------------------------------------------------------------------------------------------------------------------
vm.dirty_expire_centisecs = 3000         # Set the time at which dirty data is old enough to be eligible for writeout (6000 centiseconds). Adjusted for SSD.
vm.dirty_ratio = 80                      # Set the ratio of dirty memory at which a process is forced to write out dirty data (10%). Adjusted for SSD.
vm.dirty_writeback_centisecs = 300       # Set the interval between two consecutive background writeback passes (500 centiseconds).

fs.file-max = 67108864                        # Maximum number of file handles the kernel can allocate (Default: 67108864)
kernel.nmi_watchdog = 0                       # Disable NMI watchdog
kernel.pty.max = 24000                        # Maximum number of pseudo-terminals (PTYs) in the system
kernel.sched_autogroup_enabled = 0            # Disable automatic task grouping for better server performance
kernel.unprivileged_bpf_disabled = 1          # Disable unprivileged BPF
net.core.default_qdisc = fq_codel              
net.core.netdev_max_backlog = 32768            # Maximum length of the input queue of a network device
net.core.optmem_max = 65536                    # Maximum ancillary buffer size allowed per socket
net.core.rmem_default = 1048576                # Default socket receive buffer size
net.core.rmem_max = 16777216                   # Maximum socket receive buffer size
net.core.somaxconn = 65536                     # Maximum listen queue backlog
net.core.wmem_default = 1048576                # Default socket send buffer size
net.core.wmem_max = 16777216                   # Maximum socket send buffer size
net.ipv4.conf.all.accept_redirects = 0        # Disable acceptance of all ICMP redirected packets
net.ipv4.conf.all.secure_redirects = 0        # Disable acceptance of secure ICMP redirected packets
net.ipv4.conf.all.send_redirects = 0          # Disable sending of all IPv4 ICMP redirected packets
net.ipv4.conf.default.accept_redirects = 0    # Disable acceptance of all ICMP redirected packets (default)
net.ipv4.conf.default.secure_redirects = 0    # Disable acceptance of secure ICMP redirected packets (default)
net.ipv4.conf.default.send_redirects = 0      # Disable sending of all IPv4 ICMP redirected packets (default)
net.ipv4.ip_forward = 1                       # Enable IP forwarding
net.ipv4.tcp_congestion_control = westwood     
net.ipv4.tcp_dsack = 1                         # Enable Delayed SACK
net.ipv4.tcp_ecn = 1                           # Enable Explicit Congestion Notification (ECN)
net.ipv4.tcp_fastopen = 3                      # Enable TCP Fast Open with a queue of 3
net.ipv4.tcp_fin_timeout = 25                  # Time to hold socket in FIN-WAIT-2 state (seconds)
net.ipv4.tcp_keepalive_intvl = 30              # Time between individual TCP keepalive probes (seconds)
net.ipv4.tcp_keepalive_probes = 7              # Number of TCP keepalive probes
net.ipv4.tcp_keepalive_time = 1200             # Time before sending TCP keepalive probes (seconds)
net.ipv4.tcp_max_orphans = 819200              # Maximum number of TCP sockets not attached to any user file handle
net.ipv4.tcp_max_syn_backlog = 20480           # Maximum length of the listen queue for accepting new TCP connections
net.ipv4.tcp_max_tw_buckets = 1440000          # Maximum number of TIME-WAIT sockets
net.ipv4.tcp_mem = 65536 1048576 16777216      # TCP memory allocation limits
net.ipv4.tcp_mtu_probing = 1                   # Enable Path MTU Discovery
net.ipv4.tcp_notsent_lowat = 16384             # Minimum amount of data in the send queue below which TCP will send more data
net.ipv4.tcp_retries2 = 8                      # Number of times TCP retransmits unacknowledged data segments for the second SYN on a connection initiation
net.ipv4.tcp_rmem = 8192 1048576 16777216      # TCP read memory allocation for network sockets
net.ipv4.tcp_sack = 1                          # Enable Selective Acknowledgment (SACK)
net.ipv4.tcp_slow_start_after_idle = 0         # Disable slow start after idle
net.ipv4.tcp_slow_start_after_idle = 0         # Disable TCP slow start after idle
net.ipv4.tcp_window_scaling = 1                # Enable TCP window scaling
net.ipv4.tcp_wmem = 8192 1048576 16777216      # TCP write memory allocation for network sockets
net.ipv4.udp_mem = 65536 1048576 16777216      # UDP memory allocation limits
net.ipv6.conf.all.accept_redirects = 0         # Disable acceptance of all ICMP redirected packets for IPv6
net.ipv6.conf.all.disable_ipv6 = 0             # Enable IPv6
net.ipv6.conf.all.forwarding = 1               # Enable IPv6 packet forwarding
net.ipv6.conf.default.accept_redirects = 0     # Disable acceptance of all ICMP redirected packets for IPv6 (default)
net.ipv6.conf.default.disable_ipv6 = 0         # Enable IPv6
net.unix.max_dgram_qlen = 50                   # Maximum length of the UNIX domain socket datagram queue
vm.dirty_background_ratio = 5                  # Percentage of system memory at which background writeback starts
vm.extfrag_threshold = 100                     # Fragmentation threshold for the kernel
vm.min_free_kbytes = 65536                     # Minimum free kilobytes
vm.mmap_min_addr = 65536                       # Minimum address allowed for a user-space mmap
vm.swappiness = 10                             # Swappiness parameter (tendency to swap out unused pages)
vm.vfs_cache_pressure = 50                     # Controls the tendency of the kernel to reclaim the memory used for caching of directory and inode objects
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
	sudo sysctl -p
	sudo systemctl restart systemd-sysctl
	echo ""
	gum spin --spinner dot --title "Restarting systemd custom settings.." -- sleep 4

	echo
	green_msg 'Network is Optimized.'
	echo
```
