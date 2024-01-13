### -------------------------------------------------- ###
### Personal Nvidia mod to install nvidia 535x on fedora
### -------------------------------------------------- ###
# - Tolga Erok
# - 13/1/2024

# ------------------------------------------|       Instruction             |------------------------------------------------------ ###
#
# Install nvidia drivers from my online script. This will create 2 desktop shortcuts.

# Copy & paste into knosole.
# bash -c "$(curl -fsSL https://raw.githubusercontent.com/tolgaerok/tolga-scripts/main/Fedora39/setup.sh)"

# Let it do its thing to set up all the dependencies to execute the script. Once done, make sure you run the following:

# - Option 3, Update the system
# - Option 1, configure faster dnf updates
# - Option 2, Install RPM Fusion repositories
# - Option 8, Install H/W Video Acceleration for AMD or Intel
# - Option 5, Install Nvidia / AMD GPU drivers
# - sudo systemctl enable --now akmods --force && sudo dracut --force && echo && echo \"Force akmods and Dracut on nvidia done\" && echo
# - Wait for 3 mins then Reboot ( Allow the kernel to compile the new drivers )

# ------------------------------------------|       DOWNGRADE 545x to 535x    |------------------------------------------------------ ###

sudo dnf remove \*nvidia\* --exclude nvidia-gpu-firmware
sudo dnf install akmod-nvidia-535.129.03\* xorg-x11-drv-nvidia-cuda-535.129.03\* nvidia\*535.129.03\*
sudo systemctl enable nvidia-{suspend,resume,hibernate}
sudo systemctl enable --now akmods --force && sudo dracut --force && echo && echo \"Force akmods and Dracut on nvidia done\" && echo

sudo dnf update --exclude="akmod-nvidia*3:545.29.06-1.fc39*" \
    --exclude="nvidia-modprobe*3:545.29.06-1.fc39*" \
    --exclude="nvidia-persistenced*3:545.29.06-1.fc39*" \
    --exclude="nvidia-settings*3:545.29.06-1.fc39*" \
    --exclude="nvidia-xconfig*3:545.29.06-1.fc39*" \
    --exclude="xorg-x11-drv-nvidia-cuda-libs*3:545.29.06-1.fc39*" \
    --exclude="xorg-x11-drv-nvidia-cuda*3:545.29.06-1.fc39*" \
    --exclude="xorg-x11-drv-nvidia-kmodsrc*3:545.29.06-1.fc39*" \
    --exclude="xorg-x11-drv-nvidia-libs*3:545.29.06-1.fc39*" \
    --exclude="xorg-x11-drv-nvidia-power*3:545.29.06-1.fc39*" \
    --exclude="xorg-x11-drv-nvidia*3:545.29.06-1.fc39*"

sudo sudo nvautoinstall rpmadd
sudo nvautoinstall driver
sudo nvautoinstall nvrepo
sudo nvautoinstall plcuda
sudo nvautoinstall ffmpeg
sudo nvautoinstall vulkan
sudo nvautoinstall vidacc
sudo nvautoinstall compat

sudo systemctl enable --now akmods --force && sudo dracut --force && echo && echo \"Force akmods and Dracut on nvidia done\" && echo
sudo nano /etc/dnf/dnf.conf

# Copy and paste into dnf.conf but REMOVE the # in front of the exclude=akmod-nvidia* ........

# Exclude all nvidia-*, dont want anything later then 535x
# exclude=akmod-nvidia* nvidia-modprobe* nvidia-persistenced* nvidia-settings* nvidia-xconfig* xorg-x11-drv-nvidia-cuda-libs* xorg-x11-drv-nvidia-cuda* xorg-x11-drv-nvidia-kmodsrc* xorg-x11-drv-nvidia-libs* xorg-x11-drv-nvidia-power* xorg-x11-drv-nvidia*

# Example:
# -------------------------------------------------- #
#	[main]
#	gpgcheck=True
#	installonly_limit=3
#	clean_requirements_on_remove=True
#	best=False
#	skip_if_unavailable=True
#	fastestmirror=True
#	max_parallel_downloads=10
#	color=always
#	deltarpm=true
#	keepcache=True
#	metadata_timer_sync=0
#	metadata_expire=6h
#	metadata_expire_filter=repo:base:2h
#	metadata_expire_filter=repo:updates:12h

#  # Exclude all nvidia-*, dont want anything later then 535x
#	exclude=akmod-nvidia* nvidia-modprobe* nvidia-persistenced* nvidia-settings* nvidia-xconfig* xorg-x11-drv-nvidia-cuda-libs* xorg-x11-drv-nvidia-cuda* xorg-x11-drv-nvidia-kmodsrc* xorg-x11-drv-nvidia-libs* xorg-x11-drv-nvidia-power* xorg-x11-drv-nvidia*
