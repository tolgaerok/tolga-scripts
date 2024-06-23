# Change systemD boot menu

```bash
alias boot="sudo clr-boot-manager mount-boot && cd /boot/loader && sudo gedit loader.conf"
```

```bash
console-mode max
console-mode auto
console-mode 0
console-mode 1
console-mode 2
console-mode keep
```

```bash
timeout 3
default Solus-current-6.8.12-293.conf
console-mode auto
editor yes
```

- do not run
  
```bash
sudo clr-boot-manager update
```

  
