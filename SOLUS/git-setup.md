### I used ni package manager to install git


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

#

