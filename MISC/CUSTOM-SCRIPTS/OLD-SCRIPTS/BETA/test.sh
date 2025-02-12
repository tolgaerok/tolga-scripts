#!/bin/bash


host_name=$(dialog --stdout --title "Hostname" \
        --inputbox "Enter your hostname:" 0 0)


full_name=$(dialog --stdout --title "Full Name" \
        --inputbox "Enter your full name:" 0 0)

user=$(dialog --stdout --title "Username" \
        --inputbox "Enter your username:" 0 0)

passwd=$(dialog --stdout --title "Password" \
        --inputbox "Enter your password:" 0 0)



options=(
        "iperv3 seq" "" on
        "iperv3 par" "" on
        "curl txt file" "" on
        "curl zip file" "" on
        "wget txt file" "" on
        "wget zip file" "" on
        "scp send txt file" "" on
        "scp send zip file" "" on
        "scp get txt file" "" on
        "scp get file" "" on
        )

# Show menu
choice=$(dialog --stdout \
                --checklist "Choose one or more options:" \
                0 0 0 \
                "${options[@]}")

# Process selection
for i in $choice; do
    case $i in
        *1*)
            echo "Option 1 selected"
            ;;
        *2*)
            echo "Option 2 selected"
            ;;
        *3*)
            echo "Option 3 selected"
            ;;
        *4*)
            echo "Option 4 selected"
            ;;
    esac
done