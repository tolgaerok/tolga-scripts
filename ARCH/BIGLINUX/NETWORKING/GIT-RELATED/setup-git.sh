#!/bin/bash
# Tolga Erok
# 19/12/2024
# **Setup Git Repository and GitHub SSH Authentication**

### **Configuration**
REPO_NAME="tolga-scripts"
GIT_USER_NAME="Tolga Erok"
GIT_USER_EMAIL="kingtolga@gmail.com"
GITHUB_USERNAME="tolgaerok"
LOCAL_REPO_DIR="/home/tolga/MyGit"
SSH_KEY_COMMENT="${GIT_USER_EMAIL}"

### **Create Directory and Clone Repository (if needed)**
echo "Creating directory for Git repository..."
mkdir -p "${LOCAL_REPO_DIR}"
cd "${LOCAL_REPO_DIR}" || exit 1

if [ -d ".git" ]; then
  echo "Repository already initialized. Skipping clone..."
else
  echo "Cloning repository..."
  git clone https://github.com/${GITHUB_USERNAME}/${REPO_NAME}.git
fi

### Set Global Git Configuration
echo "Configuring global Git settings..."
git init
git config --global user.email "${GIT_USER_EMAIL}"
git config --global user.name "${GIT_USER_NAME}"
git config --global init.defaultBranch main
git config --global credential.helper cache
git config --global credential.helper 'cache --timeout=25000'
git config --global push.default simple

### **Initialize Repository (if new)**
if [ ! -d ".git" ]; then
  echo "Initializing new Git repository..."
  git init
  git branch -m main
fi

### Setup SSH Key for GitHub Authentication
echo "Generating SSH key for GitHub authentication..."
ssh-keygen -t rsa -b 4096 -C "${SSH_KEY_COMMENT}" -f ~/.ssh/id_rsa -N ""

### Display and Configure SSH
echo "Displaying SSH public key (add to GitHub settings):"
cat ~/.ssh/id_rsa.pub

eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_rsa

### **Configure Local Repository for SSH**
echo "Configuring local repository for SSH..."
git remote add origin "git@github.com:${GITHUB_USERNAME}/${REPO_NAME}.git"
git remote -v

### **Test SSH Connection**
echo "Testing SSH connection with GitHub..."
ssh -T git@github.com

### **Secure SSH Files**
echo "Securing SSH file permissions..."

# Check if ~/.ssh exists, if not, create it and set permissions
if [ ! -d "$HOME/.ssh" ]; then
  mkdir -p "$HOME/.ssh"
  chmod 700 "$HOME/.ssh"
  echo "Created ~/.ssh and set permissions to 700"
else
  echo "~/.ssh already exists, skipping creation and permission change."
fi

# Check if ~/.ssh/config exists, if so, set permissions to 600
if [ -f "$HOME/.ssh/config" ]; then
  chmod 600 "$HOME/.ssh/config"
  echo "Set permissions of ~/.ssh/config to 600"
else
  echo "~/.ssh/config does not exist, skipping permission change."
fi

chmod 600 ~/.ssh/id_rsa
chmod 644 ~/.ssh/id_rsa.pub

### **Ensure Correct Ownership**
echo "Ensuring correct ownership of SSH files..."
chown tolga:tolga ~/.ssh/config
chown tolga:tolga ~/.ssh/id_rsa
chown tolga:tolga ~/.ssh/id_rsa.pub

### **Final Check**
echo "Final repository setup check..."
git remote -v
ssh -T git@github.com
