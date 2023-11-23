# Tolga Erok
# 23/11/2023
# My 1st python script (fedora 39 updater)
# Beta v1

import tkinter as tk
from tkinter import ttk
import subprocess
import os

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

        # Terminal-like output
        self.output_text = tk.Text(root, height=10, width=80, state="disabled", wrap="word")
        self.output_text.pack(pady=10)

    def update_system(self):
        result = subprocess.run(['sudo', 'dnf', 'update', '-y'], stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
        self.display_result(result.stdout + result.stderr)

    def configure_dnf(self):
        result = subprocess.run(['sudo', 'cp', '/etc/dnf/dnf.conf', '/etc/dnf/dnf.conf.bak'], stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
        self.display_result(result.stdout + result.stderr)

    def display_result(self, message):
        self.output_text.config(state="normal")
        self.output_text.delete(1.0, tk.END)
        self.output_text.insert(tk.END, message)
        self.output_text.config(state="disabled")

if __name__ == "__main__":
    root = tk.Tk()
    app = TolgasFedoraUpdaterApp(root)
    root.mainloop()