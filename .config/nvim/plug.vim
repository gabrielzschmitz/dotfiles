"         .             .              .                  
"         |             |              |           .      
" ,-. ,-. |-. ,-. . ,-. |  ,_, ,-. ,-. |-. ,-,-. . |- ,_, 
" | | ,-| | | |   | |-' |   /  `-. |   | | | | | | |   /  
" `-| `-^ ^-' '   ' `-' `' '"' `-' `-' ' ' ' ' ' ' `' '"' 
"  ,|                                                     
"  `'                                                     
" GITHUB:https://github.com/gabrielzschmitz               
" INSTAGRAM:https://www.instagram.com/gabrielz.schmitz/   
" DOTFILES:https://github.com/gabrielzschmitz/dotfiles/   
"
" $HOME/.config/nvim/plug.vim
"

call plug#begin('~/.config/nvim/plugged')

Plug 'neoclide/coc.nvim', {'branch': 'release'}	" Code snippet
Plug 'ap/vim-css-color'                         " Show colors
Plug 'itchyny/lightline.vim'                    " Lightline
Plug 'junegunn/goyo.vim'                        " Distraction free
Plug 'ptzz/lf.vim'		                " LF file manager in NVim
Plug 'voldikss/vim-floaterm'                    " Floating LF

call plug#end()

