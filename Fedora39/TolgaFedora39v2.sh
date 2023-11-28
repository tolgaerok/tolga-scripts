#!/bin/bash

# Tolga Erok.
# My personal Fedora 39 KDE tweaker
# 18/11/2023

# Run from remote location:::.
# sudo bash -c "$(curl -fsSL https://raw.githubusercontent.com/tolgaerok/tolga-scripts/main/Fedora39/TolgaFedora39v2.sh)"

#  ¯\_(ツ)_/¯
#    █████▒▓█████ ▓█████▄  ▒█████   ██▀███   ▄▄▄
#  ▓██   ▒ ▓█   ▀ ▒██▀ ██▌▒██▒  ██▒▓██ ▒ ██▒▒████▄
#  ▒████ ░ ▒███   ░██   █▌▒██░  ██▒▓██ ░▄█ ▒▒██  ▀█▄
#  ░▓█▒  ░ ▒▓█  ▄ ░▓█▄   ▌▒██   ██░▒██▀▀█▄  ░██▄▄▄▄██
#  ░▒█░    ░▒████▒░▒████▓ ░ ████▓▒░░██▓ ▒██▒ ▓█   ▓██▒
#   ▒ ░    ░░ ▒░ ░ ▒▒▓  ▒ ░ ▒░▒░▒░ ░ ▒▓ ░▒▓░ ▒▒   ▓▒█░
#   ░       ░ ░  ░ ░ ▒  ▒   ░ ▒ ▒░   ░▒ ░ ▒░  ▒   ▒▒ ░
#   ░ ░       ░    ░ ░  ░ ░ ░ ░ ▒    ░░   ░   ░   ▒
#   ░  ░      ░    ░ ░     ░              ░  ░   ░

clear

# Assign a color variable based on the RANDOM number
RED='\e[1;31m'
GREEN='\e[1;32m'
YELLOW='\e[1;33m'
BLUE='\e[1;34m'
CYAN='\e[1;36m'
WHITE='\e[1;37m'
ORANGE='\e[1;93m'
NC='\e[0m' # Keep this line only once

# Function to fetch and execute a script from a remote URL
function execute_remote_script() {
    execute_remote_script=$1
    script_url="https://raw.githubusercontent.com/tolgaerok/tolga-scripts/main/Fedora39/remote-assets/$execute_remote_script"
    bash -c "$(curl -fsSL $script_url)"
}

# Function to display the main menu
display_main_menu() {
    clear
    echo -e "\n                  Tolga's online Fedora updater\n"
    echo -e "\e[34m|--------------------------|\e[33m Main Menu \e[34m |-------------------------------------|\e[0m"
    echo -e "\e[33m 1.\e[0m \e[32m Configure faster updates in DNF\e[0m"
    echo -e "\e[33m 2.\e[0m \e[32m Install RPM Fusion repositories\e[0m"
    echo -e "\e[33m 3.\e[0m \e[32m Update the system                 ( Create meta cache etc )\e[0m"
    echo -e "\e[33m 4.\e[0m \e[32m Install firmware updates          ( Not compatible with all systems )\e[0m"
    echo -e "\e[33m 5.\e[0m \e[32m Install Nvidia / AMD GPU drivers  ( Auto scan and install )\e[0m"
    echo -e "\e[33m 6.\e[0m \e[32m Optimize battery life\e[0m"
    echo -e "\e[33m 7.\e[0m \e[32m Install multimedia codecs\e[0m"
    echo -e "\e[33m 8.\e[0m \e[32m Install H/W Video Acceleration for AMD or Intel\e[0m"
    echo -e "\e[33m 9.\e[0m \e[32m Update Flatpak\e[0m"
    echo -e "\e[33m 10.\e[0m \e[32mSet UTC Time\e[0m"
    echo -e "\e[33m 11.\e[0m \e[32mDisable mitigations\e[0m"
    echo -e "\e[33m 12.\e[0m \e[32mEnable Modern Standby\e[0m"
    echo -e "\e[33m 13.\e[0m \e[32mEnable nvidia-modeset\e[0m"
    echo -e "\e[33m 14.\e[0m \e[32mDisable NetworkManager-wait-online.service\e[0m"
    echo -e "\e[33m 15.\e[0m \e[32mDisable Gnome Software from Startup Apps\e[0m"
    echo -e "\e[33m 16.\e[0m \e[32mChange hostname                   ( Change current localname/pc name )\e[0m"
    echo -e "\e[33m 17.\e[0m \e[32mCheck mitigations=off in GRUB\e[0m"
    echo -e "\e[33m 18.\e[0m \e[32mInstall additional apps\e[0m"
    echo -e "\e[33m 19.\e[0m \e[32mCleanup Fedora\e[0m"
    echo -e "\e[33m 20.\e[0m \e[32mFix Chrome HW accelerations issue ( No guarantee )\e[0m"
    echo -e "\e[33m 21.\e[0m \e[32mDisplay XDG session\e[0m"
    echo -e "\e[33m 22.\e[0m \e[32mFix grub or rebuild grub          ( Checks and enables menu output to grub menu )\e[0m"
    echo -e "\e[33m 23.\e[0m \e[32mInstall new DNF5                  ( Testing for fedora 40/41 )\e[0m"
    echo -e "\e[34m|-------------------------------------------------------------------------------|\e[0m"
    echo -e "\e[31m   (0) \e[0m \e[32mExit\e[0m"
    echo -e "\e[34m|-------------------------------------------------------------------------------|\e[0m"
    echo ""

}

# Function to handle user input
handle_user_input() {

    # Get the hostname and username
    hostname=$(hostname)
    username=$(whoami)

    echo -e "${YELLOW}┌──($username㉿$hostname)-[$(pwd)]${NC}"

    choice=""
    echo -n -e "${YELLOW}└─\$>>${NC} "
    read choice

    echo ""
    case "$choice" in
    1) execute_remote_script "configure_dnf.sh" ;;
    2) execute_remote_script "install_rpmfusion.sh" ;;
    3) execute_remote_script "update_system.sh" ;;
    4) execute_remote_script "install_firmware.sh" ;;
    5) execute_remote_script "install_gpu_drivers.sh" ;;
    6) execute_remote_script "optimize_battery.sh" ;;
    7) execute_remote_script "multimedia.sh" ;;
    8) execute_remote_script "install_hw_video_acceleration_amd_or_intel.sh" ;;
    9) execute_remote_script "update_flatpak.sh" ;;
    10) execute_remote_script "set_utc_time.sh" ;;
    11) execute_remote_script "disable_mitigations.sh" ;;
    12) execute_remote_script "enable_modern_standby.sh" ;;
    13) execute_remote_script "enable_nvidia_modeset.sh" ;;
    14) execute_remote_script "disable_network_manager_wait_online.sh" ;;
    15) execute_remote_script "disable_gnome_software_startup.sh" ;;
    16) execute_remote_script "change_hotname.sh" ;;
    17) execute_remote_script "check_mitigations_grub.sh" ;;
    18) execute_remote_script "install_apps.sh" ;;
    19) execute_remote_script "cleanup_fedora.sh" ;;
    20) execute_remote_script "fix_chrome.sh" ;;
    21) execute_remote_script "display_XDG_session.sh" ;;
    22) execute_remote_script "fix_grub.sh" ;;
    23) execute_remote_script "dnf5.sh" ;;
  
    0) exit ;;
    *)
        echo -e "Invalid choice. Please enter a number from 0 to 21."
        sleep 2
        ;;
    esac
}

# Main loop for the menu
while true; do
    display_main_menu
    handle_user_input
done
