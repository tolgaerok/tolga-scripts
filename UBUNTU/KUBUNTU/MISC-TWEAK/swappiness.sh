function set_swappiness() {
    local new_swappiness=1
    local old_swappiness
    old_swappiness=$(cat /proc/sys/vm/swappiness 2>/dev/null)

    log "INFO" "Starting swappiness configuration"

    local message="Configure system swappiness?\nCurrent: $old_swappiness\nRecommended: $new_swappiness"
    local options="Use recommended ($new_swappiness),Keep current ($old_swappiness),Enter custom value"
    prompt_user "choice" "$message" "" "$options"
    local choice="$REPLY"

    case $choice in
    1) # Use recommended
        ;;
    2) # Keep current
        new_swappiness="$old_swappiness"
        ;;
    3) # Custom value
        prompt_user "input" "Enter custom swappiness value" "$old_swappiness"
        new_swappiness="$REPLY"
        ;;
    esac

    if [[ "$new_swappiness" != "$old_swappiness" ]]; then
        (
            printf "vm.swappiness = %d" "$new_swappiness" | sudo tee /etc/sysctl.d/swapiness.conf >/dev/null
            sudo sysctl -p --system >/dev/null 2>&1
        ) &
        show_progress $! "Updating swappiness"
        log "INFO" "Swappiness updated to $new_swappiness"
    else
        log "INFO" "Swappiness unchanged"
    fi
}

set_swappiness
