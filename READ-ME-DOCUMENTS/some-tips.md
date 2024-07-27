# F40 GNOME Rygel issues

```script
#!/bin/bash
# Tolga Erok
# 25/5/24

# Variables
SERVICE_FILE="/etc/systemd/system/rygel.service"
USERNAME=$(whoami)
GROUP=$(id -gn)

# Check if Rygel is installed
if ! dpkg -l | grep -q rygel; then
  echo "Rygel is not installed. Installing Rygel..."
  sudo dnf update
  sudo dnf install -y rygel
else
  echo "Rygel is already installed."
fi

# Create systemd service file
echo "Creating systemd service file for Rygel..."
sudo tee $SERVICE_FILE > /dev/null <<EOL
[Unit]
Description=Rygel DLNA/UPnP server
After=network.target

[Service]
ExecStart=/usr/bin/rygel
Restart=on-failure
#User=$USERNAME
#Group=$GROUP

[Install]
WantedBy=multi-user.target
EOL

# Reload systemd daemon to recognize the new service
echo "Reloading systemd daemon..."
sudo systemctl daemon-reload

# Start the Rygel service
echo "Starting Rygel service..."
sudo systemctl start rygel

# Enable Rygel service to start on boot
echo "Enabling Rygel service to start on boot..."
sudo systemctl enable rygel
sudo systemctl restart rygel

# Check the status of the Rygel service
echo "Checking the status of Rygel service..."
sudo systemctl status rygel

echo "Rygel setup completed."
```

# Install Nvidia on F40 GNOME
```script
sudo dnf install akmod-nvidia                                 # rhel/centos users can use kmod-nvidia instead
sudo dnf install xorg-x11-drv-nvidia-cuda                     # optional for cuda/nvdec/nvenc support
sudo dnf install xorg-x11-drv-nvidia-cuda-libs                # RPM Fusion support ffmpeg compiled with NVENC/NVDEC with Fedora 25 and later
sudo dnf install nvidia-vaapi-driver libva-utils vdpauinfo    # enable video acceleration support for your player and if your NVIDIA card is recent enough (Geforce 8 and later is needed)
sudo dnf install xorg-x11-drv-nvidia-power
sudo systemctl enable nvidia-{suspend,resume,hibernate}
sudo grubby --update-kernel=ALL --args='nvidia-drm.modeset=1'
```

# Nvidia suspend issue work around
- The configuration line `options nvidia NVreg_TemporaryFilePath=/tmp` adjusts the NVIDIA driver's temporary file path to `/tmp`. This change is particularly useful when encountering issues with NVIDIA suspend due to `/tmp` being mounted as `tmpfs`.

- Optional: tweak add into `/etc/modprobe.d/nvidia.conf` as needed if you have issue with `/tmp` as `tmpfs` with nvidia suspend )
```script
options nvidia NVreg_UsePageAttributeTable=1
options nvidia NVreg_EnablePCIeGen3=1
options nvidia NVreg_RegistryDwords=RMI2cSpeed=100
options nvidia NVreg_PreserveVideoMemoryAllocations=1
options nvidia NVreg_TemporaryFilePath=/var/tmp
```

- To uninstall the package, use the following command:

```script
sudo yum remove xorg-x11-drv-nvidia\* kmod-nvidia\* 
```



- Save `control+x` and `reboot`



# Detect USB Device Versions Plugged in
![image](https://github.com/tolgaerok/tolga-scripts/assets/110285959/a7ab8daa-3c34-4e83-9112-0a8da606d615)

```script
#!/bin/bash
# Tolga erok
# 22/5/24

# Function to detect USB version of a port
detect_usb_version() {
    local usb_version=$(lsusb -v -d "$1" 2>/dev/null | grep "bcdUSB" | awk '{print $2}')
    if [[ "$usb_version" == "3.00" ]]; then
        echo "USB 3.0"
    elif [[ "$usb_version" == "2.00" ]]; then
        echo "USB 2.0"
    elif [[ "$usb_version" == "1.10" || "$usb_version" == "1.00" ]]; then
        echo "USB 1.x"
    else
        echo "Unknown USB version"
    fi
}

# Main function
main() {
    echo "Detecting USB versions:"
    echo "-----------------------"
    lsusb | while read -r line; do
        usb_vendor=$(echo "$line" | awk '{print $6}')
        usb_product=$(echo "$line" | awk '{print $7}')
        usb_version=$(detect_usb_version "$usb_vendor:$usb_product")
        echo "USB device: $usb_vendor:$usb_product, Version: $usb_version"
    done
}

# Run the main function
main
```
- Make script executable
```bash
chmod +x detect_usb_version.sh
```

- To run:
```bash
./detect_usb_version.sh

```  

# Detect Package Manger on any system
![image](https://github.com/tolgaerok/tolga-scripts/assets/110285959/afe621c1-8336-45a5-a07b-41da91203c68)

```script
#!/bin/bash

# Function to detect the package manager
detect_package_manager() {
    for _PM in apt-get dnf eopkg pacman pkgtool ppm swupd yum xbps-install zypper unknown; do
        if command -v "$_PM" &> /dev/null; then
            if [ "$_PM" = "apt-get" ] && ! command -v dpkg &> /dev/null && command -v rpm &> /dev/null; then
                _PM=apt-rpm
            fi
            echo "$_PM"
            break
        fi
    done
}

# Main function
main() {
    package_manager=$(detect_package_manager)
    echo "Package manager is: $package_manager"
}

# Run the main function
main

```
- make the script executable
```script
chmod +x detect_package_manager.sh
```
- Run the script
```bash
./detect_package_manager.sh
```

# Ultramarine Upgrade from UM39 - UM40

```script
sudo dnf upgrade --refresh
sudo dnf install dnf-plugins-core
sudo dnf system-upgrade download --releasever=40
sudo dnf system-upgrade reboot
```

# Ultramarine Nvidia
```script
sudo dnf update # Update the system first, the drivers may not work right if you don't.
sudo dnf install akmod-nvidia # Install the NVIDIA kernel module.
```

# Arch (BigLinux, Manjaro)

## Enable `numlock` on kde
```bash
sudo nano /etc/sddm.conf
```

```bash
[General]
InputMethod=qtvirtualkeyboard
Numlock=on

```

Or (This Works on Solus)

```bash
sudo kwriteconfig5 --file /etc/sddm.conf --group General --key Numlock on
```

Or

```bash
sudo kwriteconfig5 --file /etc/sddm.conf --group General --key Numlock true
```

## auto-cpufreq

`DOC`: github page as it explains it better: 
```bash
https://github.com/AdnanHodzic/auto-cpufreq
```

- Disable the service `tlp`:
```bash
sudo systemctl stop tlp.service
sudo systemctl disable tlp service
```

- Install `auto-cpufreq`
  
Can install via BigLinux Store or via the terminal

```bash
sudo pacman -S auto-cpufreq
```

- Activate and start the service:
```bash
sudo systemctl enable auto-cpufreq.service
sudo systemctl start auto-cpufreq.service
```

- Enable and start the service thermald(recommended)
```bash
sudo systemctl enable thermald.service
sudo systemctl start thermald.service
```
Restart the notebook/laptop

#



## Disable `ipv6` for faster browsing

- Create a file called `40-ipv6.conf` inside `/etc/sysctl.d`

```bash
sudo nano /etc/sysctl.d/40-ipv6.conf
```

- Add the following content:

```bash
# Disable IPv6
net.ipv6.conf.all.disable_ipv6 = 1 
net.ipv6.conf.interface0.disable_ipv6 = 1
net.ipv6.conf.interfaceN.disable_ipv6 = 1
```
#

### Use different dns (e.g. the Google ones)
```bash
sudo nano /etc/resolv.conf
```

and replace nameserver with the new ones (dns1 and dns2 respectively)

```bash
# Generated by resolvconf
nameserver 8.8.8.8
nameserver 8.8.4.4
```
#

## Add `Nvidia` gloabal environment parameters
```bash
sudo nano /etc/environment
```

ADD:

```bash
#
# This file is parsed by pam_env module
#
# Syntax: simple "KEY=VAL" pairs on separate lines
#

QT_LOGGING_RULES='*=false'
QSG_RENDER_LOOP=basic
#__GL_THREADED_OPTIMIZATION=1
#mesa_glthread=true

LIBVA_DRIVER_NAME=nvidia
WLR_NO_HARDWARE_CURSORS=1
__GLX_VENDOR_LIBRARY_NAME=nvidia
__GL_SHADER_CACHE=1
__GL_THREADED_OPTIMIZATION=1
```

#

## Custom `kernel` parameters for Biglinux 
- (Part A)

```bash
sudo nano /usr/lib/sysctl.d/50-default.conf
```
ADD:
```bash
# Use kernel.sysrq = 1 to allow all keys.
# See https://docs.kernel.org/admin-guide/sysrq.html for a list
# of values and keys.
kernel.sysrq = 16

# Append the PID to the core filename
kernel.core_uses_pid = 1

# Source route verification
net.ipv4.conf.default.rp_filter = 2
net.ipv4.conf.*.rp_filter = 2
-net.ipv4.conf.all.rp_filter

# Do not accept source routing
net.ipv4.conf.default.accept_source_route = 0
net.ipv4.conf.*.accept_source_route = 0
-net.ipv4.conf.all.accept_source_route

# Promote secondary addresses when the primary address is removed
net.ipv4.conf.default.promote_secondaries = 1
net.ipv4.conf.*.promote_secondaries = 1
-net.ipv4.conf.all.promote_secondaries

# ping(8) without CAP_NET_ADMIN and CAP_NET_RAW
# The upper limit is set to 2^31-1. Values greater than that get rejected by
# the kernel because of this definition in linux/include/net/ping.h:
#   #define GID_T_MAX (((gid_t)~0U) >> 1)
# That's not so bad because values between 2^31 and 2^32-1 are reserved on
# systemd-based systems anyway: https://systemd.io/UIDS-GIDS#summary
-net.ipv4.ping_group_range = 0 2147483647

# Fair Queue CoDel packet scheduler to fight bufferbloat
#net.core.default_qdisc = fq_codel
net.core.default_qdisc = cake
net.ipv4.tcp_congestion_control = westwood 

# Enable hard and soft link protection
fs.protected_hardlinks = 1
fs.protected_symlinks = 1

# Enable regular file and FIFO protection
fs.protected_regular = 1
fs.protected_fifos = 1

# Disable NMI watchdog: This action will speed up your boot and shutdown, because one less module is loaded. Additionally disabling watchdog timers increases performance and lowers power consumption
kernel.nmi_watchdog = 0

# Enable the sysctl setting kernel.unprivileged_userns_clone to allow normal users to run unprivileged containers.
kernel.unprivileged_userns_clone=1

# To hide any kernel messages from the console
kernel.printk = 3 3 3 3

# the key combination of Alt+SysRq+<b/e/f/s/u> will result in Magic SysRQ invocation
kernel.sysrq=1

# Libvirt uses a default of 1M requests to allow 8k disks, with at most
# 64M of kernel memory if all disks hit an aio request at the same time.
fs.aio-max-nr = 1048576

# Bump the numeric PID range to make PID collisions less likely.
# 2^22 and 2^15 is possible maximum of 64bit and 32bit kernels respectively.
kernel.pid_max = 4194304

kernel.sched_cfs_bandwidth_slice_us = 3000

#  This is required due to some games being unable to reuse their TCP ports
#  if they're killed and restarted quickly - the default timeout is too large.

net.ipv4.tcp_fin_timeout = 5
# Raise inotify resource limits
fs.inotify.max_user_instances = 1024
fs.inotify.max_user_watches = 524288

# Increase the default vm.max_map_count value
vm.max_map_count=1048576
```

## Custom `kernel` parameters for Biglinux 
- (Part B)


```bash
sudo nano /etc/sysctl.d/11-network-tweaks.conf
```

ADD:
```bash
### TUNING NETWORK PERFORMANCE ###
# Tolga Erok
#        
# net.core.default_qdisc = fq_codel                                                  # Set the default queuing discipline (qdisc) for the kernel's network scheduler to "cake"
net.core.rmem_max = 1073741824                                          # Set the maximum socket receive buffer size for all network devices to 1073741824 bytes
net.core.wmem_max = 1073741824                                        # Set the maximum socket send buffer size for all network devices to 1073741824 bytes
net.ipv4.tcp_congestion_control = westwood                        # Set the TCP congestion control algorithm to "westwood"
net.ipv4.tcp_mem = 65536 1048576 16777216                      # Set TCP memory allocation limits
net.ipv4.tcp_mtu_probing = 1                                                    # Enable Path MTU Discovery
net.ipv4.tcp_notsent_lowat = 16384                                         # Minimum amount of data in the send queue below which TCP will send more data
net.ipv4.tcp_retries2 = 8                                                             # Set the number of times TCP retransmits unacknowledged data segments for the second SYN on a connection initiation to 8
net.ipv4.tcp_rmem = 4096 87380 1073741824                      # Set TCP read memory allocation for network sockets
net.ipv4.tcp_rmem = 8192 1048576 16777216                      # TCP read memory allocation for network sockets
net.ipv4.tcp_sack = 1                                                                   # Enable Selective Acknowledgment (SACK)
net.ipv4.tcp_slow_start_after_idle = 0                                      # Disable TCP slow start after idle
net.ipv4.tcp_tw_reuse = 1                                                           # Increase the tcp-time-wait buckets pool size to prevent simple DOS attacks
net.ipv4.tcp_window_scaling = 1                                               # Enable TCP window scaling
net.ipv4.tcp_wmem = 4096 87380 1073741824                     # Set TCP write memory allocation for network sockets
net.ipv4.tcp_wmem = 8192 1048576 16777216                     # TCP write memory allocation for network sockets
net.ipv4.udp_mem = 65536 1048576 16777216                    # Set UDP memory allocation limits
net.ipv4.udp_rmem_min = 16384                                             # Increase the read-buffer space allocatable for UDP
net.ipv4.udp_wmem_min = 16384                                           # Increase the write-buffer-space allocatable for UDP


```


Then:
```bash
sudo udevadm control --reload-rules && sudo udevadm trigger && sudo sysctl --system
```

#
## Change ParallelDownloads amount: `default = 5 or 7` and add `ILoveCandy`
  
```bash
sudo nano /etc/pacman.conf
```
Find: `ParallelDownloads = 7`
change to `12`

ADD:
`IloveCandy`

RESULT:
```bash
[options]
ParallelDownloads = 12
ILoveCandy
```


#

## Change `Fair Queue CoDel packet` scheduler to fight bufferbloat from `fq_codel` to `cake`
- LOCATION: /usr/lib/sysctl.d/50-default.conf
- If this location dosnt exist then
`sudo nano /etc/sysctl.d/13-extra-tweak.conf`

ADD:

```bash
net.core.default_qdisc = cake
net.ipv4.tcp_congestion_control = westwood
```

Then:
```bash
sudo udevadm control --reload-rules && sudo udevadm trigger && sudo sysctl --system
```

Then:
```bash
sudo tc qdisc replace dev wlp3s0 root cake bandwidth 1Gbit
```

Then:
```bash
sudo udevadm control --reload-rules && sudo udevadm trigger && sudo sysctl --system
```
#
## Chrome accelerator
```bash
yay -S manjaro-vaapi libva-utils
```
#
## Systemd cannot shutdown properly

Adding to HOOKS array `shutdown` hook and refresh kernels. 

* https://www.reddit.com/r/archlinux/comments/8su99e/my_laptop_isnt_shutting_down_what_can_i_try/
* https://bbs.archlinux.org/viewtopic.php?id=233820
* https://github.com/systemd/systemd/issues/8155


The work-around for now appears to edit  `/etc/mkinitcpio.conf`  and look for the following line:

 ```
 HOOKS="base udev autodetect modconf block keyboard keymap filesystems"
 ```
 Add the  `shutdown`  hook like so:

 ```
 HOOKS="base udev autodetect modconf block keyboard keymap filesystems shutdown"
 ```
 Afterwards, regenerate the initramfs as follows:

 ```
 sudo mkinitcpio -P
 ```

 Upon reboot and a 2nd shutdown, the problem seems to go away. The developers (either archlinux or systemd) might want to check to ensure this is a regression or intended behavior.

#

## Speed up systemD shut down

```bash
sudo nano /etc/mkinitcpio.conf
```
ADD `shutdown` to the end of the following line:
```bash
HOOKS=(base udev autodetect kms modconf block keyboard keymap consolefont kms plymouth filesystems shutdown)
```
Then you must execute:
```bash
sudo mkinitcpio -P

```
#
## Stop coredumps
```bash
sudo mkdir /etc/systemd/coredump.conf.d/
sudo nano /etc/systemd/coredump.conf.d/custom.conf
```

ADD:
```bash
[Coredump]
Storage=none
ProcessSizeMax=0
```
#
## Cleanup journal / Vaccum journal events
Works good on Arch (bigLinux)
Clear jounal cruft
```bash
sudo journalctl --rotate;sudo journalctl --vacuum-time=1s
```
#
## Improve journal and systemD speed
```bash
sudo nano /etc/systemd/journald.conf
```
ADD:
```bash
SystemMaxUse=80M
SystemKeepFree=75M
MaxLevelStore=warning
MaxLevelSyslog=warning
MaxLevelKMsg=warning
MaxLevelConsole=notice
MaxLevelWall=crit
ForwardToWall=no
```
#
## Better latency
```bash
sudo nano /etc/tmpfiles.d/better-lattency.conf
```
ADD:
```bash
# w /sys/kernel/mm/transparent_hugepage/khugepaged/defrag - - - - 0
w /sys/kernel/mm/transparent_hugepage/khugepaged/defrag - - - - defer+madvise
```



## Create custom partitions 


note: if you go for "Advanced Custom (Blivet-GUI)" then ve sure to create at least the 3 partitions:

### Partition 1:
type: Standard partition
Filesystem: ext4
Size: 2 Gib (good)
Mount point:
/boot 

### Partition 2:
type: Standard partition
Filesystem: efisystem
Size: 2 Gib (good)
Mount point:
/boot/efi

### Partition 3:
type: Btrfs volume
Size: As much as desired. (30 Gib, 40, 100..)
Mount point:
/

* The efi partition is only required if your device supports efi otherwise if only BIOS then don't create it.









##  Create a keyboard shortcut to suspend Fedora

To create a keyboard shortcut to suspend Fedora, you can use the following steps:

1. **Open Keyboard Settings:**
   - Go to "Activities" (top-left corner) and search for "Settings".
   - In Settings, click on "Keyboard Shortcuts".

2. **Add Custom Shortcut:**
   - Scroll down to the bottom of the list of keyboard shortcuts and click on the "+" icon to add a new custom shortcut.

3. **Fill in Shortcut Details:**
   - In the "Name" field, you can enter a name for your shortcut, for example, "Suspend".
   - In the "Command" field, enter the command `systemctl suspend`.
   - Click on "Set Shortcut" and press the desired key combination you want to use to trigger the suspend action. For example, you might choose something like Ctrl+Alt+S.

4. **Test the Shortcut:**
   - Once you've set up the shortcut, test it out by pressing the key combination you assigned. Your Fedora system should go into suspend mode.


```bash
systemctl suspend
```

## NetworkManger show connections via cli..
```bash
 nmcli connection show
```

## Setting up git
```bash
git config --global user.email "kingtolga@gmail.com"
git config --global user.name "Tolga Erok"
DATE=`date '+%Y-%m-%d %H:%M:%S'`
git add .
git commit -a -m "new backup $DATE"
git push origin main
git push --tags
```

## Cron Jobs
```bash
# A crontab file that runs x.sh every five minues
#min hour date mon wkday command
*/5  *    *    *   *     /path/to/x.sh
```

## Setting up earlyloom Ubuntu / Debian
For Debian 10+ and Ubuntu 18.04+, there's a Debian package: ``` https://packages.debian.org/search?keywords=earlyoom ```
```bash
sudo apt install earlyoom
sudo systemctl enable --now earlyoom
systemctl status earlyoom

```
* Configuration file
If you are running earlyoom as a system service (through systemd or init.d), you can adjust its configuration via the file provided in /etc/default/earlyoom. The file already contains some examples in the comments, which you can use to build your own set of configuration based on the supported command line options, for example:

```bash
EARLYOOM_ARGS="-m 5 -r 60 --avoid '(^|/)(init|Xorg|ssh)$' --prefer '(^|/)(java|chromium)$'"
```
* After adjusting the file, simply restart the service to apply the changes. For example, for systemd:
```bash
systemctl restart earlyoom
```
Please note that this configuration file has no effect on earlyoom instances outside of systemd/init.d.


## Setting up zram Ubunut
Step 1
Note: run all the commands below in the terminal, copying them one line at a time and hitting enter. Make sure they are copied correctly.

First check if you have a swap file by running 
```bash
free -h
```
 If you do have a swap file, continue to the next step. Otherwise run the code below.
```bash
sudo su 
fallocate -l 4G /swapfile 
chmod 600 /swapfile 
mkswap /swapfile 
swapon /swapfile 
echo '/swapfile none swap sw 0 0' | tee -a /etc/fstab
```
Step 2
Run 
```bash
sudo nano /etc/default/grub 
```
and edit the line GRUB_CMDLINE_LINUX_DEFAULT to read:
```bash
GRUB_CMDLINE_LINUX_DEFAULT="quiet splash zswap.enabled=1 zswap.compressor=lz4 zswap.max_pool_percent=50 zswap.zpool=z3fold"
```
* What does the max pool percent variable mean? This refers to the maximum % of your RAM that will be taken up with compressed storage. It is dynamically allocated, so it doesn’t take up any space until you actually start using it. For most systems, 50% is a good maximum. For really low memory systems, you can try 70%. Anything higher will make the system unusably slow (Google has actually benchmarked this for Chrome OS).

Save your changes (type Ctrl+X and type y and then enter). Now run:
```bash
sudo update-grub
```
Step 3
Run the following:
```bash
sudo su
echo lz4 >> /etc/initramfs-tools/modules 
echo lz4_compress >> /etc/initramfs-tools/modules 
echo z3fold >> /etc/initramfs-tools/modules 
update-initramfs -u
```
You are done! Reboot and run 
```bash
cat /sys/module/zswap/parameters/enabled
```
If zswap is working, you should see a Y printed.

## Setup zram Debian
```bash
https://wiki.debian.org/ZRam
```
## Fix systemd-sysctl.service failed to start apply kernel variables [ Fedora 39 ]
```bash
    sudo dnf reinstall systemd
    reboot
    sudo ausearch -m avc
    sudo setenforce 0
    sudo restorecon -Rv /usr/lib/sysctl.d/
    sudo restorecon -Rv /etc/sysctl.d/
    sudo ausearch -m avc
    sudo dnf update selinux-policy
    sudo setenforce 1
    ls -l $(command -v chcon)
    sudo semodule -l | grep chcon
    sudo seinfo -t | grep chcon
    sudo ausearch -m avc --msg 1701697374.564:195
    sudo semodule -l | grep chcon
    sudo ausearch -m avc -ts recent
    sudo cat /var/log/audit/audit.log | grep chcon
    ls -lZ $(command -v chcon)
    sudo restorecon $(command -v chcon)
    sudo getsebool -a | grep mac_admin
    sudo setsebool -P mac_admin=1
    sudo dnf update
    sudo getsebool -a | grep mac_admin
    sudo setenforce 0
    sudo ausearch -m avc
    sudo restorecon -v $(command -v chcon)
    sudo semodule -l | grep mac_admin
    sudo reboot
```
## Create Chrome desktop shortcut to execute in X11 when in Wayland session
```bash
[Desktop Entry]
Categories=Network;WebBrowser;
Comment[en_AU]=Access the Internet
Comment=Access the Internet
Exec=GDK_BACKEND=x11 google-chrome --use-cmd-decoder=validating --use-gl=desktop %U
GenericName[en_AU]=Web Browser
GenericName=Web Browser
Icon=google-chrome
MimeType=video/webm;text/html;image/png;image/jpeg;image/gif;audio/webm;application/xml;application/xml;application/xhtml+xml;application/vnd.mozilla.xul+xml;application/rss+xml;application/rdf+xml;
Name[en_AU]=Google Chrome x11 Wayland Nvidia
Name=Google Chrome x11 Wayland Nvidia
Path=
StartupNotify=true
StartupWMClass=google-chrome
Terminal=false
TerminalOptions=
Type=Application
Version=1.0
X-KDE-SubstituteUID=false
X-KDE-Username=
X-MultipleArgs=false
```
## Super I/O scheduler [ Not persistent across reboot ]
```bash
#!/bin/bash
# Tolga Erok
# I/O scheduler for SSD tweak

clear

# Prompt user
echo -e "\e[93mDo you want to apply the scheduler to \e[92mNONE\e[93m? (yes/no)\e[0m"
read -r response

# Convert the response to lowercase for case-insensitive
response_lower=$(echo "$response" | tr '[:upper:]' '[:lower:]')

# Check if the user's response is a variation of "yes"
if [[ "$response_lower" == "y" || "$response_lower" == "yes" ]]; then
    # Run the command with sudo
    # Options none mq-deadline kyber bfq
    echo "none" | sudo tee /sys/block/sda/queue/scheduler
    echo -e "\e[92mScheduler applied successfully.\e[0m\n"
    cat /sys/block/sda/queue/scheduler
    sleep 3

    echo -e "\e[93m\n Enable and status of earlyloom: \e[0m\n"
    sudo systemctl enable --now earlyoom
    systemctl status earlyoom

    echo -e "\e[93m\n Available kernel congestion control: \e[0m"
    sysctl net.ipv4.tcp_available_congestion_control

    echo -e "\e[93m\nCurrent congestion control: \e[0m"
    sysctl net.ipv4.tcp_congestion_control

    exit
fi

# Close the terminal window
exit
```
## Run from remote location [ GitHub ]
```bash
sudo bash -c "$(curl -fsSL https://raw.githubusercontent.com/tolgaerok/tolga-scripts/main/Fedora39/TolgaFedora39.sh)"
```
## BIOS setup for G4-800-BIOS-NVME
```bash
BIOS Setup (F10) → Advance → System Options → Configure Storage Controller for Intel Optane.
No, not related with AHCI, but “disable Intel Optane” is a frequent tip on the forum as well.
```
## To run scripts @ login
Place script in prefered location i.e. /usr/local/bin/none.sh and set arguments to log errors: '>>' /tmp/none_script.log '2>&1'
```bash
sudo visudo
```
then add: 
```bash
yourusername ALL=(ALL) NOPASSWD: /path/to/your/script.sh
i.e. tolga ALL=(ALL) NOPASSWD: /usr/bin/systemctl, /usr/local/bin/none.sh

```
then create: 
```bash
touch ~/.profile
```

Create personal script in: /usr/local/bin/none.sh

```bash
#!/bin/bash
# tolga erok
# 10/12/2023.

export DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/$(id -u)/bus

# Reload user services
systemctl --user daemon-reload

# Enable and start the user service
systemctl --user enable --now tolga.service

# Restart the user service
systemctl --user restart tolga.service

# Log file path
LOG_FILE="$HOME/none_script.log"

# Function to log a message
log_message() {
    echo "$(date +"%Y-%m-%d %H:%M:%S") - $1" >>"$LOG_FILE"
}

# Password for privileged operations
PASSWORD="ibm450"

# Apply scheduler change without using sudo
echo "$PASSWORD" | sudo -S bash -c 'echo mq-deadline > /sys/block/sda/queue/scheduler' >/dev/null 2>&1

if [ $? -eq 0 ]; then
    log_message "Scheduler applied successfully."
else
    log_message "Failed to apply scheduler."
fi

# Display current scheduler
current_scheduler=$(cat /sys/block/sda/queue/scheduler)
log_message "Current scheduler: $current_scheduler"

# Display available kernel congestion control
log_message "Displaying available kernel congestion control..."
/usr/sbin/sysctl net.ipv4.tcp_available_congestion_control >>"$LOG_FILE"

# Display current congestion control
log_message "Displaying current congestion control..."
/usr/sbin/sysctl net.ipv4.tcp_congestion_control >>"$LOG_FILE"

# Wait for a moment
sleep 1
log_message "Script execution completed."

# Log the user executing the script
log_message "User executing the script: $(whoami)"
log_message "## ==================  EOF  ================== ##"

exit

```
## Create user systemd conf file

* Location:  /home/tolga/.config/systemd/user/tolga.service
* Saved as:  tolga.service
  
```bash
[Unit]
Description=Set i/o scheduler

[Service]
ExecStart=/usr/local/bin/none.sh

[Install]
WantedBy=default.target
```
## systemd
* Location:  /etc/systemd/system/tolga.service
* Saved as:  tolga.service
  
```bash
[Unit]
Description=Set i/o scheduler
After=network.target

[Service]
# Type=simple
Type=oneshot
# ExecStart=/usr/local/bin/none.sh
ExecStart=/bin/bash -c '/usr/local/bin/none.sh'
User=tolga
Group=tolga
# Restart=always

[Install]
WantedBy=default.target
```

## Start service

```bash
sudo systemctl daemon-reload
sudo systemctl enable --now tolga.service
sudo systemctl status tolga.service
systemctl --user daemon-reload
systemctl --user enable --now tolga.service
systemctl --user restart tolga.service
```

## Log file should look like this
```bash
2024-01-01 00:21:19 - Scheduler applied successfully.
2024-01-01 00:21:19 - Current scheduler: none [mq-deadline] kyber bfq 
2024-01-01 00:21:19 - Displaying available kernel congestion control...
net.ipv4.tcp_available_congestion_control = reno cubic westwood
2024-01-01 00:21:19 - Displaying current congestion control...
net.ipv4.tcp_congestion_control = westwood
2024-01-01 00:21:20 - Script execution completed.
2024-01-01 00:21:20 - User executing the script: tolga
2024-01-01 00:21:20 - ## ==================  EOF  ================== ##
```

## Create audio startup on login

* Location:  /home/tolga/.config/autostart
* Name:      startup.sh.desktop

```bash
[Desktop Entry]
Comment[en_AU]=
Comment=
Exec=/home/tolga/Music/startup.sh
Hidden=false
NoDisplay=false
GenericName[en_AU]=
GenericName=
Icon=dialog-scripts
MimeType=
Name[en_AU]=startup.sh
Name=startup.sh
Path=
StartupNotify=true
Terminal=false
TerminalOptions=
Type=Application
X-KDE-AutostartScript=true
X-KDE-SubstituteUID=false
X-KDE-Username=
```
* Location:  /home/tolga/Music/startup.sh
* Name:      startup.sh

```bash
#!/bin/bash

mpg123 /home/tolga/Music/darth_vader_breathe.mp3

exit
```





