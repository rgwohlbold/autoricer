#!/bin/bash

if [ ! "$(whoami)" = "root" ] || [ "$SUDO_USER" = "" ]; then
    echo "Use sudo to execute this!"
    exit
fi

install_pkg() {
    res=$(pacman -Q make >/dev/null 2>&1)
    if [ $? = 1 ]; then
        echo "Installing base-devel..." >&2
        pacman -S base-devel --noconfirm 2>&1 || echo "Failed to install base-devel, exiting..." && exit 1
    fi

    # Set makeflags to -j{number of cores + 1}
    echo "Configuring makepkg..." >&2
    threads=$(( $(nproc --all) + 1))
    sed "s/-j5/-j${threads}/g" ./pkg/makepkg.conf > /etc/makepkg.conf

    echo "Installing yay AUR helper..." >&2
    # Install yay AUR helper
    sudo -u "$SUDO_USER" git clone -q https://aur.archlinux.org/yay || echo "Failed to install yay, exiting..." >&2 && exit 1
    cd yay
    sudo -u "$SUDO_USER" makepkg -si --noconfirm 2>&1 || echo "Failed to install yay, exiting..." >&2 && exit 1
    cd ..
    rm -rf yay/


    echo "Installing basic packages..." >&2
    # Install packages
    sudo -u "$SUDO_USER" yay -S --quiet --needed --noconfirm --sudoloop - < ./pkg/packages.txt 2>&1 || echo "Failed to install basic packages, exiting..." >&2 && exit 1
    if sudo -u "$SUDO_USER" yay -R --quiet --noconfirm --sudoloop rxvt-unicode 2>&1; then
        sudo -u "$SUDO_USER" yay -S --quiet --noconfirm --sudoloop rxvt-unicode-patched 2>&1
    else
        echo "Failed to remove rxvt-unicode, terminal will not have fixed font spacing" >&2
    fi

    # Install extra packages if user wants it
    case "$1" in
        *[yY])
            echo "Installing extra packages..." >&2
            yay -S --quiet --noconfirm --sudoloop - < ./pkg/extra.txt 2>&1 || echo "Failed to install extra packages, continuing..." >&2
            ;;
    esac
}


config_xorg() {
    # If using intel drivers, use TearFree option
    if [ "$1" = "y" ]; then
        echo "Installing intel drivers" >&2
        cp ./xorg/20-intel.conf /etc/X11/xorg.conf.d/
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
