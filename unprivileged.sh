#!/bin/bash

config_xorg(){
    # Make Xorg configurations
    echo "Configuring Xorg..." >&2
    cp ./.xinitrc ./.Xresources $HOME/

}

config_i3() {
    # Make i3-gaps configuration
    echo "Configuring i3wm..." >&2
    mkdir -p ~/.config/i3
    cp -r ./i3/* $HOME/.config/i3

}

config_lock() {
    echo "Configuring lock screen..." >&2
    mkdir -p $HOME/Pictures
    cp ./wallpaper.jpg $HOME/Pictures/wallpaper.jpg
}


vimplugin() {
    echo "Installing vim plugin $2" >&2
    git clone "$1" "$HOME/.vim/bundle/$2" >> out.log
}

config_vim() {
    echo "Configuring vim" >&2
    # Install pathogen and make vim configuration
    mkdir -p $HOME/.vim/autoload $HOME/.vim/bundle && \
    curl -LSso $HOME/.vim/autoload/pathogen.vim https://tpo.pe/pathogen.vim
    cp ./.vimrc $HOME

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
    vimplugin https://github.com/vim-airline/vim-airline-themes vim-airline-themes
    vimplugin https://github.com/tpope/vim-commentary vim-commentary/      
    vimplugin https://github.com/tpope/vim-surround vim-surround/
    mkdir $HOME/.vim/colors
    curl https://raw.githubusercontent.com/NLKNguyen/papercolor-theme/master/colors/PaperColor.vim > $HOME/.vim/colors/PaperColor.vim

}

config_fish() {
    echo "Configuring fish..." >&2
    curl -L https://get.oh-my.fish | fish >&2
    fish -c "omf install bobthefish; omf install bang-bang; exit" >&2
    cp ./config.fish "$HOME/.config/fish/config.fish"
}

main() {
    config_xorg
    config_i3
    config_lock
    config_vim
    config_fish
}

main >> out.log
