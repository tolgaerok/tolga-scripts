## NetworkManger show connections via cli..
```bash
 nmcli connection show
```

## Setting up git
```bash
git config --global user.email "kingtolga@gmail.com"
git config --global user.name "Tolga Erok"
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
## Run from remote location [ GitHub ]
```bash
sudo bash -c "$(curl -fsSL https://raw.githubusercontent.com/tolgaerok/tolga-scripts/main/Fedora39/TolgaFedora39.sh)"
```
