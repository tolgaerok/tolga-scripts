#!/bin/bash

target_user="$SUDO_USER"
user_home=$(getent passwd "$target_user" | cut -d: -f6)
pictures_dir="$user_home/Pictures"
themes_dir="$user_home/.themes"
icons_dir="$user_home/.icons"

if [ ! -d "$pictures_dir" ]; then
  mkdir "$pictures_dir"
fi

custom_wallpapers_dir="$pictures_dir/CustomWallpapers"
mkdir -p "$custom_wallpapers_dir"
cp -r "$(dirname "$(readlink -f "$0")")/wallpapers"/* "$custom_wallpapers_dir"

# Set permissions to match current user's home directory
if [ -d "$pictures_dir" ]; then
  chown -R --reference="$pictures_dir" "$custom_wallpapers_dir"  
fi

if [ ! -d "$themes_dir" ]; then
  mkdir "$themes_dir"
fi

if [ ! -d "$icons_dir" ]; then
  mkdir "$icons_dir"
fi

unzip_dir="$(dirname "$(readlink -f "$0")")"

if [ -f "$unzip_dir/themes/WhiteSur-dark.zip" ]; then
  unzip -d "$themes_dir" "$unzip_dir/themes/WhiteSur-dark.zip" -x '__MACOSX/*'
fi

if [ -f "$unzip_dir/icons/capitaine-cursors.zip" ]; then
  unzip -d "$icons_dir" "$unzip_dir/icons/capitaine-cursors.zip" -x '__MACOSX/*'
fi

if [ -f "$unzip_dir/icons/BigSur.zip" ]; then
  unzip -d "$icons_dir" "$unzip_dir/icons/BigSur.zip" -x '__MACOSX/*'
fi

if [ -f "$unzip_dir/icons/BigSur-dark.zip" ]; then
  unzip -d "$icons_dir" "$unzip_dir/icons/BigSur-dark.zip" -x '__MACOSX/*'
fi

# Extract additional files
if [ -f "$unzip_dir/BigSur-black.tar.xz" ]; then
  tar -xf "$unzip_dir/BigSur-black.tar.xz" -C "$themes_dir"
fi

if [ -f "$unzip_dir/BigSur-dark.zip" ]; then
  unzip -d "$themes_dir" "$unzip_dir/BigSur-dark.zip" -x '__MACOSX/*'
fi

if [ -f "$unzip_dir/BigSur.zip" ]; then
  unzip -d "$themes_dir" "$unzip_dir/BigSur.zip" -x '__MACOSX/*'
fi

if [ -f "$unzip_dir/capitaine-cursors.zip" ]; then
  unzip -d "$icons_dir" "$unzip_dir/capitaine-cursors.zip" -x '__MACOSX/*'
fi

if [ -f "$unzip_dir/Win11.tar.gz" ]; then
  tar -xzf "$unzip_dir/Win11.tar.gz" -C "$themes_dir"
fi

if [ -f "$unzip_dir/Win11.tar.xz" ]; then
  tar -xf "$unzip_dir/Win11.tar.xz" -C "$themes_dir"
fi

if [ -f "$unzip_dir/Win11.zip" ]; then
  unzip -d "$icons_dir" "$unzip_dir/Win11.zip" -x '__MACOSX/*'
fi


# Set permissions to match current user's home directory
if [ -d "$user_home" ]; then
  chown -R --reference="$user_home" "$themes_dir"
  chown -R --reference="$user_home" "$icons_dir"    
  chmod -R --reference="$user_home" "$themes_dir"
  chmod -R --reference="$user_home" "$icons_dir"
fi
