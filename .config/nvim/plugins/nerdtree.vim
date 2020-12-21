"   __ _  ____ ___
"  / _` ||_  // __| GITHUB:https://github.com/gabrielzschmitz
" | (_| | / / \__ \ INSTAGRAM:https://www.instagram.com/gabrielz.schmitz/
"  \__, |/___||___/ DOTFILES:https://github.com/gabrielzschmitz/dotfiles/
"  |___/
"
" $HOME/.config/nvim/plugins/nerdtree.vim
"

nnoremap <C-n> :NERDTreeToggle<CR>		" Open NERDTree
let NERDTreeQuitOnOpen=1        		" Closes NERDTree after opening a file
autocmd BufWinEnter * silent NERDTreeMirror	" Open the existing NERDTree on each new tab

" Exit Vim if NERDTree is the only window left
autocmd BufEnter * if tabpagenr('$') == 1 && winnr('$') == 1 && exists('b:NERDTree') && b:NERDTree.isTabTree() |
    \ quit | endif

