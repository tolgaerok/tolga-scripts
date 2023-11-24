import tkinter as tk
from tkinter import ttk
from tkinter.scrolledtext import ScrolledText
import subprocess
import pexpect

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
        self.output_text = ScrolledText(root, height=10, width=80, wrap="word")
        self.output_text.pack(pady=10)

    def update_system(self):
        self.execute_command(['sudo', 'dnf', 'update', '-y'])

    def configure_dnf(self):
        self.execute_command(['sudo', 'cp', '/etc/dnf/dnf.conf', '/etc/dnf/dnf.conf.bak'])

    def execute_command(self, command):
        self.output_text.config(state="normal")
        self.output_text.delete(1.0, tk.END)

        process = pexpect.spawn(' '.join(command), timeout=None)

        def update_output():
            try:
                while True:
                    line = process.readline()
                    if not line:
                        break
                    self.output_text.insert(tk.END, line)
                    self.output_text.see(tk.END)
            except pexpect.EOF:
                pass

        update_output()

        process.wait()

        self.output_text.config(state="disabled")

if __name__ == "__main__":
    root = tk.Tk()
    app = TolgasFedoraUpdaterApp(root)
    root.mainloop()
