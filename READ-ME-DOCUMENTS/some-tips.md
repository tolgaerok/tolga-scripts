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
i.e. tolga ALL=(ALL) NOPASSWD: /usr/local/bin/none.sh
```
then create: 
```bash
touch ~/.profile
```
then create autostart file: 
```bash
/home/tolga/.config/autostart/none.sh.desktop
```
Open with Kwrite and add:
```bash
[Desktop Entry]
Comment[en_AU]=
Comment=
Exec=/usr/local/bin/none.sh >> /tmp/none_script.log 2>&1
GenericName[en_AU]=
GenericName=
Icon=dialog-scripts
MimeType=
Name[en_AU]=none.sh
Name=none.sh
Path=
StartupNotify=true
Terminal=true
TerminalOptions=
Type=Application
X-KDE-AutostartScript=true
X-KDE-SubstituteUID=true
X-KDE-Username=tolga
```
Create personal script in: /usr/local/bin/none.sh
```bash
#!/bin/bash

# Function to display a desktop notification
show_notification() {
    notify-send "Script Notification" "$1"
}

# Apply scheduler
echo "none" | sudo tee /sys/block/sda/queue/scheduler
show_notification "Scheduler applied successfully."

# Display current scheduler
current_scheduler=$(cat /sys/block/sda/queue/scheduler)
show_notification "Current scheduler: $current_scheduler"

# Enable and display status of earlyoom
echo -e "\nEnable and status of earlyoom:\n"
echo "< PASSWORD >" | sudo -S systemctl enable --now earlyoom
sudo systemctl status earlyoom
show_notification "Earlyoom enabled successfully."

# Display available kernel congestion control
echo -e "\nAvailable kernel congestion control:"
sysctl net.ipv4.tcp_available_congestion_control

# Display current congestion control
echo -e "\nCurrent congestion control:"
sysctl net.ipv4.tcp_congestion_control

sleep 1
exit
```

Test by loging out then in

## Updated
* Location: /usr/local/bin/
* Saved as: none.sh
```bash
#!/bin/bash

# Log file path
LOG_FILE="$HOME/none_script.log"

# Function to log a message
log_message() {
    echo "$(date +"%Y-%m-%d %H:%M:%S") - $1" >> "$LOG_FILE"
}

# Function to display a desktop notification
show_notification() {
    DISPLAY=:0 notify-send "Script Notification" "$1"
}

# Password
PASSWORD="ibm450"

# Apply scheduler
echo "ibm450" | sudo -S sh -c 'echo none > /sys/block/sda/queue/scheduler' > /dev/null 2>&1

if [ $? -eq 0 ]; then
    show_notification "Scheduler applied successfully."
    log_message "Scheduler applied successfully."
else
    show_notification "Failed to apply scheduler."
    log_message "Failed to apply scheduler."
fi

# Display current scheduler
current_scheduler=$(cat /sys/block/sda/queue/scheduler)
show_notification "Current scheduler: $current_scheduler"
log_message "Current scheduler: $current_scheduler"

# Enable and display status of earlyoom
#log_message "Enabling and checking status of earlyoom..."
#echo "$PASSWORD" | sudo -S /usr/bin/systemctl enable --now earlyoom > >(tee -a "$LOG_FILE") 2> >(tee -a "$LOG_FILE" >&2)
#if [ $? -eq 0 ]; then
 #   show_notification "Earlyoom enabled successfully."
  #  log_message "Earlyoom enabled successfully."
#else
 #   show_notification "Failed to enable Earlyoom."
 #   log_message "Failed to enable Earlyoom."
#fi

# Display available kernel congestion control
log_message "Displaying available kernel congestion control..."
/usr/sbin/sysctl net.ipv4.tcp_available_congestion_control >> "$LOG_FILE"

# Display current congestion control
log_message "Displaying current congestion control..."
/usr/sbin/sysctl net.ipv4.tcp_congestion_control >> "$LOG_FILE"

# Wait for a moment
sleep 1
log_message "Script execution completed."
exit
```
## systemd
* Location: /etc/systemd/system/tolga.service
* Saved as: tolga.service
```bash
[Unit]
Description=Set i/o scheduler
After=network.target

[Service]
Type=simple
ExecStart=/usr/local/bin/none.sh
User=tolga
Group=tolga
Restart=always

[Install]
WantedBy=default.target
```
## Start service
```bash
sudo systemctl daemon-reload
sudo systemctl enable --now tolga.service
sudo systemctl start tolga.service
systemctl --user restart tolga.service
sudo systemctl status tolga.service
```









