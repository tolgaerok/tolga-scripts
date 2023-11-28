## NetworkManger show connections via cli
```bash
 nmcli connection show
```

## Setting up git
```bash
git config --global user.email "kingtolga@gmail.com"
git config --global user.name "Tolga Erok"
```
## Setting up zram Ubunut/Deb
Step 1
Note: run all the commands below in the terminal, copying them one line at a time and hitting enter. Make sure they are copied correctly.

First check if you have a swap file by running free -h. If you do have a swap file, continue to the next step. Otherwise run the code below.
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
What does the max pool percent variable mean? This refers to the maximum % of your RAM that will be taken up with compressed storage. It is dynamically allocated, so it doesn’t take up any space until you actually start using it. For most systems, 50% is a good maximum. For really low memory systems, you can try 70%. Anything higher will make the system unusably slow (Google has actually benchmarked this for Chrome OS).

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
