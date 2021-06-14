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
" $HOME/.config/nvim/plugins/nerdtree.vim
"

nnoremap <C-n> :NERDTreeToggle<CR>		" Open NERDTree
let NERDTreeQuitOnOpen=1        		" Closes NERDTree after opening a file
autocmd BufWinEnter * silent NERDTreeMirror	" Open the existing NERDTree on each new tab

" Exit Vim if NERDTree is the only window left
autocmd BufEnter * if tabpagenr('$') == 1 && winnr('$') == 1 && exists('b:NERDTree') && b:NERDTree.isTabTree() |
    \ quit | endif

