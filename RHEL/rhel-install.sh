#################################
#	Install Rpm Fusions	#
#################################
sudo dnf install --nogpgcheck https://dl.fedoraproject.org/pub/epel/epel-release-latest-$(rpm -E %rhel).noarch.rpm
sudo dnf install --nogpgcheck https://mirrors.rpmfusion.org/free/el/rpmfusion-free-release-$(rpm -E %rhel).noarch.rpm https://mirrors.rpmfusion.org/nonfree/el/rpmfusion-nonfree-release-$(rpm -E %rhel).noarch.rpm
sudo dnf groupupdate core
sudo subscription-manager repos --enable codeready-builder-for-rhel-9-$(arch)-rpms
sudo dnf install https://dl.fedoraproject.org/pub/epel/epel-release-latest-9.noarch.rpm

#################################
#	Install Flatpak		#
#################################
sudo yum install flatpak
sudo flatpak remote-add --if-not-exists rhel https://flatpaks.redhat.io/rhel.flatpakrepo

###################################
#	Subscription manager refresh  #
###################################
sudo subscription-manager refresh
sudo dnf clean all
sudo rm -r /var/cache/dnf
sudo dnf upgrade

#################################
#	Install samba		#
#################################
#sudo dnf -y install samba
sudo dnf install samba samba-common samba-client -y
sudo groupadd samba
sudo useradd -m tolga
sudo smbpasswd -a tolga
sudo usermod -aG samba tolga
sudo  mkdir /home/RHEL-9
sudo  chgrp samba /home/RHEL-9
sudo  chmod 770 /home/RHEL-9
sudo  restorecon -R /home/RHEL-9
sudo setsebool -P samba_enable_home_dirs on
sudo firewall-cmd --add-service=samba --permanent
sudo firewall-cmd --reload
sudo mkdir /var/lib/samba/usershares
sudo groupadd -r sambashare
sudo chown root:sambashare /var/lib/samba/usershares
sudo chmod 1770 /var/lib/samba/usershares
sudo restorecon -R /var/lib/samba/usershares
sudo gpasswd sambashare -a tolga
sudo usermod -aG sambashare tolga
 
#################################
#	Edit Fstab		#
#################################     
sudo cp /etc/fstab /etc/fstab.bak
sudo sh -c 'echo "//192.168.0.3/LinuxData /mnt/linux-data cifs credentials=/etc/samba/credentials,uid=tolga,gid=samba,file_mode=0777,dir_mode=0777,x-systemd.idle-timeout=0 0 0" >> /etc/fstab'
sudo sh -c 'echo "//192.168.0.3/LinuxData/HOME/tolga /media/w11-home cifs credentials=/etc/samba/credentials,uid=tolga,gid=samba,file_mode=0777,dir_mode=0777,x-systemd.idle-timeout=0 0 0" >> /etc/fstab'
sudo sh -c 'echo "//192.168.0.3/LinuxData/BUDGET-ARCHIVE/ /media/Budget-Archives cifs credentials=/etc/samba/credentials,uid=tolga,gid=samba,file_mode=0777,dir_mode=0777,x-systemd.idle-timeout=0 0 0" >> /etc/fstab'
sudo sh -c 'echo "//192.168.0.3/WINDOWSDATA /mnt/windows-data cifs credentials=/etc/samba/credentials,uid=tolga,gid=samba,file_mode=0777,dir_mode=0777,x-systemd.idle-timeout=0 0 0" >> /etc/fstab'

sudo systemctl daemon-reload
        
#################################
#	Install Nvidia	           	#
#################################
sudo dnf install kernel-devel-$(uname -r) kernel-headers-$(uname -r) gcc make dkms acpid libglvnd-glx libglvnd-opengl libglvnd-devel pkgconfig
sudo dnf config-manager --add-repo http://developer.download.nvidia.com/compute/cuda/repos/rhel9/$(uname -i)/cuda-rhel9.repo
sudo dnf makecache
sudo dnf module install nvidia-driver:latest-dkms
sudo reboot
lsmod | grep nvidia
lsmod | grep nouveau
nvidia-smi

#################################
#	Install Misc	           	#
#################################
sudo dnf install p7zip p7zip-plugins

#################################
#	Install KDE   	           	#
#################################
sudo dnf -y install https://dl.fedoraproject.org/pub/epel/epel-release-latest-9.noarch.rpm
sudo dnf update -y
subscription-manager repos --enable codeready-builder-for-rhel-9-$(arch)-rpms
sudo dnf -y groupinstall "KDE Plasma Workspaces" "base-x"
