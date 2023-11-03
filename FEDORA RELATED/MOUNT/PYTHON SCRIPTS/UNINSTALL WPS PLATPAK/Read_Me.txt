Tolga Erok
15/3/2023


This script is designed to uninstall WPS Office, a flatpak application, and remove associated files and user data. Here is a brief summary of what the script does in a more human-readable format:

1. Lists the installed flatpaks using the 'flatpak list' command.
2. Uninstalls WPS Office flatpak using the 'flatpak uninstall com.wps.Office' command.
3. Deletes the WPS Office flatpak remote using the 'flatpak remote-delete flathub-wps-office' command.
4. Removes the WPS Office user data by executing the following commands:
   - 'rm -rf ~/.var/app/com.wps.Office/' to remove user-specific application data.
   - 'sudo rm -rf /opt/kingsoft' to remove system-wide installation files.
   - 'rm -rf ~/.config/Kingsoft' to remove user configuration files.
5. Uninstalls any unused flatpaks using the 'flatpak uninstall --unused' command.

To execute the script, you can follow these steps:
1. Create a new file with a ".py" extension, for example, "uninstall_wps.py".
2. Copy the script provided into the newly created file.
3. Save the file.
4. Open a terminal or command prompt.
5. Navigate to the directory where the script file is located using the 'cd' command.
6. Execute the script by running the command 'python3 uninstall_wps.py' or simply 'python uninstall_wps.py' if you're using Python 2.
7. The script will start executing, and you will see the output of each command being executed in the terminal or command prompt window.
