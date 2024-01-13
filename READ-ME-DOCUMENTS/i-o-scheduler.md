## How create a systemd service to run user choice of I/O scheduler on Fedora, Solus or Mint



Tolga Erok

26/12/2023

![image](https://github.com/tolgaerok/tolga-scripts/assets/110285959/7c5c7631-1c4a-4c8b-93ed-5275a8c1e9e6)

![image](https://github.com/tolgaerok/tolga-scripts/assets/110285959/e62aae39-2b2c-4458-8a4a-7d6eddf898a7)

# IMPORTANT
Choose a new I/O scheduler:
- `kyber`         - Suited for both SSDs and NVMe, provides good performance.
- `none`          - Disables I/O scheduling, suitable for SSDs and NVMe with their own internal algorithms.
- `mq-deadline`   - Multiqueue variant of the deadline scheduler, generally suitable for SSDs.

## Best Settings for HDD:
I/O Scheduler: `cfq` (Completely Fair Queueing) or `deadline`

These schedulers are generally well-suited for HDDs. `cfq` provides fairness, while `deadline` focuses on meeting deadlines for I/O requests.

- Read-Ahead Buffer:
- Setting: Moderate value (e.g., 128 KB to 256 KB)
- Helps in optimizing sequential read access on HDDs.

## Best Settings for SSD:
- I/O Scheduler: `deadline` or `bfq`

Both schedulers work well with SSDs. `deadline` can be a good balance, while `bfq` provides fairness, which can be beneficial for SSDs in certain scenarios.

- Read-Ahead Buffer:
- Setting: Smaller value (e.g., 32 KB to 64 KB)
- SSDs benefit less from larger read-ahead buffers due to their fast random access times.
- Trim Support:
- Setting: Enable TRIM
   TRIM helps in maintaining SSD performance over time by informing the drive which blocks are no longer in use.

## Best Settings for NVMe (M.2/PCIe SSD):
- I/O Scheduler: `none` or `mq-deadline`

NVMe drives often perform best without a specific I/O scheduler. `mq-deadline` can be used for systems where a scheduler is required.

- Read-Ahead Buffer:
- Setting: Not critical; can be left at default
- NVMe drives have fast random access times, so read-ahead settings are less critical.
- Trim Support:
- Setting: Enable TRIM
   TRIM is important for maintaining the longevity and performance of NVMe drives.

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







