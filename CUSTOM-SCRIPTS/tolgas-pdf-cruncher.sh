#!/bin/bash
# Tolga Erok
# pdf size reducer

# Current PWD of script
script_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Check arguments is providedd
if [ "$#" -lt 1 ]; then
  echo "Usage: pdfcompress <input1> [input2] ..."
  exit 1
fi

# Loop input files
for input_file in "$@"; do

  # Output file = input file
  output_file="${input_file%.pdf}-compressed.pdf"

  # Does input file exist?
  if [ ! -f "$input_file" ]; then
    echo -e "\e[33mWarning: The specified input file '$input_file' does not exist. Skipping...\e[0m"
    continue
  fi

  # Array of Ghostscript options
  options=("Screen (Low quality)" "Ebook (Medium quality)" "Printer (High quality)" "Prepress (Highest quality)")

  # Display the list of options in yelloww
  echo -e "\e[33mChoose Ghostscript option for $input_file to $output_file:\e[0m"
  select option in "${options[@]}"; do
    case $REPLY in
      1) gs_options="-dPDFSETTINGS=/screen"; break;;
      2) gs_options="-dPDFSETTINGS=/ebook"; break;;
      3) gs_options="-dPDFSETTINGS=/printer"; break;;
      4) gs_options="-dPDFSETTINGS=/prepress"; break;;
      *) echo -e "\e[33mInvalid option. Please choose a number between 1 and 4.\e[0m"; continue;;
    esac
  done

  # Run Ghostscript command
  gs_command="gs -dNOPAUSE -dBATCH -sDEVICE=pdfwrite $gs_options -sOutputFile=$output_file $input_file"
  echo "Running Ghostscript command: $gs_command"
  $gs_command

  # Check if Ghostscript command was successful
  if [ $? -eq 0 ]; then
    echo -e "\e[32mConversion successful. Output file: $output_file\e[0m"
  else
    echo -e "\e[31mError during conversion. Please check your input and options.\e[0m"
  fi
done
