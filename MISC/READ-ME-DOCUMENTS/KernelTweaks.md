In this section:
* Tweaked values
* Default values
* Summary

## Lets get started

Open in editor:
```bash
sudo nano /etc/sysctl.conf
```

## Tweaked values to suit nixOS or Fedora
Copy or use only to suit your use case. Default fedora 39 values below these values
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
#   Old Nixos Tweaks, to suit  ( 28GB system )
# --------------------------------------------------------------------------------------------------------------------------------------------------------------------------
kernel.sysrq = 1                         # Enable SysRQ for rebooting the machine properly if it freezes. [Source](https://oglo.dev/tutorials/sysrq/index.html)
net.core.netdev_max_backlog = 300000     # Help prevent packet loss during high traffic periods.
net.core.rmem_default = 524288           # Default socket receive buffer size, improve network performance & applications that use sockets. Adjusted for 28GB RAM.
net.core.rmem_max = 33554432             # Maximum socket receive buffer size, determine the amount of data that can be buffered in memory for network operations. Adjusted for 28GB RAM.
net.core.wmem_default = 524288           # Default socket send buffer size, improve network performance & applications that use sockets. Adjusted for 28GB RAM.
net.core.wmem_max = 33554432             # Maximum socket send buffer size, determine the amount of data that can be buffered in memory for network operations. Adjusted for 28GB RAM.
# net.ipv4.ipfrag_high_threshold = 6291456 # Reduce the chances of fragmentation. Adjusted for SSD.
net.ipv4.tcp_keepalive_intvl = 30        # TCP keepalive interval between probes to detect if a connection is still alive.
net.ipv4.tcp_keepalive_probes = 5        # TCP keepalive probes to detect if a connection is still alive.
net.ipv4.tcp_keepalive_time = 300        # TCP keepalive interval in seconds to detect if a connection is still alive.
vm.dirty_background_bytes = 474217728    # 128 MB + 300 MB + 400 MB = 828 MB (rounded to 474217728)
vm.dirty_bytes = 742653184               # 384 MB + 300 MB + 400 MB = 1084 MB (rounded to 742653184)
vm.min_free_kbytes = 65536               # Minimum free memory for safety (in KB), helping prevent memory exhaustion situations. Adjusted for 28GB RAM.
vm.swappiness = 10                       # Adjust how aggressively the kernel swaps data from RAM to disk. Lower values prioritize keeping data in RAM. Adjusted for 28GB RAM.
vm.vfs_cache_pressure = 50               # Adjust vfs_cache_pressure (0-1000) to manage memory used for caching filesystem objects. Adjusted for 28GB RAM.

# --------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#   Nobara Tweaks
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
# vm.dirty_time = 0                      # Disable dirty time accounting.   NOT AVAILABLE IN FEDORA STABLE KERNEL
vm.dirty_writeback_centisecs = 300     # Set the interval between two consecutive background writeback passes (500 centiseconds).

net.core.default_qdisc=fq
net.ipv4.tcp_congestion_control=westwood
```
Reload setting's without reboot
```bash
sudo sysctl -p

```

## Default values in fedora 39
```bash
kernel.sysrq = 16
net.core.netdev_max_backlog = 1000
net.core.rmem_default = 212992
net.core.rmem_max = 212992
net.core.wmem_default = 212992
net.core.wmem_max = 212992
net.ipv4.ipfrag_high_threshold = 
net.ipv4.tcp_keepalive_intvl = 75
net.ipv4.tcp_keepalive_probes = 9
net.ipv4.tcp_keepalive_time = 7200
vm.dirty_background_bytes = 0
vm.dirty_bytes = 0
vm.min_free_kbytes = 67584
vm.swappiness = 60
vm.vfs_cache_pressure = 100
fs.aio-max-nr = 65536
fs.inotify.max_user_watches = 524288
kernel.panic = 0
kernel.pid_max = 4194304
vm.dirty_background_ratio = 10
vm.dirty_expire_centisecs = 3000
vm.dirty_ratio = 20
vm.dirty_writeback_centisecs = 500
```
## Summary based on personal observation on my HP G1 800 i7-4770 28GB
Let's compare the default values with the tweaked values, considering the adjustments for my 28GB system:

1. **kernel.sysrq:**
   - Default: 16
   - Tweaked: 1
   - Decision: The tweak (1) is generally safer as it enables fewer SysRQ functions.

2. **net.core.netdev_max_backlog:**
   - Default: 1000
   - Tweaked: 300000
   - Decision: The tweak (300000) is more suitable for preventing packet loss during high traffic periods.

3. **net.core.rmem_default, net.core.rmem_max, net.core.wmem_default, net.core.wmem_max:**
   - Decision: The tweaks (524288, 33554432) are more suitable for a system with 28GB of RAM, improving network performance.

4. **net.ipv4.ipfrag_high_threshold:**
   - Default: [Not specified]
   - Tweaked: 6291456
   - Decision: The tweak (6291456) is adjusted for SSD and may help reduce fragmentation.

5. **net.ipv4.tcp_keepalive_intvl, net.ipv4.tcp_keepalive_probes, net.ipv4.tcp_keepalive_time:**
   - Decision: The tweaks are more aggressive (30, 5, 300) and may be suitable for detecting dead connections faster.

6. **vm.dirty_background_bytes, vm.dirty_bytes:**
   - Decision: The tweaks (474217728, 742653184) are more appropriate for a system with 28GB of RAM, providing a buffer before initiating writebacks.

7. **vm.min_free_kbytes:**
   - Default: 65536
   - Tweaked: 65536
   - Decision: No significant change. The tweak is relatively minor.

8. **vm.swappiness:**
   - Decision: The tweak (10) is more suitable for a system with 28GB of RAM, prioritizing keeping data in RAM.

9. **vm.vfs_cache_pressure:**
   - Decision: The tweak (50) is more suitable for a system with 28GB of RAM, managing memory used for caching filesystem objects.

10. **fs.aio-max-nr:**
    - Decision: The tweak (1000000) is significantly lower than the default (1048576). Depending on your application's use of asynchronous I/O, you may want to reconsider this tweak.

11. **fs.inotify.max_user_watches:**
    - Decision: The tweak (524288) is more suitable for enhancing file system monitoring capabilities.

12. **kernel.panic:**
    - Default: 0
    - Tweaked: 5
    - Decision: The tweak (5) enables the system to reboot after 5 seconds on a kernel panic. Depending on your preference for system behavior on kernel panics, you may choose to keep the default or use the tweak.

13. **kernel.pid_max:**
    - Default: 32768
    - Tweaked: 4194304
    - Decision: The tweak allows a larger number of processes and threads, which may be beneficial for a system with 28GB of RAM.

14. **SSD tweaks (vm.dirty_background_ratio, vm.dirty_expire_centisecs, vm.dirty_ratio, vm.dirty_writeback_centisecs):**
    - Decision: The SSD tweaks are adjusted for better performance on an SSD and are generally suitable.

In summary, for my 28GB system, the tweaked values seem more appropriate in most cases, especially regarding network settings, dirty memory settings, and adjustments for SSD. However, you may want to reconsider the fs.aio-max-nr tweak depending on your application's requirements. 

Always monitor your system's performance after making changes and adjust as needed.


Enjoy
Tolga Erok

## Default values in LinuxMint cinnamon
```bash
fs.aio-max-nr = 65536
fs.inotify.max_user_watches = 28851
kernel.panic = 0
kernel.panic_on_io_nmi = 0
kernel.panic_on_oops = 0
kernel.panic_on_rcu_stall = 0
kernel.panic_on_unrecovered_nmi = 0
kernel.panic_on_warn = 0
kernel.panic_print = 0
kernel.pid_max = 4194304
kernel.sysrq = 176
net.core.netdev_max_backlog = 1000
net.core.rmem_default = 212992
net.core.rmem_max = 212992
net.core.wmem_default = 212992
net.core.wmem_max = 212992
net.ipv4.tcp_keepalive_intvl = 75
net.ipv4.tcp_keepalive_probes = 9
net.ipv4.tcp_keepalive_time = 7200
vm.dirty_background_bytes = 0
vm.dirty_background_ratio = 10
vm.dirty_bytes = 0
vm.dirty_expire_centisecs = 3000
vm.dirty_ratio = 20
vm.dirty_writeback_centisecs = 500
vm.min_free_kbytes = 67584
vm.swappiness = 60
vm.vfs_cache_pressure = 100
```
Here's a comparison between the Fedora parameters between fedora and the Ubuntu parameters:

| Parameter                           | Fedora Value | Ubuntu Value   |
|-------------------------------------|--------------|----------------|
| fs.aio-max-nr                        | 65536        | 65536          |
| fs.inotify.max_user_watches         | 524288       | 28851          |
| kernel.panic                        | 0            | 0              |
| kernel.pid_max                      | 4194304      | 4194304        |
| kernel.sysrq                        | 16           | 176            |
| net.core.netdev_max_backlog         | 1000         | 1000           |
| net.core.rmem_default               | 212992       | 212992         |
| net.core.rmem_max                   | 212992       | 212992         |
| net.core.wmem_default               | 212992       | 212992         |
| net.core.wmem_max                   | 212992       | 212992         |
| net.ipv4.tcp_keepalive_intvl        | 75           | 75             |
| net.ipv4.tcp_keepalive_probes       | 9            | 9              |
| net.ipv4.tcp_keepalive_time         | 7200         | 7200           |
| vm.dirty_background_bytes           | 0            | 0              |
| vm.dirty_background_ratio           | 10           | 10             |
| vm.dirty_bytes                      | 0            | 0              |
| vm.dirty_expire_centisecs           | 3000         | 3000           |
| vm.dirty_ratio                      | 20           | 20             |
| vm.dirty_writeback_centisecs        | 500          | 500            |
| vm.min_free_kbytes                  | 67584        | 67584          |
| vm.swappiness                       | 60           | 60             |
| vm.vfs_cache_pressure               | 100          | 100            |

The values appear to be consistent between the two sets of parameters for the specified configuration options. I
