#!/usr/bin/env bash

# Metadata
# ----------------------------------------------------------------------------
AUTHOR="Tolga Erok"
VERSION="5"
DATE_CREATED="19/12/2024"

# Configuration
# ----------------------------------------------------------------------------
REPO_DIR="$HOME/MyGit/tolga-scripts"
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

fix_branch() {
  cd "$REPO_DIR" || exit
  current_branch=$(git symbolic-ref --short HEAD 2>/dev/null)

  if [ "$current_branch" = "master" ]; then
    echo "Renaming master to main..."
    git branch -m master main
    git fetch origin
    git branch --set-upstream-to=origin/main main
    git pull --rebase
  fi
}

check_remote_url() {
  remote_url=$(git -C "$REPO_DIR" remote get-url origin)
  if [[ $remote_url != *"git@github.com"* ]]; then
    echo "Error: Remote URL is not set to SSH. Please configure SSH key-based authentication."
    exit 1
  fi
}

upload_files() {
  if [ -d "$REPO_DIR/.git/rebase-merge" ]; then
    echo "Error: Rebase in progress. Resolve with 'git rebase --continue' or 'git rebase --abort'."
    exit 1
  fi

  echo "Checking for changes..."
  git add .
  
  if git status --porcelain | grep -qE '^\s*[MARCDU]'; then
    commit_msg=$(printf "$COMMIT_MSG_TEMPLATE" "$(date '+%d-%m-%Y %I:%M:%S %p')")
    echo "Changes detected, committing: $commit_msg"
    git commit -am "$commit_msg"

    echo "Pulling latest from main..."
    git pull --rebase origin main

    echo "Pushing to main..."
    git push origin main
    figlet "Files Uploaded" | lolcat
  else
    echo "No changes to commit."
    figlet "Nothing Uploaded" | lolcat
  fi
}

send_notification() {
  if command -v notify-send &> /dev/null; then
    notify-send --icon=dialog-information --app-name="Git Sync" "Upload Complete" "Time taken: $1 seconds"
  else
    echo "notify-send not found, skipping notification."
  fi
}

# Main Script
# ----------------------------------------------------------------------------
set -e
start_time=$(date +%s)

setup_git_config
ensure_git_initialized
fix_branch
check_remote_url
cd "$REPO_DIR" || exit
upload_files

end_time=$(date +%s)
time_taken=$((end_time - start_time))

send_notification "$time_taken"

