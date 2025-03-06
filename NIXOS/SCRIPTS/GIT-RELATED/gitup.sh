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

# Color Codes for output prettification
# ----------------------------------------------------------------------------
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
GREEN='\033[0;32m'
RESET='\033[0m'

# Functions
# ----------------------------------------------------------------------------
setup_git_config() {
  echo -e "🛠  ${YELLOW}Configuring git settings...${RESET}"
  git config --global core.compression 9
  git config --global core.deltaBaseCacheLimit 2g
  git config --global diff.algorithm histogram
  git config --global http.postBuffer 524288000
}

ensure_git_initialized() {
  if [ ! -d "$REPO_DIR/.git" ]; then
    echo -e "🌐  ${YELLOW}Initializing Git repository in $REPO_DIR...${RESET}"
    git init "$REPO_DIR"
    git -C "$REPO_DIR" remote add origin "$GIT_REMOTE_URL"
  fi
}

fix_branch() {
  cd "$REPO_DIR" || exit
  current_branch=$(git symbolic-ref --short HEAD 2>/dev/null)

  if [ "$current_branch" = "master" ]; then
    echo -e "🛠  ${YELLOW}Renaming master to main...${RESET}"
    git branch -m master main
    git fetch origin
    git branch --set-upstream-to=origin/main main
    git pull --rebase
  fi
}

check_remote_url() {
  remote_url=$(git -C "$REPO_DIR" remote get-url origin)
  if [[ $remote_url != *"git@github.com"* ]]; then
    echo -e "${RED}Error: Remote URL is not set to SSH. Please configure SSH key-based authentication.${RESET}"
    exit 1
  fi
}

upload_files() {
  if [ -d "$REPO_DIR/.git/rebase-merge" ]; then
    echo -e "${RED}Error: Rebase in progress. Resolve with 'git rebase --continue' or 'git rebase --abort'.${RESET}"
    exit 1
  fi

  echo -e "🌐  ${YELLOW}Checking for changes...${RESET}"
  git add .

  if git status -s | grep -qE '^\s*[MARCDU]'; then
    commit_msg=$(printf "$COMMIT_MSG_TEMPLATE" "$(date '+%d-%m-%Y %I:%M:%S %p')")
    echo -e "🛠  ${BLUE}Changes detected, committing: $commit_msg${RESET}"
    git commit -am "$commit_msg"

    echo -e "🛠  ${YELLOW}Files being committed:${RESET}"
    # List all files that are staged for commit in green
    git status -s | while read -r line; do
      if [[ $line =~ ^[MADC]\s+(.*) ]]; then
        echo -e "${GREEN}${BASH_REMATCH[1]}${RESET}"
      fi
    done

    echo -e "🌐  ${YELLOW}Pulling latest from main...${RESET}"
    if ! git pull --rebase origin main; then
      echo -e "${RED}Error: Pull failed. Please check the repository.${RESET}"
      exit 1
    fi

    echo -e "🌐  ${YELLOW}Pushing to main...${RESET}"
    if ! git push origin main; then
      echo -e "${RED}Error: Push failed. Please check the repository.${RESET}"
      exit 1
    fi
    figlet Files Uploaded | lolcat
  else
    echo -e "🌐  ${YELLOW}No changes to commit.${RESET}"
    figlet Nothing Uploaded | lolcat
  fi
}


send_notification() {
  if command -v notify-send &> /dev/null; then
    notify-send --icon=dialog-information --app-name="Git Sync" "Upload Complete" "Time taken: $1 seconds"
  else
    echo -e "🌐  ${YELLOW}notify-send not found, skipping notification.${RESET}"
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
