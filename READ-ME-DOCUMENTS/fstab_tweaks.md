# fstab tweak
Option to add mount point tweaks to either enhance ssd performance or save wear and tear.
* data=ordered
  - Ensures data ordering, improving file system reliability and performance by writing data to disk in a specific order.
* defaults
   - Applies the default options for mounting, which usually include common settings for permissions, ownership, and read/write access.
* discard
   -  Enables the TRIM command, which allows the file system to notify the storage device of unused blocks, improving performance and longevity of solid-state drives (SSDs).
* errors=remount-ro
  - Remounts the file system as read-only (ro) in case of errors to prevent further potential data corruption.
* noatime
  - Disables updating access times for files, improving file system performance by reducing write operations.
* nodiratime
  - Disables updating directory access time, improving file system performance by reducing unnecessary writes.
* relatime
  - Updates the access time of files relative to the modification time, minimizing the performance impact compared to atime


```bash
sudo nano /etc/fstab
```

```bash
#
# /etc/fstab
# Created by anaconda on Fri Nov 17 11:13:54 2023
#
# Accessible filesystems, by reference, are maintained under '/dev/disk/'.
# See man pages fstab(5), findfs(8), mount(8) and/or blkid(8) for more info.
#
# After editing this file, run 'systemctl daemon-reload' to update systemd
# units generated from this file.
#
UUID=3e3acc31-4e94-4f85-b9b7-89cc0ab53958 /                       f2fs    defaults,noatime,discard        0 0
UUID=a52f7c44-b8a7-4515-bb01-568aee26d7b2 /boot                   xfs     defaults        0 0
UUID=b8fc56cf-1720-4367-add1-2ed1b7c88409 /home                   f2fs    defaults,noatime,discard        0 0

#--------------------------| btrfs |---------------------------------------#

UUID=5992d417-423a-4ff9-bf05-93a0a2963e49 /                       btrfs   subvol=root,compress=zstd:1 0 0

or 

UUID=5992d417-423a-4ff9-bf05-93a0a2963e49 / btrfs subvol=root,compress=zstd:1,discard,noatime,nodiratime 0 0

UUID=f85c1f1b-adc9-4a4c-a5bd-41892ed3b6d7 /boot                   ext4    defaults        1 2
UUID=44FF-C70A                            /boot/efi               vfat    umask=0077,shortname=winnt 0 2
UUID=5992d417-423a-4ff9-bf05-93a0a2963e49 /home                   btrfs   subvol=home,compress=zstd:1 0 0
tmpfs                                     /tmp                    tmpfs   defaults,noatime,mode=1777 0 0

or

UUID=5992d417-423a-4ff9-bf05-93a0a2963e49 /home btrfs subvol=home,compress=zstd:1,discard,noatime,nodiratime 0 0
```

```bash
sudo mount -a
sudo systemctl daemon-reload
```
This command will attempt to mount all filesystems specified in /etc/fstab that are not currently mounted. If there are any errors, they will be displayed.

Please note that some changes to the /etc/fstab file may still require a reboot to take effect, especially if they involve system-critical filesystems. 
If you've made changes related to the root filesystem or other essential components, a reboot is recommended for those changes to be fully applied.



