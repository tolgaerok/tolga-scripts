### Restart Zram0 services

To install and configure zram to dynamic to suit current system available ram and use the resources effiently:

```bash
#!/bin/bash
# Tolga Erok
# 23-3-24

# Install zram package
sudo dnf install zram-generator-defaults -y

# Enable and start zram service
sudo systemctl enable --now systemd-zram-setup@zram0.service

# Set dynamic zram size in configuration file
echo "zram-size = ram" | sudo tee -a /etc/systemd/zram-generator.conf > /dev/null

# Restart systemd-zram-setup service
sudo systemctl restart systemd-zram-setup@zram0.service

echo "Zram setup complete."
```

This should work on arch also, but this has been scripted for fedora system
