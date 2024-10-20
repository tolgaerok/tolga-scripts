#!/bin/bash
# original script here: https://github.com/dnkmmr69420/nix-with-selinux/blob/main/silverblue-installer.sh
# thanks dnkmmr!

sudo sleep 2
echo "Adding SELinux content to /nix"
sudo semanage fcontext -a -t etc_t '/nix/store/[^/]+/etc(/.*)?' ; sudo semanage fcontext -a -t lib_t '/nix/store/[^/]+/lib(/.*)?' ; sudo semanage fcontext -a -t systemd_unit_file_t '/nix/store/[^/]+/lib/systemd/system(/.*)?' ; sudo semanage fcontext -a -t man_t '/nix/store/[^/]+/man(/.*)?' ; sudo semanage fcontext -a -t bin_t '/nix/store/[^/]+/s?bin(/.*)?' ; sudo semanage fcontext -a -t usr_t '/nix/store/[^/]+/share(/.*)?' ; sudo semanage fcontext -a -t var_run_t '/nix/var/nix/daemon-socket(/.*)?' ; sudo semanage fcontext -a -t usr_t '/nix/var/nix/profiles(/per-user/[^/]+)?/[^/]+'
sleep 1
sudo mkdir /var/lib/nix
sleep 1
echo "Adding SELinux content to /var/lib/nix"
sudo semanage fcontext -a -t etc_t '/var/lib/nix/store/[^/]+/etc(/.*)?' ; sudo semanage fcontext -a -t lib_t '/var/lib/nix/store/[^/]+/lib(/.*)?' ; sudo semanage fcontext -a -t systemd_unit_file_t '/var/lib/nix/store/[^/]+/lib/systemd/system(/.*)?' ; sudo semanage fcontext -a -t man_t '/var/lib/nix/store/[^/]+/man(/.*)?' ; sudo semanage fcontext -a -t bin_t '/var/lib/nix/store/[^/]+/s?bin(/.*)?' ; sudo semanage fcontext -a -t usr_t '/var/lib/nix/store/[^/]+/share(/.*)?' ; sudo semanage fcontext -a -t var_run_t '/var/lib/nix/var/nix/daemon-socket(/.*)?' ; sudo semanage fcontext -a -t usr_t '/var/lib/nix/var/nix/profiles(/per-user/[^/]+)?/[^/]+'
echo "Creating service files"
sleep 1
sleep 1
echo "Creating rootfs mkdir service"

sudo tee /etc/systemd/system/mkdir-rootfs@.service <<EOF
[Unit]
Description=Enable mount points in / for ostree
ConditionPathExists=!%f
DefaultDependencies=no
Requires=local-fs-pre.target
After=local-fs-pre.target

[Service]
Type=oneshot
ExecStartPre=chattr -i /
ExecStart=mkdir -p '%f'
ExecStopPost=chattr +i /
EOF

sleep 1
echo "Creating nix.mount"

sudo tee /etc/systemd/system/nix.mount <<EOF
[Unit]
Description=Nix Package Manager
DefaultDependencies=no
After=mkdir-rootfs@nix.service
Wants=mkdir-rootfs@nix.service
Before=sockets.target
After=ostree-remount.service
BindsTo=var.mount

[Mount]
What=/var/lib/nix
Where=/nix
Options=bind
Type=none
EOF

sleep 1
echo "Enabling mount and resetting SELinux context"
sleep 1

sudo systemctl daemon-reload ; sudo systemctl enable nix.mount ; sudo systemctl start nix.mount ; sudo restorecon -RF /nix

sleep 1

echo "Temorarily setting SELinux to Permissive"

sudo setenforce Permissive

sleep 1

echo "Preparing the nix install script"

sleep 2

sh <(curl -L https://nixos.org/nix/install) --daemon

echo "Nix installer has finished running"
sleep 1
echo "Copying service files"

sleep 1

echo "Creating SSL cert file"
sudo mkdir -p /etc/systemd/system/nix-daemon.service.d/
sudo tee /etc/systemd/system/nix-daemon.service.d/override.conf <<EOF
[Service]
Environment="NIX_SSL_CERT_FILE=/etc/ssl/certs/ca-bundle.crt"
EOF
sudo rm -f /etc/systemd/system/nix-daemon.{service,socket} ; sudo cp /nix/var/nix/profiles/default/lib/systemd/system/nix-daemon.{service,socket} /etc/systemd/system/ ; sudo restorecon -RF /nix ; sudo systemctl daemon-reload ; sudo systemctl enable --now nix-daemon.socket

sleep 1

echo "Setting SELinux back to Enforcing"

sudo setenforce Enforcing

echo "Modifying /etc/nix/nix.conf"
echo "experimental-features = nix-command flakes" | sudo tee -a /etc/nix/nix.conf

sleep 1

echo "Adding /etc/profile.d/nix-app-icons.sh"

sudo rm -f /etc/profile.d/nix-app-icons.sh 
sudo tee /etc/profile.d/nix-app-icons.sh <<EOF
XDG_DATA_DIRS="$HOME/.nix-profile/share:/nix/var/nix/profiles/default/share:$XDG_DATA_DIRS"
EOF

sleep 1

echo "Installing nix backup"

sudo mkdir /opt/nixbackup
sudo cp -R /nix /opt/nixbackup

sudo tee /opt/nixbackup/reset-nix <<EOF
#!/bin/bash
sudo echo "Resetting nix..."
sudo rm -rf /nix/*
sudo mkdir -p /nix
sudo cp -R /opt/nixbackup/nix/* /nix/
sudo restorecon -RF /nix
sudo echo "Nix has been reset. Reboot for changes to apply."
EOF

sudo chmod a+x /opt/nixbackup/reset-nix

sudo echo "Finished installing nix backup"

sleep 1

echo "You MUST reboot in order for the installation to finish"
echo "Reboot your system by typing:"
echo "systemctl reboot"
