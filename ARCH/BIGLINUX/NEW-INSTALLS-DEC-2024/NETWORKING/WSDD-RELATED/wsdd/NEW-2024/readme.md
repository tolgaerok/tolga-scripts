Open the Override File for Editing
Use the correct command to edit the override configuration:

    sudo systemctl edit wsdd

Add a Custom [Service] Section
Replace the file's content with:

    [Service]
    ExecStart=/usr/sbin/wsdd

Save and Exit
Save the changes and exit the editor (Ctrl + X, then Y for nano, or Ctrl + S for Kate).

Reload Systemd and Enable the Service
Reload the systemd configuration and enable the service:

    sudo systemctl daemon-reload
    sudo systemctl enable wsdd
    sudo systemctl start wsdd

Verify the Service
Confirm the service is running:
    sudo systemctl status wsdd
