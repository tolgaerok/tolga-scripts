# Adding Video/Image Codecs

These are just good to have never know when you will need them. Pretty simple just run the command to install and that’s it.

    yay -S openjpeg libwebp libavif libheif dav1d rav1e daala-git libdv libmpeg2 libtheora libvpx x264 x265 xvidcore gstreamer gst-plugins-base gst-libav gstreamer-vaapi ffmpeg

# Adding Filesystem Support

Just like with Video/Image Codecs all we need to do is just run this command to add support

    yay -S btrfs-progs dosfstools exfatprogs f2fs-tools e2fsprogs hfsprogs jfsutils nilfs-utils ntfs-3g xfsprogs apfsprogs-git bcachefs-tools zfs-utils

You may not need all of these like BTRFS, JFS or ZFS maybe even the Apple HFS and APFS options but I like to keep them installed so that Im ready to work with any drive I happen to need to interact with. Feel free to adjust this to your liking.

# Installing Fonts

These are just extra fonts for some apps that manually set there own and also includes apple-fonts which gives you the SF Pro Fonts which I have set as my default font in Firefox and My Desktop.

    yay -S noto-fonts noto-fonts-cjk ttf-dejavu ttf-liberation ttf-opensans apple-fonts