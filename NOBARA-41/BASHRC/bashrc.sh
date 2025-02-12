# .bashrc

# Source global definitions
if [ -f /etc/bashrc ]; then
    . /etc/bashrc
fi

# User specific environment
if ! [[ "$PATH" =~ "$HOME/.local/bin:$HOME/bin:" ]]; then
    PATH="$HOME/.local/bin:$HOME/bin:$PATH"
fi
export PATH

# Uncomment the following line if you don't like systemctl's auto-paging feature:
# export SYSTEMD_PAGER=

# User specific aliases and functions
if [ -d ~/.bashrc.d ]; then
    for rc in ~/.bashrc.d/*; do
        if [ -f "$rc" ]; then
            . "$rc"
        fi
    done
fi
unset rc

# ┌───────────────────────────────────────────────────────────────────────────────────────────────┐
# |                                          Nvidia session                                       |
# └───────────────────────────────────────────────────────────────────────────────────────────────┘
export LIBVA_DRIVER_NAME=nvidia
export WLR_NO_HARDWARE_CURSORS=1
export __GLX_VENDOR_LIBRARY_NAME=nvidia
export __GL_SHADER_CACHE=1
export __GL_THREADED_OPTIMIZATION=1

# ┌───────────────────────────────────────────────────────────────────────────────────────────────┐
# |                                          Custom alias                                         |
# └───────────────────────────────────────────────────────────────────────────────────────────────┘

# Define color codes
GREEN="\033[1;32m"
RED="\033[1;31m"
RESET="\033[0m"

alias tline='echo -e "\n${GREEN}┌───────────────────────────────────────────────────────────────────────────────────────────────┐ ${RESET}\n"'
alias bline='echo -e "\n${GREEN}└───────────────────────────────────────────────────────────────────────────────────────────────┘ ${RESET}\n"'

alias blue="tline && sudo systemctl status disable-bluetooth-before-sleep.service --no-pager || true && bline && echo "" && tline && sudo systemctl status enable-bluetooth-after-resume.service --no-pager || true && bline"
alias btrfs-manage="btrfs_manage"
alias cake2='interface=$(ip link show | awk -F: '\''$0 ~ /wlp|wlo|wlx/ && $0 !~ /NO-CARRIER/ {gsub(/^[ \t]+|[ \t]+$/, "", $2); print $2; exit}'\''); sudo systemctl daemon-reload && sudo systemctl restart apply-cake-qdisc.service && sudo systemctl restart apply-cake-qdisc-wake.service && tline && sudo tc -s qdisc show dev $interface && sudo systemctl status apply-cake-qdisc.service --no-pager || true && sudo systemctl status apply-cake-qdisc-wake.service --no-pager || true && bline'
alias check1="interface=\$(ip link show | awk -F: '\$0 ~ \"wlp|wlo|wlx\" && \$0 !~ \"NO-CARRIER\" {gsub(/^[ \t]+|[ \t]+$/, \"\", \$2); print \$2; exit}'); tline && sudo tc qdisc show dev \"\$interface\" && bline"
alias check2="tline && ~/check-interface.sh || true && bline"
alias cl="clear"
alias clear-temp="$HOME/clear-temp.sh"
# alias find="history | grep "
alias gitup="$HOME/gitup.sh"
alias rc='source ~/.bashrc && cl && echo "" && fortune | lolcat && echo "" && echo ""'
alias tolga-cong="sysctl net.ipv4.tcp_congestion_control"
alias tolga-io="cat /sys/block/sda/queue/scheduler"
alias tolga-io="tline && cat /sys/block/sda/queue/scheduler && bline"
alias tolga-sys="tline && echo && tolga-io && echo && tolga-cong && echo && echo 'ZSWAP status: ( Y = ON )' && cat /sys/module/zswap/parameters/enabled && bline"
alias tolga-trim="sudo fstrim -av"
alias ff='BLUEFIN_FETCH_LOGO=$(find $HOME/.config/fastfetch/logo/* | /usr/bin/shuf -n 1) && /usr/bin/fastfetch --logo $BLUEFIN_FETCH_LOGO -c $HOME/.config/fastfetch/config.jsonc'
alias flat="flatpak update --user && sudo flatpak update --system"

# Alias for Btrfs Frequent Maintenance (daily/weekly)
alias btrfsMaintFrequent='
echo "### Frequent Btrfs Maintenance ###";
sudo fstrim -v /; # Trim (inform SSD which blocks are free)
echo "--- Trim Completed ---";
# **Modified Balance Command for Safety**
sudo btrfs balance start -dusage=5 -musage=5 /;
echo "--- Balance Started (this may take some time, balancing data and metadata usage) ---";
# **Optional: Uncomment for periodic filesystem check (adjust frequency as needed)**
# sudo btrfs check --progress /
'
alias btrfsMaintInfrequent='
clear
echo "### Btrfs Infrequent Maintenance ###"
read -p "Start Background Scrub and optional Filesystem Check? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^([yY][eE][sS]|[yY]) ]]; then
    echo "Starting Scrub..."
    sudo btrfs scrub start -B /
    echo "Scrub started in background. Waiting for 5 minutes before checking status..."
    sleep 300
    sudo btrfs scrub status /
    read -p "Run Filesystem Check now? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^([yY][eE][sS]|[yY]) ]]; then
        sudo btrfs check --progress /dev/* # **Assuming / is on a single device, adjust as necessary**
    fi
fi
'
alias btrfsMaint='
echo "### Btrfs Maintenance: Trim, Scrub, Balance ###";

# Step 1: Trim (inform SSD which blocks are free)
sudo fstrim -v /;
echo "--- Trim Completed ---";

# Step 2: Start Scrub
echo "Starting Scrub...";
sudo btrfs scrub start -B /;
echo "Scrub started in background.";

# Step 3: Start Balance (if not already running)
echo "Checking if Balance is already running...";
if sudo btrfs balance status / | grep -q "No balance found"; then
    echo "Starting Balance...";
    sudo btrfs balance start -dusage=5 -musage=5 /;
    # Check if balance started successfully
    if [[ $? -eq 0 ]]; then
        echo "--- Balance Started (this may take some time, balancing data and metadata usage) ---";
    else
        echo "--- Failed to start Balance. Please check the system logs for more details. ---";
    fi
else
    echo "--- Balance is already in progress, skipping... ---";
fi
'

btrfs_manage() {
    clear
    echo ""
    echo "###---------- BTRFS TOOLS ----------######"
    echo "Choose an operation:"
    echo "1) Balance /home"
    echo "2) Balance /"
    echo "3) Scrub /home"
    echo "4) Scrub /"
    echo "5) Exit"
    read -p "Enter your choice [1-5]: " choice

    case $choice in
    1)
        echo "Starting balance on /home..."
        sudo btrfs balance start /home && sudo btrfs balance status /home
        ;;
    2)
        echo "Starting balance on /..."
        sudo btrfs balance start / && sudo btrfs balance status /
        ;;
    3)
        echo "Starting scrub on /home..."
        sudo btrfs scrub start /home && sudo btrfs scrub status /home
        ;;
    4)
        echo "Starting scrub on /..."
        sudo btrfs scrub start / && sudo btrfs scrub status /
        ;;
    5)
        echo "Exiting."
        return 0
        ;;
    *)
        echo "Invalid option. Please choose a number between 1 and 5."
        ;;
    esac
}

# Define color codes
GREEN="\033[1;32m"
RED="\033[1;31m"
RESET="\033[0m"

alias tline='echo -e "\n${GREEN}┌───────────────────────────────────────────────────────────────────────────────────────────────┐ ${RESET}\n"'
alias bline='echo -e "\n${GREEN}└───────────────────────────────────────────────────────────────────────────────────────────────┘ ${RESET}\n"'

alias check1="interface=\$(ip link show | awk -F: '\$0 ~ \"wlp|wlo|wlx\" && \$0 !~ \"NO-CARRIER\" {gsub(/^[ \t]+|[ \t]+$/, \"\", \$2); print \$2; exit}'); tline && sudo tc qdisc show dev \"\$interface\" && bline"
alias check2="tline && ~/check-interface.sh || true && bline"

alias cake2='interface=$(ip link show | awk -F: '\''$0 ~ "wlp|wlo|wlx" && !($0 ~ "NO-CARRIER") {gsub(/^[ \t]+|[ \t]+$/, "", $2); print $2; exit}'\''); syst && sudo systemctl daemon-reload && sudo systemctl restart apply-cake-qdisc.service && sudo tc -s qdisc show dev $interface && sudo systemctl status apply-cake-qdisc.service --no-pager && notify-send -i /$HOME/1.png -u normal -a "Checking interface" "CAKE protocol is present in:" "$interface"'
alias syst="sudo sysctl --load=/etc/sysctl.d/99-sysctl.conf && sudo sysctl --system && sudo udevadm control --reload-rules && sudo udevadm trigger"

alias restart-cake="sudo systemctl daemon-reload && \
sudo systemctl start apply-cake-qdisc.service && \
sudo systemctl start apply-cake-qdisc-wake.service && \
sudo systemctl enable apply-cake-qdisc.service && \
sudo systemctl enable apply-cake-qdisc-wake.service && \
sudo systemctl status apply-cake-qdisc.service --no-pager && \
echo \"\" && \
echo \"|-----------------------------------------------------------------------------------------------------|\" && \
echo \"\" && \
sudo systemctl status apply-cake-qdisc-wake.service --no-pager"

cl && echo "" && fortune | lolcat && echo "" && echo ""
