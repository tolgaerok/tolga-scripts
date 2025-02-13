#!/usr/bin/env bash

# Metadata
# ----------------------------------------------------------------------------
AUTHOR="Tolga Erok"
VERSION="4"
DATE_CREATED="19/12/2024"

# Configuration
# ----------------------------------------------------------------------------
REPO_DIR="/home/tolga/MyGit/tolga-scripts"
COMMIT_MSG_TEMPLATE="(ツ)_/¯ Edit: %s"
GIT_REMOTE_URL="git@github.com:tolgaerok/tolga-scripts.git"
CREDENTIAL_CACHE_TIMEOUT=3600

# Functions
# ----------------------------------------------------------------------------
setup_git_config() {
  git config --global core.compression 9
  git config --global core.deltaBaseCacheLimit 2g
  git config --global diff.algorithm histogram
  git config --global http.postBuffer 524288000
}

ensure_git_initialized() {
  if [ ! -d "$REPO_DIR/.git" ]; then
    echo "Initializing Git repository in $REPO_DIR..."
    git init "$REPO_DIR"
    git -C "$REPO_DIR" remote add origin "$GIT_REMOTE_URL"
  fi
}

check_remote_url() {
  remote_url=$(git -C "$REPO_DIR" remote get-url origin)
  if [[ $remote_url != *"git@github.com"* ]]; then
    echo "Error: Remote URL is not set to SSH. Please configure SSH key-based authentication."
    echo "Setup instructions:"
    echo "1. Generate SSH key pair: ssh-keygen -t ed25519 -C 'your_email'"
    echo "2. Add SSH key to agent: eval \$(ssh-agent -s); ssh-add ~/.ssh/id_ed25519"
    echo "3. Add public key to GitHub account: cat ~/.ssh/id_ed25519.pub"
    echo "4. Update Git config: git config --global credential.helper store"
    exit 1
  fi
}

upload_files() {
  if [ -d "$REPO_DIR/.git/rebase-merge" ]; then
    echo "Error: Rebase in progress. Resolve with 'git rebase --continue' or 'git rebase --abort'."
    exit 1
  fi

  echo "Current working directory: $(pwd)"
  git add .
  echo "Git status before committing:"
  git status

  if git status --porcelain | grep -qE '^\s*[MARCDU]'; then
    commit_msg=$(printf "$COMMIT_MSG_TEMPLATE" "$(date '+%d-%m-%Y %I:%M:%S %p')")
    echo "Changes detected, committing with message: $commit_msg"
    git commit -am "$commit_msg"

    echo "Pulling changes from remote repository..."
    git pull --rebase origin main

    echo "Pushing changes to remote repository..."
    git push origin main
    figlet "Files Uploaded" | lolcat
  else
    echo "No changes to commit."
    figlet "Nothing Uploaded" | lolcat
  fi
}

# Main Script
# ----------------------------------------------------------------------------
set -e

start_time=$(date +%s)

setup_git_config
ensure_git_initialized
check_remote_url
cd "$REPO_DIR" || exit
upload_files

end_time=$(date +%s)
time_taken=$((end_time - start_time))

notify-send --icon=ktimetracker --app-name="DONE" "Uploaded " "Completed:

        (ツ)_/¯
    Time taken: $time_taken
    " -u normal
