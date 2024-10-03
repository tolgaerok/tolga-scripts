## My personal scheduled RAM and Cache Cleanup: 15-Minute Intervals

* Tolga Erok
* 25-2-24

1. **Create a Service File for Freeing RAM:**

    ```bash
    sudo nano /etc/systemd/system/ram-free.service
    ```

    Add the following content to the file:

    ```plaintext
    [Unit]
    Description=Free up RAM

    [Service]
    Type=oneshot
    ExecStart=/bin/sh -c '/bin/sync && /sbin/sysctl -w vm.drop_caches=3'

    [Install]
    WantedBy=default.target
    ```

    Explanation:
    - `Description`: A description of what the service does.
    - `Type`: Specifies that this is a one-shot service, meaning it's expected to execute and then exit.
    - `ExecStart`: Commands to be executed to free up RAM. `sync` flushes file system buffers, and `sysctl -w vm.drop_caches=3` frees up page cache, remove unnecessary files and data.
    - `WantedBy`: Specifies the target that this service should be associated with.

2. **Create a Timer File to Trigger the Service Periodically:**

    ```bash
    sudo nano /etc/systemd/system/ram-free.timer
    ```

    Add the following content to the file:

    ```plaintext
    [Unit]
    Description=Free up RAM periodically

    [Timer]
    OnCalendar=*:0/15
    Persistent=true

    [Install]
    WantedBy=timers.target
    ```

    Explanation:
    - `Description`: A description of what the timer does.
    - `OnCalendar`: Specifies the schedule for triggering the timer. In this case, it's set to trigger every 15 minutes.
    - `Persistent`: Indicates that the timer should be persistent across reboots.
    - `WantedBy`: Specifies the target that this timer should be associated with.

3. **Enable and Start the Services:**

    ```bash
    sudo systemctl enable ram-free.timer
    sudo systemctl start ram-free.timer
    ```

4. **Check the Status:**

    ```bash
    systemctl status ram-free.timer
    ```

This setup will periodically trigger the `ram-free.service` to free up RAM every 15 minutes. It uses the `sync` command to flush file system buffers and `sysctl -w vm.drop_caches=3` to free up page cache, remove unnecessary files and data.

## Alias setup

```bash
alias tolga-fmem2="echo && echo 'Current mem:' && free -h && sudo /bin/sh -c '/bin/sync && /sbin/sysctl -w vm.drop_caches=3' && echo && echo 'After: ' && free -h"
```

