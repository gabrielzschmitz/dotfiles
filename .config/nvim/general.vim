"   __ _  ____ ___
"  / _` ||_  // __| GITHUB:https://github.com/gabrielzschmitz
" | (_| | / / \__ \ INSTAGRAM:https://www.instagram.com/gabrielz.schmitz/
"  \__, |/___||___/ DOTFILES:https://github.com/gabrielzschmitz/dotfiles/
"  |___/
"
" $HOME/.config/nvim/general.vim
"

" Colors
colorscheme faint
syntax on
set cursorline					" Togle's the current line indicator
set number					" Number line indicator
set wrap					" Active word warp
highlight Normal ctermbg=none

" Active 256 true color
if exists('+termguicolors')
  let &t_8f = "\<Esc>[38;2;%lu;%lu;%lum"
  let &t_8b = "\<Esc>[48;2;%lu;%lu;%lum"
  set termguicolors
endif

" Lightline
let g:lightline = { 'colorscheme': 'faint' }
set noshowmode					" To remove the --INSERT-- in command line
set cmdheight=1
set cmdwinheight=3

" Markdown
let g:vim_markdown_folding_disabled = 1

" NeoVim Config
let mapleader=","
set hidden

