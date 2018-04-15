#!/bin/bash

if [ "$(whoami)" = "root" ]; then
    echo "Do not execute this as root!"
    exit
fi


install_pkg() {
    if [ $(pacman -Q make >/dev/null 2>&1) ]; then
        sudo pacman -S base-devel --noconfirm
    fi

    # Install yay AUR helper
    git clone https://aur.archlinux.org/yay
    cd yay
    makepkg -si --noconfirm
    cd ..
    rm -rf yay/

    # TODO add MAKEFLAGS=-j5 to makepkg.conf

    # Install packages
    yay -S --needed --noconfirm - < packages.txt
    yay -R --noconfirm rxvt-unicode
    yay -S --noconfirm rxvt-unicode-patched

    # Install extra packages if user wants it
    case "$1" in
        *[yY])
            yay -S --noconfirm - < extra.txt
            ;;
    esac
}

config_xorg(){
    # Make Xorg configurations
    cp ./.xinitrc ./.Xresources ~

    # If using intel drivers, use TearFree option
    if [ "$1" = "y" ]; then
        sudo cp ./20-intel.conf /etc/X11/xorg.conf.d/
    fi
}

config_i3() {
    # Make i3-gaps configuration
    rm -rf "~/.config/i3/"
    cp -r ./i3/ "~/.config/i3/"

}

config_lock() {
    cp ./wallpaper.jpg ~/Pictures/wallpaper.jpg
    sudo rm /usr/bin/xflock4
    sudo cp ./xflock4 /usr/local/bin/xflock4
}


vimplugin() {
    git clone "$1" "~/.vim/bundle/$2"
}

config_vim() {
    # Install pathogen and make vim configuration
    mkdir -p ~/.vim/autoload ~/.vim/bundle && \
    curl -LSso ~/.vim/autoload/pathogen.vim https://tpo.pe/pathogen.vim
    cp ./.vimrc ""

    # Install vim plugins
    vimplugin https://github.com/mileszs/ack.vim ack.vim/    
    vimplugin https://github.com/junegunn/goyo.vim goyo.vim/      
    vimplugin https://github.com/junegunn/limelight.vim limelight.vim/  
    vimplugin https://github.com/majutsushi/tagbar tagbar/       
    vimplugin https://github.com/michaeljsmith/vim-indent-object vim-indent-object/
    vimplugin https://github.com/kien/ctrlp.vim ctrlp.vim/  
    vimplugin https://github.com/mboughaba/i3config.vim i3config.vim/  
    vimplugin https://github.com/scrooloose/nerdtree nerdtree/       
    vimplugin https://github.com/vim-airline/vim-airline vim-airline/  
    vimplugin https://github.com/tpope/vim-commentary vim-commentary/      
    vimplugin https://github.com/tpope/vim-surround vim-surround/
    curl https://raw.githubusercontent.com/NLKNguyen/papercolor-theme/master/colors/PaperColor.vim > ~/.vim/colors/ 

}


main() {
    read -p "Install extra packages? " extra
    reap -p "Intel drivers? " intel
    sudo touch /tmp/hello
    sudo rm /tmp/hello


    install_pkg "$extra"
    config_xorg "$intel"
    config_i3
    config_lock
    config_vim
}

main | tee out.log
