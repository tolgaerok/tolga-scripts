Create a keyboard shortcut in Windows 11 that puts your system into suspend (sleep) mode, follow these steps:

### Step 1: Create a Shortcut
1. **Right-click** on your Desktop or inside a folder where you want the shortcut.
2. Select **New > Shortcut**.
3. In the location field, type the following command:
   ```
   rundll32.exe powrprof.dll,SetSuspendState 0,1,0
   ```
4. Click **Next**, then name the shortcut (e.g., "Sleep").
5. Click **Finish**.

### Step 2: Assign a Keyboard Shortcut
1. **Right-click** on the new shortcut and select **Properties**.
2. In the **Shortcut** tab, click inside the **Shortcut key** field.
3. Press the key combination you want to use (e.g., `Ctrl + Alt + S`).
4. Click **Apply**, then **OK**.

### Step 3: Test the Shortcut
Press your chosen key combination to see if the system enters sleep mode.

### Note:
- If your system hibernates instead of sleeping, you can adjust the power settings to disable hibernation or use `rundll32.exe powrprof.dll,SetSuspendState Sleep` to force sleep mode. 
- Make sure your power plan settings are configured to allow sleep mode.

If your system hibernates instead of suspending when using the `rundll32.exe powrprof.dll,SetSuspendState 0,1,0` command, you'll need to disable hibernation or use a different method to force sleep mode.

#

### Option 1: Disable Hibernation
1. **Open Command Prompt as Administrator**:
   - Press `Win + X` and select **Terminal (Admin)**.
   - If you're using PowerShell, type `cmd` and press Enter to switch to the Command Prompt.

2. **Disable Hibernation**:
   - Type the following command and press Enter:
     ```
     powercfg -h off
     ```

Now, when you use the shortcut, the system should enter sleep mode instead of hibernating.

### Option 2: Use a Different Sleep Command
1. **Create a Shortcut**:
   - Follow the same steps as before but use this command instead:
     ```
     rundll32.exe powrprof.dll,SetSuspendState Sleep
     ```
   
2. **Assign a Keyboard Shortcut**:
   - Right-click the shortcut, go to **Properties**, and assign your desired keyboard shortcut.

### Option 3: Use the `psshutdown` Tool
If the above methods don’t work, you can use a tool called `psshutdown` from the Sysinternals suite:
1. **Download PsTools** from the official Microsoft website: [Sysinternals PsTools](https://learn.microsoft.com/en-us/sysinternals/downloads/pstools).

2. **Extract the contents** to a folder, for example, `C:\PsTools`.

3. **Create a Shortcut**:
   - Right-click on the Desktop, select **New > Shortcut**, and enter:
     ```
     C:\PsTools\psshutdown.exe -d -t 0
     ```
   - Name it something like "Sleep" and click **Finish**.

4. **Assign a Keyboard Shortcut**:
   - Right-click the shortcut, go to **Properties**, and assign your desired keyboard shortcut.

This should reliably put your system to sleep without hibernating.
