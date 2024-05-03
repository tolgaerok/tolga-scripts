# DRACUT.CONFIG and my nvidia-dracut alias


## The Alias:
```bash
alias tolga-nvidia='sudo systemctl enable --now akmods --force && sudo dracut --force && echo && echo "Force akmods and Dracut on NVIDIA done" && echo'
```

The `tolga-nvidia` alias is my custom command that does some behind-the-scenes magic to get NVIDIA graphics cards working smoothly. Here's what it does:

1. It enables the `akmods` service, which is responsible for managing kernel modules, and starts it right away.
2. It rebuilds the initramfs image using `dracut`, forcing a rebuild even if the image is already up-to-date.
3. It prints a confirmation message to let you know that the process is complete.

## The Connection to `add_drivers` in `dracut.conf`
LOCATION:
```bash
/etc/dracut.conf.d/lz4hc.conf
```

CONFIG FILE
```bash
add_drivers+=" lz4hc lz4hc_compress "
```
The `add_drivers` parameter in the `dracut.conf` file is where the magic happens. It specifies additional kernel modules to include in the initramfs image. In this case, it's adding the `lz4hc` and `lz4hc_compress` modules to the mix.

#

My `tolga-nvidia` alias is used to rebuild the initramfs image with these modules enabled. The `akmods` service and `dracut` tool work together to make sure the kernel modules are up-to-date and the initramfs image is rebuilt accordingly.

The `--force` option in the `dracut` command ensures that the initramfs image is rebuilt even if it's already up-to-date. This might be necessary if the `lz4hc` and `lz4hc_compress` modules aren't included in the existing initramfs image.

In short, my `tolga-nvidia` alias is a custom command that helps get NVIDIA graphics cards working smoothly by rebuilding the initramfs image with the necessary modules on every Nvidia driver and kernel update
