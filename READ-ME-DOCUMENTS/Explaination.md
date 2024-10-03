## About These Settings

These configurations aim to optimize various aspects of the Linux system, including network performance, file systems, and kernel behavior. The tweaks are inspired by configurations from RHEL, Fedora, Solus, Mint, and Windows Server. Adjustments have been made based on personal experimentation and preferences.

Keep in mind that before applying these tweaks, it's recommended to test in a controlled environment and monitor system behavior.

# Linux System Optimization

## TCP Stack Tweaks

```conf
net.ipv4.tcp_congestion_control = westwood
net.ipv4.tcp_dsack = 1
net.ipv4.tcp_ecn = 1
net.ipv4.tcp_fastopen = 3
net.ipv4.tcp_fin_timeout = 25
net.ipv4.tcp_keepalive_intvl = 30
net.ipv4.tcp_keepalive_probes = 7
net.ipv4.tcp_keepalive_time = 1200
net.ipv4.tcp_max_orphans = 819200
net.ipv4.tcp_max_syn_backlog = 20480
net.ipv4.tcp_max_tw_buckets = 1440000
net.ipv4.tcp_mem = 65536 1048576 16777216
net.ipv4.tcp_mtu_probing = 1
net.ipv4.tcp_notsent_lowat = 16384
net.ipv4.tcp_retries2 = 8
net.ipv4.tcp_rmem = 8192 1048576 16777216
net.ipv4.tcp_sack = 1
net.ipv4.tcp_slow_start_after_idle = 0
net.ipv4.tcp_window_scaling = 1
net.ipv4.tcp_wmem = 8192 1048576 16777216
```

## Network and File System Settings

```conf
net.core.netdev_max_backlog = 32768
net.core.somaxconn = 65536
fs.aio-max-nr = 1000000
fs.inotify.max_user_watches = 524288
kernel.panic = 5
kernel.pid_max = 32768
vm.dirty_background_bytes = 474217728
vm.dirty_bytes = 742653184
vm.dirty_expire_centisecs = 3000
vm.dirty_ratio = 80
vm.dirty_writeback_centisecs = 300
vm.dirty_background_ratio = 5
vm.extfrag_threshold = 100
fs.file-max = 67108864
kernel.nmi_watchdog = 0
kernel.pty.max = 24000
kernel.sched_autogroup_enabled = 0
kernel.unprivileged_bpf_disabled = 1
```

## IPv4 and IPv6 Networking

```conf
net.ipv4.conf.all.accept_redirects = 0
net.ipv4.conf.all.secure_redirects = 0
net.ipv4.conf.all.send_redirects = 0
net.ipv4.conf.default.accept_redirects = 0
net.ipv4.conf.default.secure_redirects = 0
net.ipv4.conf.default.send_redirects = 0
net.ipv4.ip_forward = 1
net.ipv4.udp_mem = 65536 1048576 16777216
net.ipv6.conf.all.accept_redirects = 0
net.ipv6.conf.all.disable_ipv6 = 0
net.ipv6.conf.all.forwarding = 1
net.ipv6.conf.default.accept_redirects = 0
net.ipv6.conf.default.disable_ipv6 = 0
```

## Miscellaneous Settings

```conf
net.unix.max_dgram_qlen = 50
vm.min_free_kbytes = 65536
vm.mmap_min_addr = 65536
vm.swappiness = 10
vm.vfs_cache_pressure = 50
net.core.default_qdisc = fq_codel
```



