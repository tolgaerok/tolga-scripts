## Tolga Erok
How create a systemd service to run i/o scheduler on fedora

1. Open a terminal and create a new systemd service file:

   ```bash
   sudo nano /etc/systemd/system/io-scheduler.service
   ```

2. Add the following content to the `io-scheduler.service` file:

   ```ini
   [Unit]
   Description=Set I/O Scheduler on boot

   [Service]
   Type=simple
   ExecStart=/bin/bash -c 'echo -e "Configuring I/O Scheduler to: "; echo "mq-deadline" | sudo tee /sys/block/sda/queue/scheduler; printf "I/O Scheduler has been set to ==>  "; cat /sys/block/sda/queue/scheduler; echo ""'

   [Install]
   WantedBy=default.target
   ```

   Plase note that this assumes your disk is `/dev/sda`. If yourr disk is different, replace `/dev/sda` with the appropriate device path.

3. Save the file and exit the text editor.

4. Reload the systemd manager to pick up the changes:

   ```bash
   sudo systemctl daemon-reload
   ```

5. Enable the service to start on boot:

   ```bash
   sudo systemctl enable io-scheduler.service
   ```

6. Optionally, you can start the service immediately:

   ```bash
   sudo systemctl start io-scheduler.service
   ```
7. Check status
   
  ```bash
  sudo systemctl status io-scheduler.service
  ```

This systemd service will run the specified commands during system boot. 

##TODO:
Keep in mind that modifying system settings during boot requires elevated privileges, so the service will be executed with sudo.

![image](https://github.com/tolgaerok/tolga-scripts/assets/110285959/7c5c7631-1c4a-4c8b-93ed-5275a8c1e9e6)




