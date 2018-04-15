#!/bin/bash

if [ ! "$(whoami)" = "root" ] || [ "$SUDO_USER" = "" ]; then
    echo "Use sudo to execute this!"
    exit
fi

install_pkg() {
    res=$(pacman -Q make >/dev/null 2>&1)
    if [ $? = 1 ]; then
        echo "Installing base-devel..." >&2
        pacman -S base-devel --noconfirm
    fi

    echo "Installing yay AUR helper..." >&2
    # Install yay AUR helper
    sudo -u "$SUDO_USER" git clone https://aur.archlinux.org/yay
    cd yay
    echo $SUDO_USER
    sudo -u "$SUDO_USER" makepkg -si --noconfirm --quiet
    cd ..
    rm -rf yay/

    # TODO add MAKEFLAGS=-j5 to makepkg.conf

    echo "Installing basic packages..." >&2
    # Install packages
    sudo -u "$SUDO_USER" yay -S --quiet --needed --noconfirm --sudoloop - < packages.txt
    sudo -u "$SUDO_USER" yay -R --quiet --noconfirm --sudoloop rxvt-unicode
    sudo -u "$SUDO_USER" yay -S --quiet --noconfirm --sudoloop rxvt-unicode-patched

    # Install extra packages if user wants it
    case "$1" in
        *[yY])
            echo "Installing extra packages..." >&2
            yay -S --quiet --noconfirm --sudoloop - < extra.txt | tee realout
            ;;
    esac
}


config_xorg() {
    # If using intel drivers, use TearFree option
    if [ "$1" = "y" ]; then
        echo "Installing intel drivers" >&2
        cp ./20-intel.conf /etc/X11/xorg.conf.d/
    fi
}

config_lock() {
    echo "Installing lock screen..." >&2
    if [ -f /usr/bin/xflock4 ]; then
        rm /usr/bin/xflock4
    fi
    cp ./scripts/* /usr/local/bin/
}


main() {
    install_pkg "$1"
    config_xorg "$2"
    config_lock
}

read -p "Install extra packages? (y/n) " extra
read -p "Intel drivers? (y/n) " intel
main "$extra" "$intel" | sudo -u "$SUDO_USER" tee out.log
sudo -u "$SUDO_USER" ./unprivileged.sh
