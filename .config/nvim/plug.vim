"   __ _  ____ ___
"  / _` ||_  // __| GITHUB:https://github.com/gabrielzschmitz
" | (_| | / / \__ \ INSTAGRAM:https://www.instagram.com/gabrielz
"  \__, |/___||___/ DOTFILES:https://github.com/gabrielzschmitz/
"  |___/
"
" $HOME/.config/nvim/plug.vim
"

call plug#begin('~/.config/nvim/plugged')
" General
Plug 'prettier/vim-prettier'                            " Code formater
Plug 'neoclide/coc.nvim', {'branch': 'release'}         " Code snippet
Plug 'ap/vim-css-color'                                 " Show colors
Plug 'itchyny/lightline.vim'                            " Lightline
Plug 'ryanoasis/vim-devicons'                           " Icons everywhere
Plug 'mhinz/vim-startify'                               " Better NVim start screen

" File Explorers
Plug 'preservim/nerdtree'                               " File explorer in NVim
Plug 'kevinhwang91/rnvimr', {'do': 'make sync'}         " Ranger in a floating window on NVim

" Vim Wiki
Plug 'vimwiki/vimwiki'                                  " Vim Wiki
Plug 'godlygeek/tabular'                                " Tabular for markdown
Plug 'plasticboy/vim-markdown'                          " Markdown syntax
Plug 'mattn/calendar-vim'                               " A calendar for NeoVim
Plug 'iamcco/markdown-preview.nvim', { 'do': 'cd app && yarn install'  } " Markdown preview

" Languages Support
Plug 'othree/html5.vim'                                 " Html syntax
Plug 'hail2u/vim-css3-syntax'                           " Css syntax
Plug 'pangloss/vim-javascript'                          " Javascript syntax
Plug 'numirias/semshi', {'do': ':UpdateRemotePlugins'}  " Python syntax
call plug#end()
