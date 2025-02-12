#!/usr/bin/env bash
# tolga

set -eu

# Helper function for logging
function log() {
    local level=$1
    local message=$2
    local timestamp
    timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    printf "[%b] [%b] %b\n" "$timestamp" "$level" "$message" >&2
}

# Helper function for showing progress
function show_progress() {
    local pid=$1
    local message=$2
    local spin='⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏'
    local i=0

    while kill -0 "$pid" 2>/dev/null; do
        i=$(( (i+1) % ${#spin} ))
        printf "\r[%b] %b..." "${spin:$i:1}" "$message"
        sleep 0.1
    done
    printf "\r✓ %b...done\n" "$message"
}

# Helper function for user prompt
function prompt_user() {
    local prompt_type="${1}"    # yes_no, choice, or input
    local message="${2}"
    local default="${3:-}"
    local options="${4:-}"        # For choice type

    # Display formatted message with visual separator
    printf "\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n"
    printf "🔹 %b\n" "$message"

    case "$prompt_type" in
        "yes_no")
            printf "[Y/n]: "
            read -r answer
            [[ -z "$answer" || "${answer,,}" == "y"* ]] && return 0 || return 1
            ;;
        "choice")
            IFS=',' read -ra choices <<< "$options"
            for i in "${!choices[@]}"; do
                printf "%d) %b\n" $((i+1)) "${choices[$i]}"
            done
            printf "Choose [1-%d]: " "${#choices[@]}"
            read -r REPLY
            printf "%b" "$REPLY"
            ;;
        "input")
            if [[ -n "$default" ]]; then
                printf "[default: %s]: " "$default"
            else
                printf ": "
            fi
            read -r input
            REPLY="${input:-$default}"
            printf "%s" "$REPLY"
            ;;
    esac
}

function remove_snapd() {
    log "INFO" "Starting snapd removal process"

    local installed_snaps
    installed_snaps=$(snap list 2>/dev/null | awk 'NR>1 {print $1}')

    # Show current status
    if [[ -n "$installed_snaps" ]]; then
        local message="The following snap packages are installed and will be removed:\n$installed_snaps"
    else
        local message="No snap packages are currently installed"
    fi
    message+="\n\n⚠️  Warning: This will completely remove snapd and all snap packages."

    if ! prompt_user "yes_no" "$message"; then
        log "INFO" "Snapd removal cancelled"
        return 0
    fi

    (
        log "INFO" "Stopping snapd services"
        sudo systemctl stop snapd.service snapd.socket snapd.seeded.service > /dev/null 2>&1

        log "INFO" "Removing snap packages"
        for snap in $(snap list 2>/dev/null | awk 'NR>1 {print $1}'); do
            log "INFO" "Removing snap package: $snap"
            sudo snap remove --purge "$snap" > /dev/null 2>&1
        done

        # Wait for snap processes
        while pgrep -a snap >/dev/null 2>&1; do
            sleep 1
        done

        log "INFO" "Unmounting snap volumes"
        for mnt in $(mount | grep snapd | cut -d' ' -f3 2>/dev/null); do
            sudo umount -l "$mnt" > /dev/null 2>&1 || true
        done

        log "INFO" "Removing snapd package and configuration"
        sudo apt -y remove --purge snapd > /dev/null 2>&1
        sudo apt -y autoremove --purge > /dev/null 2>&1

        log "INFO" "Removing snap directories and cache"
        sudo rm -rf \
            /var/cache/snapd/ \
            /var/lib/snapd/ \
            /var/snap/ \
            /snap/ \
            ~/snap/ > /dev/null 2>&1

        log "INFO" "Removing remaining configuration"
        sudo rm -rf \
            /etc/snap/ \
            /usr/lib/snapd/ \
            /usr/share/snapd/ \
            /usr/share/keyrings/snapd.gpg > /dev/null 2>&1

        log "INFO" "Configuring system to prevent snapd reinstallation"
        sudo tee /etc/apt/preferences.d/nosnap.pref > /dev/null <<'EOF'
Package: snapd
Pin: release a=*
Pin-Priority: -1
EOF

        # Handle Firefox replacement if needed
        if ! command -v firefox >/dev/null 2>&1 && prompt_user "yes_no" "Would you like to re-install Firefox from Mozilla PPA?"; then
            log "INFO" "Installing Firefox from Mozilla PPA"
            sudo add-apt-repository -y ppa:mozillateam/ppa > /dev/null 2>&1
            sudo tee /etc/apt/preferences.d/mozilla-firefox > /dev/null <<'EOF'
Package: *
Pin: release o=LP-PPA-mozillateam
Pin-Priority: 1001
EOF
            sudo apt update > /dev/null 2>&1
            sudo apt install -y firefox > /dev/null 2>&1
        fi

    ) & show_progress $! "Removing snapd and related components"

    log "INFO" "Snapd removal completed successfully"
    printf "\n💡 System changes made:\n"
    printf "   - All snap packages removed\n"
    printf "   - Snapd service and socket disabled\n"
    printf "   - Snapd package and configuration removed\n"
    printf "   - Snap directories cleaned up\n"
    printf "   - System configured to prevent snapd reinstallation\n"
    if command -v firefox >/dev/null 2>&1; then
        printf "   - Firefox installed from Mozilla PPA\n"
    fi
}


remove_snapd