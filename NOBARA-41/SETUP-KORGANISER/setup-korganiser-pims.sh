#!/bin/bash
# tolga erok
# 18/12/2024

# Script to install KOrganizer, KDE PIM suite, and related packages on Fedora

echo "Starting installation of KDE PIM suite and related addons..."

echo "Updating system..."
sudo dnf update -y

echo "Installing KOrganizer and Akonadi components..."
sudo dnf install -y korganizer akonadi akonadi-server akonadi-calendar akonadi-mime akonadi-notes

echo "Installing KDE PIM suite (Kontact, KMail, KAddressBook, etc.)..."
sudo dnf install -y kontact kmail kaddressbook kalarm kjots kdepim-runtime kdepim-common kdepim-addons

echo "Installing additional KDE PIM tools and addons..."
sudo dnf install -y akonadi-import-wizard akonadi-contacts kde-telepathy

echo "Starting Akonadi server..."
akonadictl start

echo "Verifying Akonadi server status..."
akonadictl status

echo "Cleaning up..."
sudo dnf autoremove -y

echo "KDE PIM suite and related tools have been successfully installed!"
