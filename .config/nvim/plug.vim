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
" General
Plug 'neoclide/coc.nvim', {'branch': 'release'}	" Code snippet
Plug 'ap/vim-css-color'                         " Show colors
Plug 'itchyny/lightline.vim'                    " Lightline
Plug 'mhinz/vim-startify'                       " Better NVim start screen
Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'} " Better colors

" File Explorer
Plug 'ptzz/lf.vim'		" LF file manager in NVim
Plug 'voldikss/vim-floaterm'	" Make LF a floating window

call plug#end()

