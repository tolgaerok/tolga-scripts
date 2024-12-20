#!/bin/bash

# Tolga Erok .............
# 12/1/2024
# Image converter using ImageMagick

check_imagick() {
    if ! command -v convert &>/dev/null; then
        read -p "ImageMagick is not installed. Do you want to install it? (y/n): " install_response
        if [ "$install_response" == "y" ]; then
            sudo dnf install ImageMagick
        else
            echo "ImageMagick is required for image conversion. Please install it and run the script again."
            exit 1
        fi
    fi
}

# Function to convert images in the current directory (PWD)
convert_images() {
    output_folder="CONVERTED"
    output_format="$1"

    # Create output folder if not existss
    mkdir -p "$output_folder"

    # Get a list of image files in the current directory (PWD)
    image_files=(*.{png,jpg,jpeg,gif,bmp,tiff,avif,heic})

    # Check if there are any images to convert
    if [ "${#image_files[@]}" -eq 0 ]; then
        echo "No images found for conversion."
        exit 1
    fi

    # count and show their extensions
    echo "Found ${#image_files[@]} image(s) with extension(s): $(printf "%s\n" "${image_files[@]##*.}" | sort -u | tr '\n' ' ')"

    # Loop through the image files in the current directory like a whore
    for file_path in "${image_files[@]}"; do

        # Extract file name and extension
        file_name=$(basename "$file_path")
        file_base="${file_name%.*}"

        # Convert the image to the chosen, specified format and suppress errors
        convert "$file_path" "$output_folder/${file_base}-converted.$output_format" 2>/dev/null && echo "Converted: $file_name to $output_format"
    done
}

# Check if ImageMagick is installed
check_imagick

# Prompt user for chosen output format
read -p "Enter the desired output format (e.g., jpg, png, avif, heic): " output_format

# Start tp convert images
convert_images "$output_format"

echo "Conversion complete."
