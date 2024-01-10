#!/bin/bash
# Tolga Erok
# pdf size reducer

# Current PWD of script
script_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Check arguments is providedd
if [ "$#" -ne 2 ]; then
  echo "Usage: pdfcompress <input_file> <output_file>"
  exit 1
fi

# Input and output
input_file="$1"
output_file="$2"

# Does input file exist?
if [ ! -f "$input_file" ]; then
  echo "Error: The specified input file does not exist."
  exit 1
fi

# Array of Ghostscript optionss
options=("Screen (Low quality)" "Ebook (Medium quality)" "Printer (High quality)" "Prepress (Highest quality)")

# Display options
echo "Choose Ghostscript option:"
select option in "${options[@]}"; do
  case $REPLY in
    1) gs_options="-dPDFSETTINGS=/screen"; break;;
    2) gs_options="-dPDFSETTINGS=/ebook"; break;;
    3) gs_options="-dPDFSETTINGS=/printer"; break;;
    4) gs_options="-dPDFSETTINGS=/prepress"; break;;
    *) echo "Invalid option. Please choose a number between 1 and 4."; continue;;
  esac
done

# Run Ghostscript command
gs_command="gs -dNOPAUSE -dBATCH -sDEVICE=pdfwrite $gs_options -sOutputFile=$output_file $input_file"
echo "Running Ghostscript command: $gs_command"
$gs_command

# Check if Ghostscript command was successful
if [ $? -eq 0 ]; then
  echo "Conversion successful. Output file: $output_file"
else
  echo "Error during conversion. Please check your input and options."
fi
