import tkinter as tk
from tkinter import ttk
import subprocess

class TolgasFedoraUpdaterApp:
    def __init__(self, root):
        self.root = root
        self.root.title("Tolga's Fedora Updater")

        self.notebook = ttk.Notebook(root)
        self.notebook.pack(pady=10, padx=10)

        # Create tabs
        self.tab1 = ttk.Frame(self.notebook)
        self.tab2 = ttk.Frame(self.notebook)

        self.notebook.add(self.tab1, text="System Update")
        self.notebook.add(self.tab2, text="Configure DNF tweaks")

        # Tab 1 - System Update
        self.btn_update_system = tk.Button(self.tab1, text="Update System", command=self.update_system)
        self.btn_update_system.pack(pady=10)

        # Tab 2 - Configure DNF
        self.btn_configure_dnf = tk.Button(self.tab2, text="Configure DNF", command=self.configure_dnf)
        self.btn_configure_dnf.pack(pady=10)

    def update_system(self):
        self.execute_command(['sudo', 'dnf', 'update', '-y'])

    def configure_dnf(self):
        self.execute_command(['sudo', 'cp', '/etc/dnf/dnf.conf', '/etc/dnf/dnf.conf.bak'])

    def execute_command(self, command):
        try:
            subprocess.run(['konsole', '--hold', '--separate', '--noclose', '-e', 'bash', '-c', ' '.join(command)])
        except FileNotFoundError:
            print("Konsole command not found. Please ensure it is installed on your system.")

if __name__ == "__main__":
    root = tk.Tk()
    app = TolgasFedoraUpdaterApp(root)
    root.mainloop()
