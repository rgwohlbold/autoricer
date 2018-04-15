#!/bin/bash

if [ "$(whoami)" = "root" ]; then
    echo "Do not execute this as root!"
    exit
fi

read -p "Install extra packages? " extra
sudo touch /tmp/hello
sudo rm /tmp/hello

home="$HOME"

sudo pacman -S base-devel

# Install yay AUR helper
git clone https://aur.archlinux.org/yay
cd yay
makepkg -si --noconfirm
cd ..
rm -rf yay/

# Install packages
yay -S --noconfirm - < packages.txt

# Install extra packages if user wants it
case $extra in
    *[yY])
        yay -S --noconfirm - < extra.txt
        ;;
esac

# Make Xorg configurations
cp ./.xinitrc ./.Xresources "$home"
cp ./20-intel.conf /etc/X11/xorg.conf.d/

# Make i3-gaps configuration
rm -rf "$home/.config/i3/"
cp -r ./i3/ "$home/.config/i3/"

# Install pathogen and make vim configuration
mkdir -p ~/.vim/autoload ~/.vim/bundle && \
curl -LSso ~/.vim/autoload/pathogen.vim https://tpo.pe/pathogen.vim
cp ./.vimrc "$home"

