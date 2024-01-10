#####################################################################
#  Shutdown & restart networkmanager and flush caches               #
#   Tolga Erok
#   31/5/2023                                                       #
#####################################################################

import subprocess
import tkinter as tk
from tkinter import messagebox
from tkinter import ttk

def execute_script():
    password = password_entry.get()
    if password.strip() == "":
        messagebox.showwarning("Error", "Please enter the root password.")
        return

    # Disable network
    status_label.config(text="Disabling network...")
    progress_bar.step(20)
    window.update()
    subprocess.run(["sudo", "systemctl", "stop", "NetworkManager.service"])

    # Reset DNS cache
    status_label.config(text="Resetting DNS cache...")
    progress_bar.step(20)
    window.update()
    subprocess.run(["sudo", "systemd-resolve", "--flush-caches"])

    # Enable network
    status_label.config(text="Enabling network...")
    progress_bar.step(20)
    window.update()
    subprocess.run(["sudo", "systemctl", "start", "NetworkManager.service"])

    # Restart Wi-Fi adapter
    status_label.config(text="Restarting Wi-Fi adapter...")
    progress_bar.step(20)
    window.update()
    subprocess.run(["sudo", "systemctl", "restart", "NetworkManager.service"])

    # Check if running as root
    try:
        with open("/etc/os-release") as f:
            os_release = f.read()
        if "ID=ubuntu" in os_release:
            messagebox.showerror("Error", "This script must be run as root.")
            return
    except FileNotFoundError:
        pass

    # Rest of the script...

    # Fill progress bar to 100%
    status_label.config(text="Script executed successfully.")
    progress_bar["value"] = progress_bar["maximum"]
    window.update()

def check_password(event):
    execute_script()

# Create the GUI window
window = tk.Tk()
window.title("Refresh Networkmanager and Flush caches")
window.geometry("400x200")

# Root Password Entry
password_label = tk.Label(window, text="Root Password:")
password_label.pack()
password_entry = tk.Entry(window, show="*")
password_entry.pack()
password_entry.bind("<Return>", check_password)

# Execute Button
execute_button = tk.Button(window, text="Execute", command=execute_script)
execute_button.pack()

# Progress Bar
progress_bar = ttk.Progressbar(window, mode="determinate", length=200)
progress_bar.pack()

# Status Label
status_label = tk.Label(window, text="")
status_label.pack()

# Exit Button
exit_button = tk.Button(window, text="Exit", command=window.destroy)
exit_button.pack()

window.mainloop()
