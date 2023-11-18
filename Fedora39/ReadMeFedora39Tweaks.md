```bash
sudo nano /etc/sysctl.conf
```



```bash
# sysctl settings are defined through files in
# /usr/lib/sysctl.d/, /run/sysctl.d/, and /etc/sysctl.d/.
#
# Vendors settings live in /usr/lib/sysctl.d/.
# To override a whole file, create a new file with the same in
# /etc/sysctl.d/ and put new settings there. To override
# only specific settings, add a file with a lexically later
# name in /etc/sysctl.d/ and put new settings there.
#
# For more information, see sysctl.conf(5) and sysctl.d(5).

# --------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# Old Nixos Tweaks, to suit  ( 28GB system )
# --------------------------------------------------------------------------------------------------------------------------------------------------------------------------
kernel.sysrq = 1                         # Enable SysRQ for rebooting the machine properly if it freezes. [Source](https://oglo.dev/tutorials/sysrq/index.html)
net.core.netdev_max_backlog = 300000     # Help prevent packet loss during high traffic periods.
net.core.rmem_default = 524288           # Default socket receive buffer size, improve network performance & applications that use sockets. Adjusted for 28GB RAM.
net.core.rmem_max = 33554432             # Maximum socket receive buffer size, determine the amount of data that can be buffered in memory for network operations. Adjusted for 28GB RAM.
net.core.wmem_default = 524288           # Default socket send buffer size, improve network performance & applications that use sockets. Adjusted for 28GB RAM.
net.core.wmem_max = 33554432             # Maximum socket send buffer size, determine the amount of data that can be buffered in memory for network operations. Adjusted for 28GB RAM.
net.ipv4.ipfrag_high_threshold = 6291456 # Reduce the chances of fragmentation. Adjusted for SSD.
net.ipv4.tcp_keepalive_intvl = 30        # TCP keepalive interval between probes to detect if a connection is still alive.
net.ipv4.tcp_keepalive_probes = 5        # TCP keepalive probes to detect if a connection is still alive.
net.ipv4.tcp_keepalive_time = 300        # TCP keepalive interval in seconds to detect if a connection is still alive.
vm.dirty_background_bytes = 474217728    # 128 MB + 300 MB + 400 MB = 828 MB (rounded to 474217728)
vm.dirty_bytes = 742653184               # 384 MB + 300 MB + 400 MB = 1084 MB (rounded to 742653184)
vm.min_free_kbytes = 65536               # Minimum free memory for safety (in KB), helping prevent memory exhaustion situations. Adjusted for 28GB RAM.
vm.swappiness = 10                       # Adjust how aggressively the kernel swaps data from RAM to disk. Lower values prioritize keeping data in RAM. Adjusted for 28GB RAM.
vm.vfs_cache_pressure = 50               # Adjust vfs_cache_pressure (0-1000) to manage memory used for caching filesystem objects. Adjusted for 28GB RAM.

# --------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# Nobara Tweaks
# --------------------------------------------------------------------------------------------------------------------------------------------------------------------------
fs.aio-max-nr = 1000000                  # defines the maximum number of asynchronous I/O requests that can be in progress at a given time.     1048576
fs.inotify.max_user_watches = 65536      # sets the maximum number of file system watches, enhancing file system monitoring capabilities.       Default: 8192  TWEAKED: 524288
kernel.panic = 5                         # Reboot after 5 seconds on kernel panic                                                               Default: 0
kernel.pid_max = 131072                  # allows a large number of processes and threads to be managed                                         Default: 32768 TWEAKED: 4194304

# --------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#   SSD tweaks: Adjust settings for an SSD to optimize performance.
# --------------------------------------------------------------------------------------------------------------------------------------------------------------------------
vm.dirty_background_ratio = 40         # Set the ratio of dirty memory at which background writeback starts (5%). Adjusted for SSD.
vm.dirty_expire_centisecs = 3000       # Set the time at which dirty data is old enough to be eligible for writeout (6000 centiseconds). Adjusted for SSD.
vm.dirty_ratio = 80                    # Set the ratio of dirty memory at which a process is forced to write out dirty data (10%). Adjusted for SSD.
vm.dirty_time = 0                      # Disable dirty time accounting.
vm.dirty_writeback_centisecs = 300     # Set the interval between two consecutive background writeback passes (500 centiseconds).
```

```bash
sudo sysctl -p

```
