#

<h1 align="center">
   The Ultimate Distrobox / Docker / BoxBuddy Cheat Sheet 
</h1>



Distrobox is a program that lets you run almost any Linux distro in a terminal. This means you can install apps from Fedora, Ubuntu, and Arch without a dual boot or a VM, and run them as if they were running natively! I tested it to run MegaSync and SublimeText, and it works pretty well, if a bit finicky to set up. 

## Steps I followed: 

### Install docker: 
```bash
sudo eopkg it docker
sudo systemctl start docker.service
sudo systemctl enable docker.service
```
### Install distrobox without root: 
```bash
curl -s https://raw.githubusercontent.com/89luca89/distrobox/main/install | sh -s -- --prefix ~/.local
```
Create docker user group and add current user to it: 
```bash
sudo groupadd docker
sudo usermod -aG docker $USER
```
Add these lines to .bashrc so DIstrobox will be in your path and you can run graphical applications: 
```bash
export PATH="$PATH:$HOME/local/bin"
xhost +si:localuser:$USER
```
Follow the instructions on Github to create and enter a new container. Then you can run commands for the native distro and install whatever you want (just exercise care).

## BOXBUDDY  - Allowing Filesystem Access via the Command Line 

You will need to determine if BoxBuddy is a user-level or system-level flatpak. 
To do this, execute: 
```bash
flatpak list –columns=app,installation | grep boxbuddyrs 
```
This should say either “user” or “system”. 

If you have BoxBuddy as a user-level flatpak, execute: 
```bash
flatpak override –user io.github.dvlv.boxbuddyrs –filesystem=home 
```
If BoxBuddy is instead a system-level flatpak, execute: 
```bash
sudo flatpak override io.github.dvlv.boxbuddyrs –filesystem=home 
```
**_To allow host access instead, change –filesystem=home to –filesystem=host above._** 

### Removing Filesystem Access via the Command Line 

After creating your Box with a custom home directory, you may wish to remove filesystem permissions again. 

If you have BoxBuddy as a user-level flatpak, execute: 
```bash
flatpak override –user –reset io.github.dvlv.boxbuddyrs 
```
If BoxBuddy is instead a system-level flatpak, execute: 
```bash
sudo flatpak override –reset io.github.dvlv.boxbuddyrs
```
