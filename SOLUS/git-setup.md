### I used nix package manager to install git

```bash
nix-env -iA nixpkgs.gitFull
```

#

### Step 1: Configure Git with User Details

- First, configure Git with your email and name:
```bash
git config --global user.email "Tolga Erok"
git config --global user.name "kingtolga"
```

### Step 2: Create a New Directory and Initialize Git

- Create a new directory for your project and initialize a Git repository:

```bash
mkdir -p MyGit
cd MyGit
git init
```

### Step 3: Set Default Branch Name

- Set the default branch name to `main` (or `master`, depending on your Git version):

```bash
git config --global init.defaultBranch main
```

### Step 4: Add and Commit Files

- Add all files in your directory to the Git staging area and commit them with a message:

```bash
git add -A   # Add all files
git commit -m "Initial commit"
```

### Step 5: Generate and Add SSH Key (if not already done)

- If you haven't already set up an SSH key for GitHub, follow these steps. If you already have an SSH key, skip to Step 6.

#### Generate SSH Key
- Generate a new SSH key pair:
```bash
ssh-keygen -t rsa -b 4096 -C "kingtolga@gmail.com"
```
Follow the prompts to save the key in the default location (`~/.ssh/id_rsa`) or specify a different filename.

#### Add SSH Key to SSH Agent
- Start the SSH agent (if not already running) and add your SSH private key:
```bash
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_rsa
```

#### Add SSH Key to GitHub Account
- Copy the SSH public key to your clipboard:
```bash
cat ~/.ssh/id_rsa.pub   
```
Go to your GitHub account settings -> SSH and GPG keys -> New SSH key, and paste the copied public key.

### Step 6: Add Remote Repository

- Add your GitHub repository as a remote named `origin` (replace `<your-username>` with your GitHub username and `<repository>` with your repository name):
```bash
git remote add origin git@github.com:tolgaerok/nixos-2405-gnome.git
```
If you prefer HTTPS instead of SSH, use:
```bash
git remote add origin https://github.com/tolgaerok/nixos-2405-gnome.git
```

### Step 7: Push to Remote Repository

- Push your committed changes to the remote repository (`origin`):
```bash
git push -u origin main
```
This command pushes your `main` branch to `origin` and sets it as the upstream branch. Subsequent pushes can be done with just `git push`.

### Step 8: Verify on GitHub

- Go to your GitHub repository to verify that your files have been pushed successfully.

### Summary

These steps guide you through configuring Git, initializing a repository, setting up SSH (if needed), adding a remote repository on GitHub, and pushing your initial commit. Adjust paths and repository names as necessary based on your setup.

#

#### My custom gitup script to automate the git uploads

#


```bash
   #!/usr/bin/env bash
    # Tolga Erok
    # 10/6/2024
    # git uploader version #2

    set -e

    # Personal nixos git folder uploader!!
    # Tolga Erok. ¯\\_(ツ)_/¯..
    # 20/8/23.

    start_time=$(date +%s)
    # Directory of your Git repository
    REPO_DIR="/etc/nixos"

    # Commit message with timestamp and custom changes in Australian format..
    COMMIT_MSG="(ツ)_/¯ Edit: $(date '+%d-%m-%Y %I:%M:%S %p')"

    # Add some tweaks
    git config --global core.compression 9
    git config --global core.deltaBaseCacheLimit 2g
    git config --global diff.algorithm histogram
    git config --global http.postBuffer 524288000

    # Ensure the Git repository is initialized
    if [ ! -d "$REPO_DIR/.git" ]; then
        echo "Initializing Git repository in $REPO_DIR..."
        git init "$REPO_DIR"
        git remote add origin git@github.com:tolgaerok/nixos-2405-gnome.git
    fi

    # Check if the remote URL is set to SSH
    remote_url=$(git -C "$REPO_DIR" remote get-url origin)

    # Configure Git credential helper to cache credentials for 1 hour
    git config --global credential.helper "cache --timeout=3600"

    if [[ $remote_url == *"git@github.com"* ]]; then
        echo ""
        echo "Remote URL is set to SSH. Proceeding with the script..." | lolcat
        echo ""
    else
        echo "Remote URL is not set to SSH. Please set up SSH key-based authentication for the remote repository."
        echo "If you haven't already, generate an SSH key pair:"
        echo "ssh-keygen -t ed25519 -C 'your email'"
        echo "Add your SSH key to the agent:"
        echo "eval \$(ssh-agent -s)"
        echo "ssh-add ~/.ssh/id_ed25519"
        echo "Then, add your SSH public key to your GitHub account:"
        echo "cat ~/.ssh/id_ed25519.pub"
        echo "Finally, update your Git configuration to use SSH:"
        echo "git config --global credential.helper store"
        echo "Remote URL needs to be updated to SSH. Exiting..."
        exit 1
    fi

    # Navigate to the repository directory
    cd "$REPO_DIR" || exit

    # Check if a rebase is in progress
    if [ -d "$REPO_DIR/.git/rebase-merge" ]; then
        echo "A rebase is currently in progress. Please resolve it before running this script."
        echo "You can either continue the rebase with 'git rebase --continue' or abort it with 'git rebase --abort'."
        exit 1
    fi

    # Print the current working directory for debugging
    echo "Current working directory: $(pwd)"

    # Add all changes
    git add .

    # Print the status for debugging
    echo "Git status before committing:"
    git status

    # Check if there are changes to commit
    if git status --porcelain | grep -qE '^\s*[MARCDU]'; then
        echo "Changes detected, committing..."
        # Commit changes with custom message
        git commit -am "$COMMIT_MSG"

        # Pull changes from the remote repository to avoid conflicts
        echo "Pulling changes from remote repository..."
        git pull --rebase origin main

        # Push changes to the main branch
        echo "Pushing changes to remote repository..."
        git push origin main
        figlet files && figlet uploaded
    else
        echo "No changes to commit."
        figlet Nothing to && figlet Upload
    fi        

    end_time=$(date +%s)

    

    time_taken=$((end_time - start_time))

    notify-send --icon=ktimetracker --app-name="DONE" "Uploaded " "Completed:

        (ツ)_/¯
    Time taken: $time_taken
    " -u normal
```

#

#### Short-cut

```bash
nix-env -iA nixpkgs.gitFull
git config --global user.email "Tolga Erok"
git config --global user.name "kingtolga@gmail.com"
mkdir -p MyGit
cd MyGit/
git init
git config --global init.defaultBranch main
git add -A
git commit -m "Initial commit, and i still cant get it to work"
```
