# Create a directory for my Git repository
mkdir -p /home/tolga/MyGit
cd /home/tolga/MyGit/

# Clone my repository
# git clone https://github.com/tolgaerok/solus.git

# Set global Git configuration
git config --global user.email "kingtolga@gmail.com"
git config --global user.name "Tolga Erok"
git config --global init.defaultBranch main

# Initialize the repository (only if needed for a new local repo)
git init

# Set up SSH key for GitHub authentication
ssh-keygen -t rsa -b 4096 -C "kingtolga@gmail.com"
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_rsa

# Display the SSH public key (add it to GitHub account via GitHub settings)
cat ~/.ssh/id_rsa.pub

# Configure the local repository
git branch -m main
git remote add origin git@github.com:tolgaerok/tolga-scripts.git
git remote -v

# Test the SSH connection with GitHub
ssh -T git@github.com

# Set appropriate permissions for SSH files
chmod 700 ~/.ssh
chmod 600 ~/.ssh/config
chmod 600 ~/.ssh/id_rsa
chmod 644 ~/.ssh/id_rsa.pub

# Ensure correct ownership of SSH files
chown tolga:tolga ~/.ssh/config
chown tolga:tolga ~/.ssh/id_rsa
chown tolga:tolga ~/.ssh/id_rsa.pub

# Update the remote URL to use SSH if needed
git remote set-url origin git@github.com:tolgaerok/tolga-scripts.git
git remote -v

# Test the updated SSH connection again
ssh -T git@github.com
