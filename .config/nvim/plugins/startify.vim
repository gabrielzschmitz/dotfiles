"   __ _  ____ ___  
"  / _` ||_  // __| GITHUB:https://github.com/gabrielzschmitz
" | (_| | / / \__ \ INSTAGRAM:https://www.instagram.com/gabrielz.schmitz/
"  \__, |/___||___/ DOTFILES:https://github.com/gabrielzschmitz/dotfiles/
"  |___/
"
" $HOME/.config/nvim/plugins/startify.vim
"

let g:startify_session_dir = '~/.config/nvim/session'
let g:startify_custom_header = [
        \ '                              _           ',
        \ '  __ _  ____ ___   _ ____   _(_)_ __ ___  ',
        \ ' / _` ||_  // __| | `_ \ \ / / | `_ ` _ \ ',
        \ '| (_| | / / \__ \ | | | \ V /| | | | | | |',
        \ ' \__, |/___||___/ |_| |_|\_/ |_|_| |_| |_|',
        \ ' |___/                                    ',
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

