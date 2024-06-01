# Magic SysRq values
To use the magic SysRq key on a Linux system, you'll typically need to combine the `Alt` key with the `SysRq` key (which is often the same as the `Print Screen` key) and another key that represents a specific command. Here’s a basic guide on how to use it:

### 1. Ensure SysRq is Enabled
First, you need to make sure the magic SysRq key is enabled in your system's configuration. You can check the current setting by running:

```sh
cat /proc/sys/kernel/sysrq
```

This command will output a number corresponding to the current setting. If it's `0`, SysRq is disabled. If it's a positive number, some or all SysRq functions are enabled.

To enable SysRq, you can modify the configuration temporarily or permanently.

**Temporarily:**

```sh
echo 176 > /proc/sys/kernel/sysrq
```

**Permanently:**

Edit the `/etc/sysctl.conf` file (you'll need superuser privileges) and add or modify the line:

```sh
kernel.sysrq = 176
```

Then apply the changes:

```sh
sudo sysctl -p
```

### 2. Using the Magic SysRq Key
Once SysRq is enabled, you can use the key combinations to perform various actions. Here are some common commands:

- **Restart the system safely**: `Alt` + `SysRq` + `b`
- **Shutdown the system safely**: `Alt` + `SysRq` + `o`
- **Sync all mounted filesystems**: `Alt` + `SysRq` + `s`
- **Remount all filesystems read-only**: `Alt` + `SysRq` + `u`
- **Kill all processes except for init**: `Alt` + `SysRq` + `e`
- **Terminate all processes including init (may cause reboot)**: `Alt` + `SysRq` + `i`

### Example Usage
1. **Sync Filesystems and Reboot**:
   - Press `Alt` + `SysRq` + `s` (sync filesystems)
   - Press `Alt` + `SysRq` + `u` (remount filesystems read-only)
   - Press `Alt` + `SysRq` + `b` (reboot)

2. **Sync Filesystems and Power Off**:
   - Press `Alt` + `SysRq` + `s` (sync filesystems)
   - Press `Alt` + `SysRq` + `u` (remount filesystems read-only)
   - Press `Alt` + `SysRq` + `o` (power off)

### Notes
- These key combinations should be pressed sequentially and not simultaneously.
- The effectiveness and availability of these commands can vary depending on your system's configuration and hardware.

# kernel.sysrq=1

If `kernel.sysrq` is set to `1`, it means that all functions of the magic SysRq key are enabled. This allows you to use any of the predefined key combinations to perform various actions directly with the kernel. Here’s a list of the key combinations you can use when `kernel.sysrq` is set to `1`:

- **`b`**: Immediately reboot the system without unmounting or syncing filesystems.
- **`c`**: Perform a system crash by triggering a kernel panic.
- **`d`**: Display all current CPU registers and flags.
- **`e`**: Send the SIGTERM signal to all processes except for init (terminate gracefully).
- **`f`**: Invoke the OOM (Out of Memory) killer to kill a process to free up memory.
- **`g`**: Used by kgdb (kernel debugger).
- **`h`**: Display help (shows all available SysRq commands).
- **`i`**: Send the SIGKILL signal to all processes except for init (terminate forcefully).
- **`j`**: Forcibly "Just kill" all hung tasks.
- **`k`**: Secure Access Key (SAK) kills all programs on the current virtual console.
- **`l`**: Send a SIGKILL to all processes, including init (may cause a system halt).
- **`m`**: Dump memory info to the console.
- **`n`**: Reset the nice level of all high-priority and real-time tasks.
- **`o`**: Shutdown the system (may not work on all systems).
- **`p`**: Dump the current registers and flags to the console.
- **`q`**: Dump all timers.
- **`r`**: Switch the keyboard from raw mode to XLATE mode.
- **`s`**: Sync all mounted filesystems.
- **`t`**: Dump a list of current tasks and their information to the console.
- **`u`**: Remount all mounted filesystems as read-only.
- **`v`**: Dump Voyager SMP processor info.
- **`w`**: Dump tasks in uninterruptable (blocked) state.
- **`x`**: Dump all currently held locks.
- **`y`**: Show all memory pools.
- **`z`**: Dump the page tables of the current process.

### Example Usage
To use any of these commands, press and hold the `Alt` key and the `SysRq` key (often the `Print Screen` key), then press the desired letter key.

For example, to safely reboot the system:

1. **Sync filesystems**: `Alt` + `SysRq` + `s`
2. **Remount filesystems as read-only**: `Alt` + `SysRq` + `u`
3. **Reboot the system**: `Alt` + `SysRq` + `b`

This ensures a cleaner reboot process, minimizing the risk of data loss or filesystem corruption.

By using these key combinations, you can interact directly with the Linux kernel to troubleshoot and manage your system, especially in cases where it is unresponsive.
