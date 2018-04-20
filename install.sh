#!/bin/bash

# Creates a new user, adds him to wheel and uncomments the policy in /etc/sudoers
create_user() {
    pacman -S sudo >> out.log
    username="$1"
    useradd -s /bin/bash -m -g users "$username"
    sed 's/# *%wheel ALL=(ALL) ALL/%wheel ALL=(ALL) ALL/g' /etc/sudoers > /etc/sudoers
    chmod 440 /etc/sudoers
    grep -q wheel /etc/group
    if [ $? = "1" ]; then
        groupadd wheel
    fi
    gpasswd -a "$username" wheel
}

install_pkg() {
    # Update packacke database
    echo "Synchronizing package databases..."
    pacman -Syy 2>&1

    # Install base-devel if not yet installed
    res=$(pacman -Q make >/dev/null 2>&1)
    if [ $? = 1 ]; then
        echo "Installing base-devel..." >&2
        pacman -S base-devel --noconfirm 2>&1 || (echo "Failed to install base-devel, exiting..." >&2 && exit 1)
    fi

    # Set makeflags to -j{number of cores + 1}
    echo "Configuring makepkg..." >&2
    threads=$(( $(nproc --all) + 1))
    sed "s/-j5/-j${threads}/g" ./pkg/makepkg.conf > /etc/makepkg.conf

    # Install yay AUR helper
    echo "Installing yay AUR helper..." >&2
    sudo -u "$SUDO_USER" git clone -q https://aur.archlinux.org/yay || (echo "Failed to install yay, exiting..." >&2 && exit 1)
    cd yay
    sudo -u "$SUDO_USER" makepkg -si --noconfirm 2>&1 || (echo "Failed to install yay, exiting..." >&2 && exit 1)
    cd ..
    rm -rf yay/

    # Install basic packages
    echo "Installing basic packages..." >&2
    sudo -u "$SUDO_USER" yay -S --quiet --needed --noconfirm --sudoloop - < ./pkg/packages.txt 2>&1 || (echo -e "Failed to install basic packages, exiting...\nYou may want to update your mirrorlist" >&2 && exit 1)

    # Install rxvt-unicode-patched
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

config_shell() {
    echo "Setting fish as default shell..." >&2
    chsh -s /usr/bin/fish "$SUDO_USER"
}


main() {
    install_pkg "$1"
    config_xorg "$2"
    config_lock
    config_shell
}

# This has to be executed as root
if [ ! "$(whoami)" = "root" ]; then
    echo "This operation requires root privileges"
    exit 1
fi

# If this is not executed as sudo or if the sudo user is root, ask for the username or create a new user
if [ ! "$SUDO_USER" ] || [ "$SUDO_USER" = "root" ]; then
    read -p "Create user? (y/n) " create_user
    if [ "$create_user" = "y" ]; then
        read -p "What should be your username? " username
        while [ ! "$username" ]; do
            echo "Empty username!"
            read -p "What should be your username? " username
        done
        create_user "$username"
    else
        read -p "What is your username? " username
        while [ ! -d "/home/$username" ]; do
            echo "User does not exist! "
            read -p "What is your username? " username
        done
    fi
    SUDO_USER="$username"
fi


read -p "Install extra packages? (y/n) " extra
read -p "Intel drivers? (y/n) " intel

main "$extra" "$intel" | sudo -u "$SUDO_USER" tee out.log >/dev/null
sudo -u "$SUDO_USER" ./config.sh
