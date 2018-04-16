#!/bin/bash

if [ ! "$(whoami)" = "root" ] || [ "$SUDO_USER" = "" ]; then
    echo "Use sudo to execute this!"
    exit
fi

log() {
    echo "$1"
}

install_pkg() {
    res=$(pacman -Q make >/dev/null 2>&1)
    if [ $? = 1 ]; then
        log "Installing base-devel"
        pacman -S base-devel --noconfirm
    fi

    log "Installing yay AUR helper"
    # Install yay AUR helper
    sudo -u "$SUDO_USER" git clone https://aur.archlinux.org/yay
    cd yay
    echo $SUDO_USER
    sudo -u "$SUDO_USER" makepkg -si --noconfirm
    cd ..
    rm -rf yay/

    # TODO add MAKEFLAGS=-j5 to makepkg.conf

    log "Installing packages..."
    # Install packages
    sudo -u "$SUDO_USER" yay -S --needed --noconfirm --sudoloop - < packages.txt
    sudo -u "$SUDO_USER" yay -R --noconfirm --sudoloop rxvt-unicode
    sudo -u "$SUDO_USER" yay -S --noconfirm --sudoloop rxvt-unicode-patched

    # Install extra packages if user wants it
    case "$1" in
        *[yY])
            log "Installing extra packages..."
            yay -S --noconfirm --sudoloop - < extra.txt | tee realout
            ;;
    esac
}


config_xorg() {
    # If using intel drivers, use TearFree option
    if [ "$1" = "y" ]; then
        log "Installing intel drivers"
        cp ./20-intel.conf /etc/X11/xorg.conf.d/
    fi
}

config_lock() {
    log "Installing lock screen..."
    if [ -f /usr/bin/xflock4 ]; then
        rm /usr/bin/xflock4
    fi
    cp ./xflock4 /usr/local/bin/xflock4
}


main() {
    #install_pkg "$1"
    config_xorg "$2"
    config_lock
}

mkfifo realout
cat realout &

read -p "Install extra packages? " extra
read -p "Intel drivers? " intel
main "$extra" "$intel"
sudo -u "$SUDO_USER" ./unprivileged.sh
rm realout
