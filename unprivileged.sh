#!/bin/bash

config_xorg(){
    # Make Xorg configurations
    echo "Configuring xorg..." >&2
    cp ./xorg/.xinitrc ./xorg/.Xresources "$HOME"

}

config_i3() {
    # Make i3-gaps configuration
    echo "Configuring i3wm..." >&2
    mkdir -p ~/.config/i3
    cp ./i3/config "$HOME/.config/i3/"

}

config_lock() {
    echo "Configuring lock screen..." >&2
    mkdir -p "$HOME/Pictures"
    cp ./i3/wallpaper.jpg "$HOME/Pictures/wallpaper.jpg"
}


vimplugin() {
    if [ ! -d "$HOME/.vim/bundle/$2" ]; then
        echo "Installing vim plugin $2..." >&2
        git clone -q "$1" "$HOME/.vim/bundle/$2" >> out.log
    fi
}

config_vim() {
    echo "Configuring vim" >&2
    # Install pathogen and make vim configuration
    mkdir -p "$HOME/.vim/autoload" "$HOME/.vim/bundle" && \
    curl -LSso "$HOME/.vim/autoload/pathogen.vim" https://tpo.pe/pathogen.vim
    cp ./vim/.vimrc "$HOME"

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
    mkdir -p "$HOME/.vim/colors"
    if [ ! -f "$HOME/.vim/colors/PaperColor.vim" ]; then
        curl https://raw.githubusercontent.com/NLKNguyen/papercolor-theme/master/colors/PaperColor.vim > "$HOME/.vim/colors/PaperColor.vim"
    fi
}

config_fish() {
    echo "Configuring fish..." >&2
    if [ ! -d "$HOME/.local/share/omf" ]; then
        curl -L https://get.oh-my.fish | fish >&2
    else
        fish -c "omf update; exit"
    fi
    if [ ! -d "$HOME/.local/share/omf/pkg/bang-bang" ] || [ ! -d "$HOME/.local/share/omf/themes/bobthefish" ] ; then
        fish -c "omf install bobthefish; omf install bang-bang; exit"
    fi
    cp ./fish/config.fish "$HOME/.config/fish/config.fish"
}

config_music() {
    echo "Configuring mpd..." >&2
    mkdir -p "$HOME/.config/mpd"
    mkdir -p "$HOME/Music"
    cp ./mpd/mpd.conf "$HOME/.config/mpd/"

    echo "Configuring ncmpcpp..." >&2
    mkdir -p "$HOME/.ncmpcpp"
    cp ./ncmpcpp/bindings "$HOME/.ncmpcpp/"
}

main() {
    config_xorg
    config_i3
    config_lock
    config_vim
    config_fish
    config_music
}

main >> out.log
