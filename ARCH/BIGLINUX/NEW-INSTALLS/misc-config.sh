flatpak install flathub io.github.aandrew_me.ytdn
flatpak run io.github.aandrew_me.ytdn

sudo systemctl enable --now smb.service nmb.service && sudo systemctl restart smb.service nmb.service


# grub
# GRUB_CMDLINE_LINUX="io_delay=none rootdelay=0 io_delay=none mitigations=off"

sudo grub-mkconfig -o /boot/grub/grub.cfg
