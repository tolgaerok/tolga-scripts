#!/usr/bin/env bash
# Tolga Erok
# 28 Sep 2024
# git uploader version #3.1001

set -e

# detect OS
get_os_name() {
    if [[ -f /etc/os-release ]]; then
        . /etc/os-release
        echo "$NAME"  # Returns the OS name
    else
        echo "Unknown OS"
    fi
}

# Get the OS name
OS_NAME=$(get_os_name)

start_time=$(date +%s)
REPO_DIR="/var/home/tolga/MyGit/tolga-scripts"

# Commit message with OS name and timestamp
COMMIT_MSG="(ツ)_/¯ Edited with $OS_NAME: $(date '+%d-%m-%Y %I:%M:%S %p')"

# Start the SSH agent and add the SSH key
eval "$(ssh-agent -s)"
ssh-add "$HOME/.ssh/id_ed25519"

# Check if the Git repository is initialized
if [ ! -d "$REPO_DIR/.git" ]; then
    echo "Initializing Git repository in $REPO_DIR..."
    git init "$REPO_DIR"
    git remote add origin git@github.com:tolgaerok/tolga-scripts.git
fi

# Check the remote URL
remote_url=$(git -C "$REPO_DIR" remote get-url origin)
if [[ $remote_url != *"git@github.com"* ]]; then
    echo "Remote URL is not set to SSH. Please set it up."
    exit 1
fi

# Navigate to the repository directory
cd "$REPO_DIR" || { echo "Failed to navigate to $REPO_DIR"; exit 1; }

# Print the current working directory
echo "Current working directory: $(pwd)"
git add .

echo "Git status before committing:"
git status

if git status --porcelain | grep -qE '^\s*[MARCDU]'; then
    echo "Changes detected, committing..."
    git commit -am "$COMMIT_MSG"

    echo "Pulling changes from remote repository..."
    if ! git pull --rebase --verbose origin main; then
        echo "Error pulling changes. Please check your SSH setup."
        exit 1
    fi

    echo "Pushing changes to remote repository..."
    git push origin main
    echo "Files uploaded"
else
    echo "No changes to commit."
    echo "Nothing to Upload"
fi        

end_time=$(date +%s)
time_taken=$((end_time - start_time))

notify-send --icon=dialog-information --app-name="DONE" "Uploaded" "Completed:

(ツ)_/¯
Time taken: $time_taken
" -u normal

