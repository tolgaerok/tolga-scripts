#!/usr/bin/env bash
# Tolga Erok
# 28 Sep 2024
# git uploader version #3.1

set -e

# Detect OS
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
REPO_DIR="/home/tolga/Documents/MyGit/tolga-scripts"

# Commit message with OS name and timestamp
COMMIT_MSG="(ツ)_/¯ Edited with $OS_NAME: $(date '+%d-%m-%Y %I:%M:%S %p')"

# Start the SSH agent and add the SSH key
eval "$(ssh-agent -s)"
ssh-add "$HOME/.ssh/id_rsa"

# Check if the Git repository is initialized
if [ ! -d "$REPO_DIR/.git" ]; then
    echo "Initializing Git repository in $REPO_DIR..."
    git init "$REPO_DIR"
    git remote add origin git@github.com:tolgaerok/tolga-scripts.git
else
    # Ensure the remote exists and is correctly set
    remote_url=$(git -C "$REPO_DIR" remote get-url origin 2>/dev/null)
    if [ -z "$remote_url" ]; then
        echo "Remote 'origin' not found, adding it..."
        git remote add origin git@github.com:tolgaerok/tolga-scripts.git
    elif [[ $remote_url != *"git@github.com"* ]]; then
        echo "Remote URL is not set to SSH. Updating it..."
        git remote set-url origin git@github.com:tolgaerok/tolga-scripts.git
    fi
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
     figlet Files Uploaded | lolcat
else
    echo "No changes to commit."
    figlet Nothing Uploaded | lolcat
fi

end_time=$(date +%s)
time_taken=$((end_time - start_time))

notify-send --icon=dialog-information --app-name="DONE" "Uploaded" "Completed:

(ツ)_/¯
Time taken: $time_taken
" -u normal
