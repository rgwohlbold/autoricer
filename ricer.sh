#!/bin/bash

if [ ! "$(whoami)" = "root" ]; then
    echo "This operation needs root privileges."
    exit
fi

# Install yay AUR helper
git clone https://aur.archlinux.org/yay
cd yay
makepkg -si --noconfirm
cd ..
rm -rf yay/

yay -S --noconfirm - < packages.txt

# betterlockscreen
# https://github.com/pavanjadhaw/betterlockscreen

