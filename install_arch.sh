#!/bin/bash

set -e

echo "Creating a backup of current configurations..."
mkdir -p ~/backups
cp -r ~/.config/ ~/backups/
cp ~/.bashrc ~/backups/
echo "Backup saved to ~/backups/"

echo "Updating system and installing official packages..."
if [ -f "./arch_official.txt" ]; then
  sudo pacman -Syu --needed --noconfirm
  sudo pacman -S --needed --noconfirm $(cat ./arch_official.txt)
else
  echo "Error: ./arch_official.txt not found!"
  exit 1
fi

echo "Installing AUR packages via yay..."
if [ -f "./arch_aur.txt" ]; then
  if ! command -v yay &>/dev/null; then
    echo "Error: yay is not installed. Please install it before running this script."
    exit 1
  fi
  yay -S --needed --noconfirm $(cat ./arch_aur.txt)
else
  echo "Warning: ./arch_aur.txt not found"
  exit 1
fi

echo "Installing Zenburn theme and terminus font..."
yay -S --needed --noconfirm zenburn-gtk-theme-git terminus-font || echo "Failed to install theme/font automatically, please check package names in AUR."

echo "Copying new configuration files..."

cp -r ./.local/* ~/.local/ 2>/dev/null || echo "./.local/ is empty or missing"
cp -r ./.config/* ~/.config/ 2>/dev/null || echo "./.config/ is empty or missing"
if [ -f "./.bashrc" ]; then
  cp ./.bashrc ~/.bashrc
fi

echo "All tasks completed successfully!"
read -p "Reboot the system now? (y/n): " choice
case "$choice" in
y | Y)
  echo "Rebooting..."
  reboot
  ;;
*) echo "Reboot canceled. Don't forget to reboot manually later." ;;
esac
