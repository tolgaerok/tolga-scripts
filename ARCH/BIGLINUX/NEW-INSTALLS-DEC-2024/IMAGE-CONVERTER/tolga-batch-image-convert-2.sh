#!/bin/bash

# Tolga Erok .............
# 12/1/2024
# Image converter using ImageMagick

### Constants and Variables ###
OUTPUT_FOLDER="CONVERTED"
SUPPORTED_FORMATS="png jpg jpeg gif bmp tiff avif"

### Functions ###

check_imagick() {
    if ! command -v convert &>/dev/null; then
        read -p "ImageMagick is not installed. Install it? (y/n): " -n 1 -r
        echo
        if [[ "$REPLY" =~ ^[Yy]$ ]]; then
            sudo dnf install ImageMagick
        else
            echo "Please install ImageMagick and run the script again."
            exit 1
        fi
    fi
}

convert_images() {
    local output_format="$1"
    local image_files=()

    # Validate output format
    if [[ "$SUPPORTED_FORMATS" != *"$output_format"* ]]; then
        echo "Unsupported format: $output_format. Supported formats: $SUPPORTED_FORMATS"
        exit 1
    fi

    # Create output folder if not exists
    mkdir -p "$OUTPUT_FOLDER"

    # Get image files in the current directory (PWD)
    for ext in $SUPPORTED_FORMATS; do
        image_files+=(*."$ext")
    done

    # Check if there are any images to convert
    if [ ${#image_files[@]} -eq 0 ]; then
        echo "No images found for conversion."
        exit 1
    fi

    # Count and show their extensions
    local unique_ext=($(printf "%s\n" "${image_files[@]##*.}" | sort -u))
    echo "Found ${#image_files[@]} image(s) with extension(s): ${unique_ext[*]}"

    # Convert images in parallel using xargs for potential speedup
    printf "%s\n" "${image_files[@]}" | xargs -P "$(nproc)" -I {} bash -c \
        "convert {} \"$OUTPUT_FOLDER/{}-converted.$output_format\" 2>/dev/null && echo \"Converted: {} to $output_format\""
}

### Main Script ###

check_imagick

# Prompt user for chosen output format
while true; do
    read -p "Enter the desired output format ($SUPPORTED_FORMATS): " output_format
    if [[ "$SUPPORTED_FORMATS" == *"$output_format"* ]]; then
        break
    fi
    echo "Invalid format. Please choose from: $SUPPORTED_FORMATS"
done

# Start to convert images
convert_images "$output_format"

echo "Conversion complete."
