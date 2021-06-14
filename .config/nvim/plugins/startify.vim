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
" $HOME/.config/nvim/plugins/startify.vim
"

let g:startify_session_dir = '~/.config/nvim/session'
let g:startify_custom_header = [
        \ '        .             .              .                  ',
        \ '        |             |              |           .      ',
        \ ',-. ,-. |-. ,-. . ,-. |  ,_, ,-. ,-. |-. ,-,-. . |- ,_, ',
        \ '| | ,-| | | |   | |-" |   /  `-. |   | | | | | | |   /  ',
        \ '`-| `-^ ^-" "   " `-" `" """ `-" `-" " " " " " " `" """ ',
        \ ' ,|                                                     ',
        \ ' `"                                                     ',
	\ ]
let g:startify_bookmarks = [
        \ { 'c': '~/.config/i3/config' },
        \ { 'i': '~/.config/nvim/init.vim' },
        \ { 'z': '~/.zshrc' },
	\ { 'p': '~/.config/nvim/plugins' },
        \ ]
let g:startify_lists = [
        \ { 'type': 'bookmarks',        'header': ['    Favorites'] },
        \ { 'type': 'dir',              'header': ['    Current Directory '. getcwd()] },
        \ { 'type': 'files',            'header': ['    Files'] },
        \ ]

