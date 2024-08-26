```
sudo dnf config-manager --add-repo=https://negativo17.org/repos/fedora-nvidia.repo

sudo dnf install https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
sudo dnf config-manager --enable fedora-cisco-openh264
sudo dnf update @core
sudo dnf install akmod-nvidia # rhel/centos users can use kmod-nvidia instead
sudo dnf install xorg-x11-drv-nvidia-cuda #optional for cuda/nvdec/nvenc support
sudo dnf install xorg-x11-drv-nvidia-cuda

sudo dnf install dnf5 -y
sudo dnf5 install dnf5 dnf5-plugins
sudo dnf5 update && sudo dnf5 makecache


https://negativo17.org/nvidia-driver/

```
