# OOMD service (fedora)

OOMD (Out-Of-Memory Daemon) is a component of systemd, the system and service manager for Linux. Its purpose is to handle situations where the system runs out of memory (OOM). 
When a system exhausts its available memory and cannot fulfill memory allocation requests from processes, it needs to make a decision about which process to terminate to free up memory and prevent system instability or crashes.

Source: https://fedoraproject.org/wiki/Changes/EnableSystemdOomd



```bash
sudo systemctl enable --now systemd-oomd.service
sudo systemctl enable --now fstrim.timer

```
