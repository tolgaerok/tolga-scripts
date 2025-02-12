# Samba to start after boot, login, suspend, and resume.


This guide explains how to set up Samba services (`smb` and `nmb`) to start automatically after boot, login, suspend, and reboot using custom `systemd` services. This will help ensure that your Samba services are consistently available, even after system states like suspend or reboot.

Ensure that `smb.service` and `nmb.service` are properly configured and working manually before setting them up to start automatically.

## 1. Create a Custom `systemd` Service for Samba to Start on Boot and Login

To ensure that Samba services start after boot and login, we will create a custom `systemd` service.

### Step 1: Create the Service File

Create a custom systemd service file by running the following command:

```bash
sudo nano /etc/systemd/system/samba-start.service
```

### Step 2: Add the Service Configuration

Add the following content to the file:

```ini
[Unit]
Description=Start Samba (SMB and NMB) Services
After=network.target

[Service]
ExecStart=/usr/bin/systemctl start smb.service
ExecStartPost=/usr/bin/systemctl start nmb.service
Restart=always
User=root

[Install]
WantedBy=multi-user.target
WantedBy=default.target
```

This configuration ensures that `smb` and `nmb` are started after the network is available, both after boot and login.

### Step 3: Reload `systemd` and Enable the Service

Reload the `systemd` manager to pick up the new service and enable it to start on boot:

```bash
sudo systemctl daemon-reload
sudo systemctl enable samba-start.service
```

This ensures that the service will start automatically after login and will persist through reboots.

---

## 2. Ensure Samba Starts After Suspend and Resume

To make sure that Samba starts correctly after the system resumes from suspend or hibernation, we will create another `systemd` service.

### Step 1: Create the Suspend/Resume Hook

Create a new systemd service file to handle suspend and resume:

```bash
sudo nano /etc/systemd/system/samba-start-after-suspend.service
```

### Step 2: Add the Configuration

Add the following content to the file:

```ini
[Unit]
Description=Start Samba (SMB and NMB) after Suspend
After=suspend.target

[Service]
ExecStart=/usr/bin/systemctl start smb.service
ExecStartPost=/usr/bin/systemctl start nmb.service
Restart=always
User=root

[Install]
WantedBy=suspend.target
WantedBy=hibernate.target
WantedBy=multi-user.target
```

This service ensures that `smb` and `nmb` are started again after the system suspends or hibernates, to restore connectivity after the system wakes up.

### Step 3: Reload and Enable the Service

Reload `systemd` and enable the service:

```bash
sudo systemctl daemon-reload
sudo systemctl enable samba-start-after-suspend.service
```

This ensures that the Samba services are re-started after the system resumes from suspend or hibernation.

---

## 3. Additional Configuration for Reboot

You don’t need to create any additional service for the reboot since Samba services will already start automatically after boot (via the previous setup). However, you can verify that the services will start correctly after a reboot by checking their status:

```bash
sudo systemctl status smb.service
sudo systemctl status nmb.service
```

If the services aren't starting automatically, ensure that both `samba-start.service` and `samba-start-after-suspend.service` are enabled and working correctly.

---

## 4. Verifying the Services

Once the services are set up, you can verify their status:

- **Samba on Boot/Login:**

```bash
sudo systemctl status samba-start.service
```

You should see a message indicating that the `smb` and `nmb` services have been started successfully.

- **Samba after Suspend/Resume:**

Test by suspending and resuming your system, then check the status of the service:

```bash
sudo systemctl status samba-start-after-suspend.service
```

This ensures that Samba starts automatically after the system resumes from suspend or hibernation.

---

## Troubleshooting

If the services fail to start, you can view their logs for more details:

- For `smb` service logs:

```bash
sudo journalctl -u smb.service
```

- For `nmb` service logs:

```bash
sudo journalctl -u nmb.service
```

This can help identify any issues with the service startup or configuration.

---

## Summary

- **`samba-start.service`**: Starts `smb` and `nmb` at boot and login.
- **`samba-start-after-suspend.service`**: Starts `smb` and `nmb` after suspend or resume.

These services ensure that Samba is up and running after boot, login, suspend, and resume. This setup will help provide a reliable Samba connection after your system undergoes any state change (boot, suspend, or resume).

---

## References

- [Samba documentation](https://www.samba.org/samba/docs/)
- [systemd documentation](https://www.freedesktop.org/wiki/Software/systemd/)



