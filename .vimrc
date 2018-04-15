" No vi compatibility
set nocompatible

" Syntax on
syntax on

" Turn on plugins, indent and filetype detection
filetype plugin indent on

" Set tabs to be four spaces
set tabstop=4
set shiftwidth=4
set expandtab
set autoindent
set smartcase
set background=dark

" Colorscheme ceudah
" set Vim-specific sequences for RGB colors
"let &t_8f = "\<Esc>[38;2;%lu;%lu;%lum"
"let &t_8b = "\<Esc>[48;2;%lu;%lu;%lum"
" These only for termite
"set t_Co=256
"set termguicolors
silent! colorscheme PaperColor

" Set line numbers to be hybrid
set number
set relativenumber

" Set autoresize width and eight
:let g:AUTORESIZE_ANOTHER_WINDOW_HEIGHT = 50
:let g:AUTORESIZE_ANOTHER_WINDOW_WIDTH = 50

let g:limelight_conceal_ctermfg = 'gray'
let g:limelight_conceal_ctermfg = 240

autocmd! User GoyoEnter Limelight
autocmd! User GoyoLeave Limelight!


" Execute pathogen
execute pathogen#infect()

" Airline settings
let g:airline_powerline_fonts = 1
let g:airline_theme = 'badwolf'

" Ycm config
let g:ycm_global_ycm_extra_conf = '/usr/share/vim/vimfiles/third_party/ycmd/cpp/ycm/.ycm_extra_conf.py'
let g:ycm_server_python_interpreter = '/usr/bin/python2'

"set laststatus=2

set directory=/tmp
set viewoptions=cursor,folds,slash,unix


" KEY REMAPPING


" Set window navigation to Ctrl+hjkl
nnoremap <C-h> <C-w>h
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-l> <C-w>l

" Use F1 for NerdTree
map <F1> :NERDTreeToggle<CR>

" Use F2 and F3 for tab navigation
map <F2> gT
map <F3> gt

" Use F4 and F5 for clipboard
map <F4> "*y
map <F5> "*p

map <F6> :Goyo<CR>

" Map F8 for ctags
noremap <F7> :Ack<Space>
noremap <F8> :TagbarToggle<CR>

" Map Arrow Keys to do nothing
noremap <Up> <Nop>
noremap <Down> <Nop>
noremap <Left> <Nop>
noremap <Right> <Nop>

" Remaps for German keyboard
noremap ß `
noremap ßß ``
noremap ö ^

nnoremap j gj
nnoremap k gk

" Use tab for tabbing
nnoremap <Tab> >>
vnoremap <Tab> >>

" Jump to <++> with double semicolon
inoremap ;; <Esc>/<++><Enter>"_c4l
"inoremap ;, <Esc>/<++><Enter>dd
nnoremap ;; /<++><Enter>"_c4l
inoremap ;. <Esc>/<++><Enter>dd
nnoremap ;. /<++><Enter>dd
inoremap ;<Esc> ;<Esc>

" Write with sudo
cmap w!! w !sudo tee % >/dev/null


" SPECIFIC FILETYPES


" Some HTML first
function HTML_inline(command, tag)
    execute "autocmd FileType html,php inoremap" . a:command . "  <" . a:tag . "></" . a:tag . "><Enter><++><Esc><F<?<<Enter>i"
    execute "autocmd FileType html,php nnoremap" . a:command . " i<" . a:tag . "></" . a:tag . "><Enter><++><Esc><F<?<<Enter>i"
endfunction

function HTML_inline_extra(command, tag, extra)
    execute "autocmd FileType html,php inoremap" . a:command . "  <" . a:tag . " " . a:extra . "=\"<Esc>mpa\"></" . a:tag . "><Enter><++><Esc>`pa"
    execute "autocmd FileType html,php nnoremap" . a:command . " i<" . a:tag . " " . a:extra . "=\"<Esc>mpa\"></" . a:tag . "><Enter><++><Esc>`pa"
endfunction

function HTML_return(command, tag)
    execute "autocmd FileType html,php inoremap " . a:command . "  <" . a:tag . "><Esc>mpa<Enter></" . a:tag . "><Enter><++><Esc>`po"
    execute "autocmd FileType html,php nnoremap " . a:command . " i<" . a:tag . "><Esc>mpa<Enter></" . a:tag . "><Enter><++><Esc>`po"
endfunction

function HTML_return_extra(command, tag, extra)
    execute "autocmd FileType html,php inoremap " . a:command . "  <" . a:tag . " " . a:extra . "=\"<Esc>mpa\"><Enter><++><Enter></" . a:tag . "><Enter><++><Esc>`pa"
    execute "autocmd FileType html,php nnoremap " . a:command . " i<" . a:tag . " " . a:extra . "=\"<Esc>mpa\"><Enter><++><Enter></" . a:tag . "><Enter><++><Esc>`pa"
endfunction

call HTML_inline(";ti", "title")
call HTML_inline(";h1", "h1")
call HTML_inline(";h2", "h2")
call HTML_inline(";h3", "h3")
call HTML_inline(";st", "b")
call HTML_inline(";it", "i")
call HTML_inline(";li", "li")
call HTML_inline(";spa", "span")

call HTML_inline_extra(";spi", "span", "id")
call HTML_inline_extra(";spc", "span", "class")

call HTML_return(";ht",  "html")
call HTML_return(";he" , "head")
call HTML_return(";bo" , "body")
call HTML_return(";ul" , "ul")
call HTML_return(";ol" , "ol")
call HTML_return(";div", "div")

call HTML_return_extra(";dic", "div", "class")
call HTML_return_extra(";dii", "div", "id")



let g:tex_flavor = "latex"
"autocmd Filetype tex setl updatetime=5
let g:livepreview_previewer = 'evince'

function TeX_exec(command)
    execute "autocmd FileType tex " . a:command
endfunction

function TeX_add(short, command)
    call TeX_exec("inoremap " . a:short . "  " . a:command)
    call TeX_exec("nnoremap " . a:short . " i" . a:command)
endfunction

function TeX_inline(command, elem)
    call TeX_add(";"    . a:command, "\\" . a:elem .  "{}<Enter><++><Esc>k$i")
    call TeX_add(";+"   . a:command, "\\" . a:elem .  "[<Esc>mpa]{<++>}<Enter><++><Esc>`pa")
    call TeX_add(";*+"  . a:command, "\\" . a:elem . "*[<Esc>mpa]{<++>}<Enter><++><Esc>`pa")
    "call TeX_add(";*"   . a:command, "\\" . a:elem . "*{}<Enter><++><Esc>k$i")
endfunction

function TeX_simple(command, name)
    call TeX_add(";"     . a:command, "\\" . a:name .  "<Space>")
    call TeX_add(";*"    . a:command, "\\" . a:name . "*<Space>")
endfunction

function TeX_block(command, name)
    call TeX_add(";"    . a:command, "\\begin{" . a:name .  "}<Enter><Esc>mpa<Enter>\\end{" . a:name . "}<Enter><++><Esc>`pa")
    call TeX_add(";*"   . a:command, "\\begin{" . a:name . "*}<Enter><Esc>mpa<Enter>\\end{" . a:name . "}<Enter><++><Esc>`pa")
endfunction

function TeX_begin_end(name)
    execute "normal! i\\begin{" . a:name . "}\n\<esc>mpa\n\\end{" . a:name . "}\n<++>\<esc>`p"
endfunction

function TeX_begin_end_prompt()
    let name = input("Name of the block: ")
    call TeX_begin_end(name)
endfunction


autocmd FileType tex nnoremap ;beg :call TeX_begin_end_prompt()<Enter>
autocmd FileType tex inoremap ;beg <Esc>:call TeX_begin_end_prompt()<Enter>

" Header
call TeX_inline("doc", "documentclass")
call TeX_inline("pkg", "usepackage")
call TeX_inline("new", "newcommand")
call TeX_inline("tit", "title")
call TeX_inline("aut", "author")
call TeX_inline("dat", "date")
call TeX_simple("mak", "maketitle")
call TeX_block ("bdo", "document")

" Sections
call TeX_inline("sec", "section")
call TeX_inline("sse", "subsection")
call TeX_inline("sss", "subsubsection")
call TeX_inline("par", "paragraph")

" Special markup
call TeX_inline("bol", "textbf")
call TeX_inline("ita", "textit")
call TeX_inline("und", "underline")
call TeX_inline("lef", "flushleft")
call TeX_inline("cen", "center")
call TeX_inline("rig", "flushright")

" Images
call TeX_inline("inc", "includegraphics")
call TeX_block ("bfi", "figure")
call TeX_inline("cap", "caption")

" Labels and references
call TeX_inline("lab", "label")
call TeX_inline("ref", "ref")

" Lists
call TeX_block ("bit", "itemize")
call TeX_block ("ben", "enumerate")
call TeX_simple("ite", "item")

" Presentation stuff
call TeX_block ("bfr", "frame")
call TeX_inline("frt", "frametitle")

