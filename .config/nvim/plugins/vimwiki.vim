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
let g:mkdp_browser = 'librewolf'
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
let g:vimwiki_list = [{'path': '~/Documents/Wiki', 'diary_rel_path': 'Diary/', 'syntax': 'markdown', 'ext': '.md'}]
let g:mkdp_markdown_css = '$HOME/Documents/Wiki/darkgithub.css'
let g:vimwiki_global_ext = 0

" Calendar config
au BufRead,BufNewFile *.wiki set filetype=vimwiki
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
:autocmd FileType vimwiki map <Leader>c :call ToggleCalendar()

let g:vimwiki_key_mappings =
  \ {
  \   'all_maps': 1,
  \   'global': 1,
  \   'headers': 1,
  \   'text_objs': 1,
  \   'table_format': 1,
  \   'table_mappings': 1,
  \   'lists': 0,
  \   'links': 1,
  \   'html': 1,
  \   'mouse': 0,
  \ }

hi VimwikiHeader1 guifg=#a65f69
hi VimwikiHeader2 guifg=#3b8563
hi VimwikiHeader3 guifg=#b9637e
hi VimwikiHeader4 guifg=#b39669
hi VimwikiHeader5 guifg=#487799
hi VimwikiHeader6 guifg=#348396

" spell-check
au BufRead,BufNewFile *.md set filetype=markdown
:autocmd FileType markdown set spell spelllang=pt_br
:autocmd FileType markdown set norelativenumber
map <Leader>en :set spelllang=en_us<CR>
map <Leader>br :set spelllang=pt_br<CR>

