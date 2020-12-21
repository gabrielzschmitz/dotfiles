"   __ _  ____ ___
"  / _` ||_  // __| GITHUB:https://github.com/gabrielzschmitz
" | (_| | / / \__ \ INSTAGRAM:https://www.instagram.com/gabrielz.schmitz/
"  \__, |/___||___/ DOTFILES:https://github.com/gabrielzschmitz/dotfiles/
"  |___/
"
" $HOME/.config/nvim/plugins/vimwiki.vim
"

set nocompatible
filetype plugin on
let g:mkdp_auto_start = 1
let g:mkdp_auto_close = 1
let g:mkdp_browser = 'vimb'
let g:mkdp_preview_options = {
    \ 'mkit': {},
    \ 'katex': {},
    \ 'uml': {},
    \ 'maid': {},
    \ 'disable_sync_scroll': 0,
    \ 'sync_scroll_type': 'middle',
    \ 'hide_yaml_meta': 1,
    \ 'sequence_diagrams': {},
    \ 'flowchart_diagrams': {},
    \ 'content_editable': v:false,
    \ 'disable_filename': 1
    \ }
let g:mkdp_page_title = '「${name}」'
let g:mkdp_command_for_global = 1
let g:mkdp_markdown_css = '~/.config/nvim/colors/faintstyle.css'
let g:vimwiki_list = [{'path': '~/Documents/Wiki'}]
" Calendar config
au BufRead,BufNewFile *.wiki set filetype=vimwiki
:autocmd FileType vimwiki map d :VimwikiMakeDiaryNote
function! ToggleCalendar()
  execute ":Calendar"
  if exists("g:calendar_open")
    if g:calendar_open == 1
      execute "q"
      unlet g:calendar_open
    else
      g:calendar_open = 1
    end
  else
    let g:calendar_open = 1
  end
endfunction
:autocmd FileType vimwiki map c :call ToggleCalendar()

