#!/bin/bash

# Tolga Erok 7/6/2023 To RPM or NOT to RPMFusion

# Check if RPMFusion is already installed
if command -v rpmfusion &>/dev/null; then
  echo "RPMFusion is already installed."
  exit 0
fi

# Search for RPMFusion repositories in /etc/yum.repos.d/
repo_files=($(find /etc/yum.repos.d/ -name "rpmfusion*.repo"))

# Check if any RPMFusion repositories are found
if [ "${#repo_files[@]}" -eq 0 ]; then
  echo "RPMFusion repositories not found in /etc/yum.repos.d/."
else
  echo -e "RPMFusion repositories found in /etc/yum.repos.d/:\n"
  printf "%-40s %-10s %s\n" "Repository" "Status" "Duplicates"
  echo "-----------------------------------------------------"

  # Check for duplicate repositories
  duplicate_repos=($(awk -F '/' '/rpmfusion/ {print $NF}' <<<"${repo_files[*]}" | sort | uniq -d))
  for repo_file in "${repo_files[@]}"; do
    repo_name=${repo_file##*/}
    status=$(grep -E '^\s*enabled\s*=\s*(1|true)' "$repo_file" >/dev/null && echo "Enabled" || echo "Disabled")
    duplicates=""
    if [[ " ${duplicate_repos[*]} " =~ " $repo_name " ]]; then
      duplicates="Duplicate"
    fi
    printf "%-40s %-10s %s\n" "$repo_name" "$status" "$duplicates"
  done

  read -rp "Do you want to enable RPMFusion and perform a clean and update operation? (y/n): " choice
  if [ "$choice" = "y" ]; then
    # Install RPMFusion repositories if not already installed
    if ! rpmfusion &>/dev/null; then
      sudo dnf install -y "https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm" "https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm"
    fi

    # Enable RPMFusion repositories
    sudo dnf config-manager --set-enabled rpmfusion-free rpmfusion-nonfree

    # Clean package cache and update
    sudo dnf clean all && sudo dnf update rpmfusion-free rpmfusion-nonfree

    echo "RPMFusion enabled and updated successfully."
  else
    echo "RPMFusion enabling and update cancelled."
  fi
fi

# Additional potential locations for the 'rpmfusion' command
rpmfusion_locations=(
  "/usr/bin/rpmfusion"
  "/usr/local/bin/rpmfusion"
  "/opt/rpmfusion/bin/rpmfusion"
)

# Check if 'rpmfusion' command is available in any of the additional locations
found_location=""
for location in "${rpmfusion_locations[@]}"; do
  if command -v "$location" &>/dev/null; then
    found_location="$location"
    break
  fi
done

# Output the found location, if any
if [ -n "$found_location" ]; then
  echo "RPMFusion command found at: $found_location"
fi
