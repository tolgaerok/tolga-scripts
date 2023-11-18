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
```

```bash
sudo mount -a
sudo systemctl daemon-reload
```
This command will attempt to mount all filesystems specified in /etc/fstab that are not currently mounted. If there are any errors, they will be displayed.

Please note that some changes to the /etc/fstab file may still require a reboot to take effect, especially if they involve system-critical filesystems. 
If you've made changes related to the root filesystem or other essential components, a reboot is recommended for those changes to be fully applied.
