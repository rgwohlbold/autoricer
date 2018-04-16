#!/bin/bash

config_xorg(){
    # Make Xorg configurations
    cp ./.xinitrc ./.Xresources ~/
}

config_i3() {
    # Make i3-gaps configuration
    mkdir -p ~/.config/i3
    cp -r ./i3/* ~/.config/i3

}

config_lock() {
    mkdir -p ~/Pictures
    cp ./wallpaper.jpg ~/Pictures/wallpaper.jpg
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
    mkdir ~/.vim/colors
    curl https://raw.githubusercontent.com/NLKNguyen/papercolor-theme/master/colors/PaperColor.vim > ~/.vim/colors/PaperColor.vim

}
