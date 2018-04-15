#!/bin/bash

if [ ! "$(whoami)" = "root" ]; then
    echo "This operation needs root privileges."
    exit
fi

read -p "What is your username? " user
read -p "Install extra packages? " extra


# Add user and their groups
useradd -m -g users -s /bin/bash "$user"
gpasswd -a "$user" wheel
gpasswd -a "$user" video
gpasswd -a "$user" audio


# Install yay AUR helper
git clone https://aur.archlinux.org/yay
cd yay
su "$user" -c "makepkg -si --noconfirm"
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
cp ./.xinitrc ./.Xresources "/home/$user/"
cp ./20-intel.conf /etc/X11/xorg.conf.d/

# Make i3-gaps configuration
rm -rf "/home/$user/.config/i3/"
cp -r ./i3/ "/home/$user/.config/i3/"

# Install pathogen and make vim configuration
mkdir -p ~/.vim/autoload ~/.vim/bundle && \
curl -LSso ~/.vim/autoload/pathogen.vim https://tpo.pe/pathogen.vim
cp ./.vimrc "/home/$user/"

