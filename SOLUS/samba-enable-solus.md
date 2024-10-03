### Quick samba setup

```bash
sudo systemctl enable --now smb
sudo systemctl enable --now nmb
sudo smbpasswd -a tolga
sudo groupadd samba
sudo usermod -aG samba tolga
sudo smbpasswd -e tolga
sudo systemctl restart smb
sudo systemctl restart nmb
groups tolga
```

#


