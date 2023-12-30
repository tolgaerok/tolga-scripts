# Change Wallpaper
# Tolga erok



clear
echo "Setting up Desktop wallpaper"
# Get the script's folder path
script_folder="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# Specify the source image file path
source_file="/etc/nixos/SETUP/wallpapers/arc-mountain.png"
#source_file="/etc/nixos/SETUP/wallpapers/nix.png"
# Specify the destination picture folder path
picture_folder="$HOME/Pictures"
# Specify the destination wallpaper file name
wallpaper_file="wallpaper.jpg"
# Check if the source image file exists
if [ ! -f "$source_file" ]; then
echo "Error: Source image file not found."
sleep 2
fi
# Copy the image file to the picture folder
cp "$source_file" "$picture_folder/$wallpaper_file"
if [ $? -ne 0 ]; then
echo "Failed to copy the image file to the picture folder."
sleep 2
fi
# Set the wallpaper using KDE's command-line tool
command="qdbus org.kde.plasmashell /PlasmaShell org.kde.PlasmaShell.evaluateScript"
script="
var allDesktops = desktops();
for (i=0;i<allDesktops.length;i++) {
d = allDesktops[i];
d.wallpaperPlugin = 'org.kde.image';
d.currentConfigGroup = Array('Wallpaper', 'org.kde.image', 'General');
d.writeConfig('Image', 'file://$picture_folder/$wallpaper_file');
d.writeConfig('FillMode', '2');
}"
eval "$command \"$script\""
echo "Desktop Wallpaper set successfully."
sleep1
clear
