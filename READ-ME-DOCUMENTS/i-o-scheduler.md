## How create a systemd service to run user choice of I/O scheduler on Fedora, Solus or Mint



Tolga Erok

26/12/2023

![image](https://github.com/tolgaerok/tolga-scripts/assets/110285959/7c5c7631-1c4a-4c8b-93ed-5275a8c1e9e6)

![image](https://github.com/tolgaerok/tolga-scripts/assets/110285959/e62aae39-2b2c-4458-8a4a-7d6eddf898a7)

# IMPORTANT
Choose a new I/O scheduler:
- kyber - Suited for both SSDs and NVMe, provides good performance.
- none - Disables I/O scheduling, suitable for SSDs and NVMe with their own internal algorithms.
- mq-deadline - Multiqueue variant of the deadline scheduler, generally suitable for SSDs.

# Steps

1. Open a terminal and create a new systemd service file:

   ```bash
   sudo nano /etc/systemd/system/io-scheduler.service
   ```

2. Add the following content to the `io-scheduler.service` file:
- Change to sda or nvme01 for `cat /sys/block/sda/queue/scheduler`

   ```ini
   [Unit]
   Description=Set I/O Scheduler on boot

   [Service]
   Type=simple
   ExecStart=/bin/bash -c 'echo -e "Configuring I/O Scheduler to: "; echo "kyber" | sudo tee /sys/block/sda/queue/scheduler; printf "I/O Scheduler has been set to ==>  "; cat /sys/block/sda/queue/scheduler; echo ""'

   [Install]
   WantedBy=default.target
   ```

   Plase note that this assumes your disk is `/dev/sda`. If yourr disk is different, replace `/dev/sda` with the appropriate device path.

4. Save the file and exit the text editor.

5. Reload the systemd manager to pick up the changes:

   ```bash
   sudo systemctl daemon-reload
   ```

6. Enable the service to start on boot:

   ```bash
   sudo systemctl enable io-scheduler.service
   ```

7. Optionally, you can start the service immediately:

   ```bash
   sudo systemctl start io-scheduler.service
   ```

8. Check status
   
   ```bash
   sudo systemctl status io-scheduler.service
   ```

9. Check i/o assignment 
   
   ```bash
   SSD  ==>    cat /sys/block/sda/queue/scheduler
   NVME ==>    cat /sys/block/nvme01/queue/scheduler
   ```

10. Edit grub, sudo nano /etc/default/grub 
  
   ```bash
   Find       ==>    GRUB_CMDLINE_LINUX="rhgb quiet mitigations=off"
   Change to: ==>    GRUB_CMDLINE_LINUX="rhgb quiet elevator=none mitigations=off"
   ```

11. Update grub 
  
   ```bash
   sudo grub2-mkconfig -o /boot/grub2/grub.cfg && sudo grub2-mkconfig -o /boot/efi/EFI/fedora/grub.cfg
   ```

This systemd service will run the specified commands during system boot.

# Note:

Keep in mind that modifying system settings during boot requires elevated privileges, so the service will be executed with sudo.







