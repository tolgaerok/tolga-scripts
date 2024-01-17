### -------------------------------------------------- ###
### Personal Nvidia mod to install nvidia 535x on fedora
### -------------------------------------------------- ###
# - Tolga Erok
# - 13/1/2024

# ------------------------------------------|       Instruction             |------------------------------------------------------ ###

# Install my online post installer that includes Nvidia drivers. This will create 2 desktop shortcuts.

# Copy & paste into knosole.
# bash -c "$(curl -fsSL https://raw.githubusercontent.com/tolgaerok/tolga-scripts/main/Fedora39/setup.sh)"

# Find 2 desktop icons, double click on the GREEN square icon and follow the prompts

# Allow it do its thing to set up all the dependencies required to execute my script.
# Once done, make sure you run the following in this order:

# - Option 1, configure faster dnf updates
# - Option 3, Update the system
# - Option 2, Install RPM Fusion repositories
# - Option 8, Install H/W Video Acceleration for AMD or Intel
# - Option 5, Install Nvidia / AMD GPU drivers

# This will take some time as it will install the required libaries and CUDA dependencies. Once complete, execute the following:

# sudo systemctl enable --now akmods --force && sudo dracut --force && echo && echo "Force akmods and Dracut on nvidia done" && echo

# Wait for 3 mins ( This allow's the kernel to compile the new drivers ) then [ Reboot ]

# ------------------------------------------|       DOWNGRADE 545x to 535x    |------------------------------------------------------ ###

sudo dnf remove \*nvidia\* --exclude nvidia-gpu-firmware
sudo dnf install akmod-nvidia-535.129.03\* xorg-x11-drv-nvidia-cuda-535.129.03\* nvidia\*535.129.03\*
sudo systemctl enable nvidia-{suspend,resume,hibernate}
sudo systemctl enable --now akmods --force && sudo dracut --force && echo && echo "Force akmods and Dracut on nvidia done" && echo

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

sudo systemctl enable --now akmods --force && sudo dracut --force && echo && echo "Force akmods and Dracut on nvidia done" && echo
sudo nano /etc/dnf/dnf.conf

# Copy and paste into dnf.conf but REMOVE the # in front of the exclude=akmod-nvidia* ........

# Exclude all nvidia-*, dont want anything later then 535x
# exclude=akmod-nvidia*3:545* nvidia-modprobe*3:545* nvidia-persistenced*3:545* nvidia-settings*3:545* nvidia-xconfig*3:545* xorg-x11-drv-nvidia-cuda-libs*3:545* xorg-x11-drv-nvidia-cuda*3:545* xorg-x11-drv-nvidia-kmodsrc*3:545* xorg-x11-drv-nvidia-libs*3:545* xorg-x11-drv-nvidia-power*3:545* xorg-x11-drv-nvidia*3:545*

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

# Exclude all nvidia-*, dont want anything later then 535x
# exclude=akmod-nvidia*3:545* nvidia-modprobe*3:545* nvidia-persistenced*3:545* nvidia-settings*3:545* nvidia-xconfig*3:545* xorg-x11-drv-nvidia-cuda-libs*3:545* xorg-x11-drv-nvidia-cuda*3:545* xorg-x11-drv-nvidia-kmodsrc*3:545* xorg-x11-drv-nvidia-libs*3:545* xorg-x11-drv-nvidia-power*3:545* xorg-x11-drv-nvidia*3:545*

# Or copy and paste into termainal after fresh install of Fedora then reun update

# Define the path to the DNF configuration file
# DNF_CONF_PATH="/etc/dnf/dnf.conf"

# display_message "[${GREEN}✔${NC}]  Configuring faster updates in DNF..."

# Check if the file exists before attempting to edit it
# if [ -e "$DNF_CONF_PATH" ]; then
# Backup the original configuration file
# sudo cp "$DNF_CONF_PATH" "$DNF_CONF_PATH.bak"

# Use sudo to edit the DNF configuration file with nano
# sudo nano "$DNF_CONF_PATH" <<EOL
# [main]
# gpgcheck=True
# installonly_limit=3
# clean_requirements_on_remove=True
# best=False
# skip_if_unavailable=True
# fastestmirror=True
# max_parallel_downloads=10
# color=always
# deltarpm=True
# keepcache=True
# metadata_timer_sync=0
# metadata_expire=6h
# metadata_expire_filter=repo:base:2h
# metadata_expire_filter=repo:updates:12h

# Exclude all nvidia-*, dont want anything later then 535x
# exclude=akmod-nvidia*3:545* nvidia-modprobe*3:545* nvidia-persistenced*3:545* nvidia-settings*3:545* nvidia-xconfig*3:545* xorg-x11-drv-nvidia-cuda-libs*3:545* xorg-x11-drv-nvidia-cuda*3:545* xorg-x11-drv-nvidia-kmodsrc*3:545* xorg-x11-drv-nvidia-libs*3:545* xorg-x11-drv-nvidia-power*3:545* xorg-x11-drv-nvidia*3:545*
# EOL

# Disable kernel update - optional
# --------------------------------------------------------------------
# Disable kernel updates from [fedora] and [updates] repos
# ---------------------------------------------------------------------

# --- First step ------- #
# sudo nano /etc/yum.repos.d/fedora.repo file. 
# Add exclude=kernel* at the bottom of this section
# [fedora]
#name=Fedora $releasever - $basearch
# .... 
# exclude=kernel*

# --- Second step ------- #
#  sudo nano /etc/yum.repos.d/fedora-updates.repo
# Add exclude=kernel* at the bottom of this section
# [updates]
# ... 
# exclude=kernel*
