# Original

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

# Ver 2

```
# Add the Negativo17 NVIDIA repository
sudo dnf config-manager --add-repo=https://negativo17.org/repos/fedora-nvidia.repo

# Install RPM Fusion repositories (free and nonfree) in one go
RPMFUSION_URLS=(
    "https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm"
    "https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm"
)
sudo dnf install -y "${RPMFUSION_URLS[@]}"

# Enable Cisco H264 support
sudo dnf config-manager --enable fedora-cisco-openh264

# Update system's core packages
sudo dnf update -y @core

# Remove any nvidia drivers first
sudo yum -y remove *nvidia*

# Install NVIDIA drivers and related packages
NVIDIA_PACKAGES=(
    "akmod-nvidia"
    "xorg-x11-drv-nvidia-cuda" # Optional for CUDA/NVDEC/NVENC support
    "nvidia-driver"
    "nvidia-settings"
    "nvidia-driver-libs.i686"
)
sudo dnf install -y "${NVIDIA_PACKAGES[@]}"

# List Nvidia packages installed

for i in $(rpm -ql nvidia-driver-libs.x86_64 nvidia-driver-cuda-libs.x86_64 | grep \.so); do
    strings $i | grep nvidia-modprobe >/dev/null && echo $i
done

sleep 4

# Install DNF5 and its plugins
sudo dnf install -y dnf5
sudo dnf5 install -y dnf5 dnf5-plugins

# Update the system with DNF5 and refresh the cache
sudo dnf5 update -y && sudo dnf5 makecache
```
