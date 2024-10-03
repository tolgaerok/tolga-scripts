```bash
# to reload
# sudo sysctl -p

# About These Settings
# These configurations aim to optimize various aspects of the Linux system, including network performance, file systems, and kernel behavior. The tweaks are inspired by configurations from RHEL,
# Fedora, Solus, Mint, and Windows Server. Adjustments have been made based on personal experimentation and preferences.
# Keep in mind that before applying these tweaks, it's recommended to test in a controlled environment and monitor system behavior.

# Linux System Optimization
# --------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# Old Nixos Tweaks, to suit (28GB system)
# --------------------------------------------------------------------------------------------------------------------------------------------------------------------------

kernel.sysrq = 16                        # Enable SysRQ for rebooting the machine properly if it freezes. [Source](https://oglo.dev/tutorials/sysrq/index.html)
vm.dirty_background_bytes = 474217728    # Set dirty background bytes for optimized performance (adjusted for SSD).
vm.dirty_bytes = 742653184               # Set dirty bytes for optimized performance (adjusted for SSD).

# --------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# Nobara Tweaks
# --------------------------------------------------------------------------------------------------------------------------------------------------------------------------

fs.aio-max-nr = 1048576                  # Defines the maximum number of asynchronous I/O requests that can be in progress at a given time.
fs.inotify.max_user_watches = 524288     # Sets the maximum number of file system watches, enhancing file system monitoring capabilities. Default: 8192, Tweaked: 524288
kernel.panic = 5                         # Reboot after 5 seconds on kernel panic. Default: 0
kernel.pid_max = 4194304                  # Allows a large number of processes and threads to be managed. Default: 32768, Tweaked: 4194304

# --------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# SSD tweaks: Adjust settings for an SSD to optimize performance.
# --------------------------------------------------------------------------------------------------------------------------------------------------------------------------

vm.dirty_expire_centisecs = 3000         # Set the time at which dirty data is old enough to be eligible for writeout (6000 centiseconds). Adjusted for SSD.
vm.dirty_ratio = 80                      # Set the ratio of dirty memory at which a process is forced to write out dirty data (10%). Adjusted for SSD.
vm.dirty_writeback_centisecs = 300       # Set the interval between two consecutive background writeback passes (500 centiseconds).

fs.file-max = 67108864                   # Maximum number of file handles the kernel can allocate. Default: 67108864
kernel.nmi_watchdog = 0                  # Disable NMI watchdog
kernel.pty.max = 24000                   # Maximum number of pseudo-terminals (PTYs) in the system
kernel.sched_autogroup_enabled = 0       # Disable automatic task grouping for better server performance
kernel.unprivileged_bpf_disabled = 1     # Disable unprivileged BPF
net.core.default_qdisc = fq_codel
net.core.netdev_max_backlog = 32768      # Maximum length of the input queue of a network device
net.core.optmem_max = 65536              # Maximum ancillary buffer size allowed per socket
net.core.rmem_default = 1048576          # Default socket receive buffer size
net.core.rmem_max = 16777216             # Maximum socket receive buffer size
net.core.somaxconn = 65536               # Maximum listen queue backlog
net.core.wmem_default = 1048576          # Default socket send buffer size
net.core.wmem_max = 16777216             # Maximum socket send buffer size
net.ipv4.conf.all.accept_redirects = 0   # Disable acceptance of all ICMP redirected packets
net.ipv4.tcp_congestion_control = westwood 

# --------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# Additional Tweaks
# --------------------------------------------------------------------------------------------------------------------------------------------------------------------------

fs.inotify.max_user_watches=1048576        # Helps with out-of-the-box compatibility with some games
vm.max_map_count=2147483642                # Define the maximum number of memory map areas a process may have
kernel.core_pattern=|/usr/lib/systemd/systemd-coredump %P %u %g %s %t %c %h
fs.suid_dumpable=2                         # Set SUID_DUMPABLE flag. 0 means not core dump, 1 means core dump, and 2 means core dump with setuid
kernel.core_uses_pid = 1                   # Append the PID to the core filename

# Source route verification
net.ipv4.conf.default.rp_filter = 2          # Enable source route verification
net.ipv4.conf.*.rp_filter = 2                # Enable source route verification
-net.ipv4.conf.all.rp_filter                 # Disable source route verification for all interfaces

# Do not accept source routing
net.ipv4.conf.default.accept_source_route = 0     # Disable acceptance of source-routed packets
net.ipv4.conf.*.accept_source_route = 0           # Disable acceptance of source-routed packets
-net.ipv4.conf.all.accept_source_route            # Disable acceptance of source-routed packets for all interfaces

# Promote secondary addresses when the primary address is removed
net.ipv4.conf.default.promote_secondaries = 1    # Promote secondary addresses when the primary address is removed
net.ipv4.conf.*.promote_secondaries = 1          # Promote secondary addresses when the primary address is removed
-net.ipv4.conf.all.promote_secondaries           # Disable promoting secondary addresses for all interfaces
-net.ipv4.ping_group_range = 0 2147483647        # Restrict the range of user IDs that can create ICMP Echo sockets

# Enable hard and soft link protection
fs.protected_hardlinks = 1                # Protect hard links against tampering by not allowing users to create or modify them
fs.protected_symlinks = 1                 # Protect symlinks against tampering by not allowing users to create or modify them

# Enable regular file and FIFO protection
fs.protected_regular = 1                  # Protect regular files against tampering by not allowing users to create or modify them
fs.protected_fifos = 1                    # Protect FIFOs against tampering by not allowing users to create or modify them

-vm.unprivileged_userfaultfd = 1           # Enable unprivileged userfaultfd
vm.page-cluster = 0                        # Disable page clustering for filesystems

# --------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# Old Nixos Tweaks, to suit (28GB system)
# --------------------------------------------------------------------------------------------------------------------------------------------------------------------------

kernel.sysrq = 16                        # Enable SysRQ for rebooting the machine properly if it freezes. [Source](https://oglo.dev/tutorials/sysrq/index.html)
vm.dirty_background_bytes = 474217728    # Set dirty background bytes for optimized performance (adjusted for SSD).
vm.dirty_bytes = 742653184               # Set dirty bytes for optimized performance (adjusted for SSD).

# --------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# Nobara Tweaks
# --------------------------------------------------------------------------------------------------------------------------------------------------------------------------

fs.aio-max-nr = 1048576                  # Defines the maximum number of asynchronous I/O requests that can be in progress at a given time.
fs.inotify.max_user_watches = 524288     # Sets the maximum number of file system watches, enhancing file system monitoring capabilities. Default: 8192, Tweaked: 524288
kernel.panic = 5                         # Reboot after 5 seconds on kernel panic. Default: 0
kernel.pid_max = 4194304                 # Allows a large number of processes and threads to be managed. Default: 32768, Tweaked: 4194304

# --------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# SSD tweaks: Adjust settings for an SSD to optimize performance.
# --------------------------------------------------------------------------------------------------------------------------------------------------------------------------

vm.dirty_expire_centisecs = 3000         # Set the time at which dirty data is old enough to be eligible for writeout (6000 centiseconds). Adjusted for SSD.
vm.dirty_ratio = 80                      # Set the ratio of dirty memory at which a process is forced to write out dirty data (10%). Adjusted for SSD.
vm.dirty_writeback_centisecs = 300       # Set the interval between two consecutive background writeback passes (500 centiseconds).

fs.file-max = 67108864                   # Maximum number of file handles the kernel can allocate. Default: 67108864
kernel.nmi_watchdog = 0                  # Disable NMI watchdog
kernel.pty.max = 24000                   # Maximum number of pseudo-terminals (PTYs) in the system
kernel.sched_autogroup_enabled = 0       # Disable automatic task grouping for better server performance
kernel.unprivileged_bpf_disabled = 1     # Disable unprivileged BPF
net.core.default_qdisc = fq_codel
net.core.netdev_max_backlog = 32768      # Maximum length of the input queue of a network device
net.core.optmem_max = 65536              # Maximum ancillary buffer size allowed per socket
net.core.rmem_default = 1048576          # Default socket receive buffer size
net.core.rmem_max = 16777216             # Maximum socket receive buffer size
net.core.somaxconn = 65536               # Maximum listen queue backlog
net.core.wmem_default = 1048576          # Default socket send buffer size
net.core.wmem_max = 16777216             # Maximum socket send buffer size
net.ipv4.conf.all.accept_redirects = 0   # Disable acceptance of all ICMP redirected packets

# --------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# Additional Tweaks
# --------------------------------------------------------------------------------------------------------------------------------------------------------------------------

fs.inotify.max_user_watches=1048576        # Helps with out-of-the-box compatibility with some games
vm.max_map_count=2147483642                # Define the maximum number of memory map areas a process may have
kernel.core_pattern=|/usr/lib/systemd/systemd-coredump %P %u %g %s %t %c %h
fs.suid_dumpable=2                         # Set SUID_DUMPABLE flag. 0 means not core dump, 1 means core dump, and 2 means core dump with setuid
kernel.core_uses_pid = 1                   # Append the PID to the core filename

# Source route verification
net.ipv4.conf.default.rp_filter = 2        # Enable source route verification
net.ipv4.conf.*.rp_filter = 2              # Enable source route verification
-net.ipv4.conf.all.rp_filter               # Disable source route verification for all interfaces

# Do not accept source routing
net.ipv4.conf.default.accept_source_route = 0    # Disable acceptance of source-routed packets
net.ipv4.conf.*.accept_source_route = 0          # Disable acceptance of source-routed packets
-net.ipv4.conf.all.accept_source_route           # Disable acceptance of source-routed packets for all interfaces

# Promote secondary addresses when the primary address is removed
net.ipv4.conf.default.promote_secondaries = 1    # Promote secondary addresses when the primary address is removed
net.ipv4.conf.*.promote_secondaries = 1          # Promote secondary addresses when the primary address is removed
-net.ipv4.conf.all.promote_secondaries           # Disable promoting secondary addresses for all interfaces
-net.ipv4.ping_group_range = 0 2147483647        # Restrict the range of user IDs that can create ICMP Echo sockets

# Enable hard and soft link protection
fs.protected_hardlinks = 1                # Protect hard links against tampering by not allowing users to create or modify them
fs.protected_symlinks = 1                 # Protect symlinks against tampering by not allowing users to create or modify them

# Enable regular file and FIFO protection
fs.protected_regular = 1                  # Protect regular files against tampering by not allowing users to create or modify them
fs.protected_fifos = 1                    # Protect FIFOs against tampering by not allowing users to create or modify them

-vm.unprivileged_userfaultfd = 1          # Enable unprivileged userfaultfd
vm.page-cluster = 0                       # Disable page clustering for filesystems
```
