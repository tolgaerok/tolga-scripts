## Open the Override File for Editing.

Use the correct command to edit the override configuration:

    sudo systemctl edit wsdd

## Add a Custom [Service] Section

Replace the file's content with:

    [Service]
    ExecStart=/usr/sbin/wsdd

- Save and Exit
- Save the changes and exit the editor (Ctrl + X, then Y for nano, or Ctrl + S for Kate).

## Reload Systemd and Enable the Service

Reload the systemd configuration and enable the service:

    sudo iptables -A INPUT -p udp --dport 3702 -j ACCEPT
    sudo systemctl daemon-reload
    sudo systemctl enable wsdd
    sudo systemctl start wsdd

## Verify the Service

Confirm the service is running:

    sudo systemctl --no-pager status wsdd


# VERSION 2

`sudo nano /usr/local/bin/wsdd-wrapper.sh`

    #!/bin/bash
    INTERFACE=$(ip route | awk '/default/ {print $5}')
    exec /usr/bin/wsdd --shortlog --chroot=/run/wsdd -i "$INTERFACE" $WSDD_PARAMS


`sudo chmod +x /usr/local/bin/wsdd-wrapper.sh`

Edit:

`/usr/lib/systemd/system/wsdd.service`

```bash
[Unit]
Description=Web Services Dynamic Discovery host daemon
Documentation=man:wsdd(8)
; Start after the network has been configured
After=network-online.target
Wants=network-online.target
; It makes sense to have Samba running when wsdd starts, but is not required.
;BindsTo=smb.service
After=smb.service

[Service]
Type=simple
EnvironmentFile=/etc/conf.d/wsdd
; The service is put into an empty runtime directory chroot,
; i.e. the runtime directory which usually resides under /run
ExecStart=/usr/bin/wsdd --shortlog --chroot=/run/wsdd $WSDD_PARAMS
#ExecStart=
#ExecStart=/usr/bin/wsdd --shortlog --chroot=/run/wsdd -i $(ip route | awk '/default/ {print $5}') $WSDD_PARAMS
ExecStart=
ExecStart=/usr/local/bin/wsdd-wrapper.sh

DynamicUser=yes
User=wsdd
Group=wsdd
RuntimeDirectory=wsdd
AmbientCapabilities=CAP_SYS_CHROOT

[Install]
WantedBy=multi-user.target
```

    sudo systemctl daemon-reexec
    sudo systemctl restart wsdd
    sudo systemctl status wsdd
