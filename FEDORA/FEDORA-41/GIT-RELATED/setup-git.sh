#!/bin/bash
# Tolga Erok
# 19/12/2024
# Setup Git Repository and GitHub SSH Authentication

### **Configuration**
GITHUB_USERNAME="tolgaerok"
GIT_USER_EMAIL="kingtolga@gmail.com"
GIT_USER_NAME="Tolga Erok"
LOCAL_REPO_DIR="$HOME/MyGit"
REPO_NAME="tolga-scripts"
SSH_KEY_COMMENT="$GIT_USER_EMAIL"
SSH_KEY_PATH="$HOME/.ssh/id_rsa"

### Create Directory and Clone Repository
echo "Creating directory for Git repository..."
mkdir -p "$LOCAL_REPO_DIR"
cd "$LOCAL_REPO_DIR" || exit 1

if [ -d ".git" ]; then
    echo "Repository already initialized. Skipping clone..."
else
    echo "Cloning repository..."
    git clone "git@github.com:${GITHUB_USERNAME}/${REPO_NAME}.git" .
fi

### Set Global Git Configuration
echo "Configuring global Git settings..."
git config --global user.email "$GIT_USER_EMAIL"
git config --global user.name "$GIT_USER_NAME"
git config --global init.defaultBranch main
git config --global credential.helper cache
git config --global credential.helper 'cache --timeout=25000'
git config --global push.default simple

### Initialize Repository
if [ ! -d ".git" ]; then
    echo "Initializing new Git repository..."
    git init
    git branch -m main
fi

### Setup SSH Key for GitHub Authentication
if [ ! -f "$SSH_KEY_PATH" ]; then
    echo "Generating SSH key for GitHub authentication..."
    ssh-keygen -t rsa -b 4096 -C "$SSH_KEY_COMMENT" -f "$SSH_KEY_PATH" -N ""
    echo "New SSH key generated. Make sure to add it to your GitHub account."
else
    echo "SSH key already exists. Skipping generation."
fi

### Ensure SSH Agent is Running and Add Key
eval "$(ssh-agent -s)"
ssh-add "$SSH_KEY_PATH"

### Display SSH Key for GitHub Addition
echo ""
echo "Copy the following SSH key and add it to GitHub (Settings > SSH Keys):"
echo "┌───────────      IMPORTANT      ─────────────┐"
echo ""
cat "$SSH_KEY_PATH.pub"
echo ""
echo "└─────────────────────────────────────────────┘"
echo ""

### Configure Local Repository for SSH
if git remote | grep -q "origin"; then
    echo "Updating existing remote repository URL..."
    git remote set-url origin "git@github.com:${GITHUB_USERNAME}/${REPO_NAME}.git"
else
    echo "Adding new remote repository..."
    git remote add origin "git@github.com:${GITHUB_USERNAME}/${REPO_NAME}.git"
fi

git remote -v

### Test SSH Connection
echo "Testing SSH connection with GitHub..."
ssh -T git@github.com || {
    echo "SSH authentication failed. Ensure you added the key to GitHub."
    exit 1
}

### Secure SSH Files
echo "Securing SSH file permissions..."
mkdir -p "$HOME/.ssh"
chmod 700 "$HOME/.ssh"

if [ -f "$HOME/.ssh/config" ]; then
    chmod 600 "$HOME/.ssh/config"
else
    echo "~/.ssh/config does not exist. Skipping."
fi

chmod 600 "$SSH_KEY_PATH"
chmod 644 "$SSH_KEY_PATH.pub"

### Ensure Correct Ownership
echo "Ensuring correct ownership of SSH files..."
chown $USER:$USER "$SSH_KEY_PATH" "$SSH_KEY_PATH.pub"

if [ -f "$HOME/.ssh/config" ]; then
    chown $USER:$USER "$HOME/.ssh/config"
fi

### Final Check
echo "Final repository setup check..."
git remote -v
ssh -T git@github.com
