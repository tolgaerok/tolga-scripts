#!/bin/bash
# Tolga Erok
# 27/2/2025

sleep 2  # Delay to ensure GNOME is fully started

# Get a list of currently enabled extensions
enabled_extensions=$(gnome-extensions list --enabled)

# Disable each enabled extension one by one
for ext in $enabled_extensions; do
    gnome-extensions disable "$ext"
done

# Re-enable each previously enabled extension
for ext in $enabled_extensions; do
    gnome-extensions enable "$ext"
done
