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
" $HOME/.config/nvim/general.vim
"

colorscheme zero				" Colors
syntax on
let g:prettier#autoformat_require_pragma = 0
set cursorline					" Togle's the current line indicator
set number					" Number line indicator
set relativenumber				" Relative number indicator
set wrap					" Active word warp
set mouse=a					" Activate mouse
set clipboard=unnamedplus			" Use the same clipboard as system
set autoindent
set noswapfile
set lazyredraw
set shada="NONE"
highlight Normal ctermbg=none

" Active 256 true color
if exists('+termguicolors')
  let &t_8f = "\<Esc>[38;2;%lu;%lu;%lum"
  let &t_8b = "\<Esc>[48;2;%lu;%lu;%lum"
  set termguicolors
endif

" Lightline
let g:lightline = { 'colorscheme': 'zero' }
set noshowmode					" To remove the --INSERT-- in command line
set cmdheight=1
set cmdwinheight=3

" Markdown
let g:vim_markdown_folding_disabled = 1

" NeoVim Config
let mapleader=","
set hidden
set viminfo='100,n$HOME/.config/nvim/files/info/viminfo
set clipboard+=unnamedplus			" Give NVim the ability to copy and paste from and to other programs (require Xclip)

" i3config File Detection
aug i3config_ft_detection
  au!
  au BufNewFile,BufRead ~/.config/i3/config set filetype=i3config
aug end

au BufNewFile,BufRead * if &syntax == 'conf' | set syntax=sh | endif

" set 4 spaces tab
set tabstop=8
set softtabstop=0
set expandtab
set shiftwidth=4
set smarttab
