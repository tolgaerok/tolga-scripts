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

###---------- Nvidia session ----------###
export LIBVA_DRIVER_NAME=nvidia
export WLR_NO_HARDWARE_CURSORS=1
export __GLX_VENDOR_LIBRARY_NAME=nvidia
export __GL_SHADER_CACHE=1
export __GL_THREADED_OPTIMIZATION=1

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

alias btrfs-manage="btrfs_manage"

alias cl="clear"
# Search command line history
alias tolga-h="history | grep "

###---------- Tools ----------###
alias rc='source ~/.bashrc && clear && echo "" && fortune | lolcat  && echo ""'
alias tolga-bashrc='kwrite  ~/.bashrc'

# ┌───────────    konsole related    ───────────┐

PS1="\[\e[1;m\]┌(\[\e[1;32m\]\u\[\e[1;34m\]@\h\[\e[1;m\]) \[\e[1;m\]➤\[\e[1;36m\] \W \[\e[1;m\] \n\[\e[1;m\]└\[\e[1;33m\]➤\[\e[0;m\]  "

# └─────────────────────────────────────────────┘

# ┌───────────    vscode related     ───────────┐
eval "$(direnv hook bash)"
# └─────────────────────────────────────────────┘

alias fastfetch2='BLUEFIN_FETCH_LOGO=$(find $HOME/.config/fastfetch/logo2/* | /usr/bin/shuf -n 1) && rm -rf $HOME/.cache/fastfetch && /usr/bin/fastfetch --logo $BLUEFIN_FETCH_LOGO -c $HOME/.config/fastfetch/config.jsonc'

alias fastfetch3='BLUEFIN_FETCH_LOGO=$(find $HOME/.config/fastfetch/logo/* | /usr/bin/shuf -n 1) && rm -rf $HOME/.cache/fastfetch && /usr/bin/fastfetch --logo $BLUEFIN_FETCH_LOGO -c $HOME/.config/fastfetch/config.jsonc'

alias gitup="~/gitup.sh"

alias cake2='interface=$(ip link show | awk -F: '\''$0 ~ "wlp|wlo|wlx" && !($0 ~ "NO-CARRIER") {gsub(/^[ \t]+|[ \t]+$/, "", $2); print $2; exit}'\''); sudo systemctl daemon-reload && sudo systemctl restart apply-cake-qdisc.service && sudo tc -s qdisc show dev $interface && sudo systemctl status apply-cake-qdisc.service'

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
alias find="history | grep "
alias gitup="$HOME/gitup.sh"
alias rc='source ~/.bashrc && cl && echo "" && fortune | lolcat && echo "" && echo ""'
alias tolga-cong="sysctl net.ipv4.tcp_congestion_control"
alias tolga-io="cat /sys/block/sda/queue/scheduler"
alias tolga-io="tline && cat /sys/block/sda/queue/scheduler && bline"
alias tolga-sys="tline && echo && tolga-io && echo && tolga-cong && echo && echo 'ZSWAP status: ( Y = ON )' && cat /sys/module/zswap/parameters/enabled && bline"
alias tolga-trim="sudo fstrim -av"

cl && echo "" && fortune | lolcat && echo ""
