" Name: candle
" Author: Aditya Azad<adityaazad121@gmail.com>
" Maintainer: Aditya Azad<adityaazad121@gmail.com>
" Notes: A dark monochrome colorscheme with a hint of color

" Colors used
" #262626
" #0D0D0D
" #404040
" #474747
" #8C8C8C
" #F2F2F2
" #807476

" set background=dark
" highlight clear
" if exists("syntax_on")
"     syntax reset
" endif
let g:colors_name="candle"

" --------------------------------
" Editor settings
" --------------------------------
hi Normal          guifg=#F2F2F2    guibg=NONE    gui=NONE
hi Cursor          guifg=#F2F2F2    guibg=NONE    gui=NONE
hi CursorLine      guifg=NONE       guibg=#262626 gui=NONE
hi LineNr          guifg=#404040    guibg=NONE    gui=NONE
hi CursorLineNR    guifg=#F2F2F2    guibg=NONE    gui=NONE
                                                            
" -----------------                                         
" - Number column -                                         
" -----------------                                         
hi CursorColumn    guifg=NONE       guibg=NONE    gui=NONE
hi FoldColumn      guifg=#404040    guibg=NONE    gui=NONE
hi SignColumn      guifg=#404040    guibg=NONE    gui=NONE
hi Folded          guifg=#404040    guibg=NONE    gui=NONE
                                                            
" -------------------------                                 
" - Window/Tab delimiters -                                 
" -------------------------                                 
hi VertSplit       guifg=NONE       guibg=NONE    gui=NONE
hi ColorColumn     guifg=NONE       guibg=NONE    gui=NONE
hi TabLine         guifg=NONE       guibg=NONE    gui=NONE
hi TabLineFill     guifg=NONE       guibg=NONE    gui=NONE
hi TabLineSel      guifg=NONE       guibg=NONE    gui=NONE
                                                            
" -------------------------------                           
" - File Navigation / Searching -                           
" -------------------------------                           
hi Directory       guifg=#F2F2F2    guibg=NONE    gui=NONE
hi Search          guifg=#0D0D0D    guibg=#807476 gui=NONE
hi IncSearch       guifg=#0D0D0D    guibg=#807476 gui=NONE
hi Substitute      guifg=#0D0D0D    guibg=#807476 gui=NONE
                                                            
" -----------------                                         
" - Prompt/Status -                                         
" -----------------                                         
hi StatusLine      guifg=#807476    guibg=NONE    gui=NONE
hi StatusLineNC    guifg=#0D0D0D    guibg=NONE    gui=NONE
hi WildMenu        guifg=#807476    guibg=NONE    gui=NONE
hi Question        guifg=#404040    guibg=NONE    gui=NONE
hi Title           guifg=#F2F2F2    guibg=NONE    gui=NONE
hi ModeMsg         guifg=#404040    guibg=NONE    gui=NONE
hi MoreMsg         guifg=#807476    guibg=NONE    gui=NONE

" --------------
" - Visual aid -
" --------------
hi MatchParen      guifg=#807476    guibg=#404040 gui=NONE
hi Visual          guifg=#F2F2F2    guibg=#404040 gui=NONE
hi VisualNOS       guifg=#F2F2F2    guibg=#404040 gui=NONE
hi NonText         guifg=NONE       guibg=NONE    gui=NONE

hi Todo            guifg=#F2F2F2    guibg=NONE    gui=NONE
hi Underlined      guifg=#F2F2F2    guibg=NONE    gui=NONE
hi Error           guifg=#404040    guibg=NONE    gui=NONE
hi ErrorMsg        guifg=#404040    guibg=NONE    gui=NONE
hi WarningMsg      guifg=#404040    guibg=NONE    gui=NONE
hi Ignore          guifg=#404040    guibg=NONE    gui=NONE
hi SpecialKey      guifg=#404040    guibg=NONE    gui=NONE
hi WhiteSpaceChar  guifg=#404040    guibg=NONE    gui=NONE
hi WhiteSpace      guifg=#404040    guibg=NONE    gui=NONE

" --------------------------------
" Variable types
" --------------------------------
hi Constant        guifg=#8C8C8C    guibg=NONE    gui=NONE
hi String          guifg=#8C8C8C    guibg=NONE    gui=NONE
hi StringDelimiter guifg=#8C8C8C    guibg=NONE    gui=NONE
hi Character       guifg=#8C8C8C    guibg=NONE    gui=NONE
hi Number          guifg=#8C8C8C    guibg=NONE    gui=NONE
hi Boolean         guifg=#8C8C8C    guibg=NONE    gui=NONE
hi Float           guifg=#8C8C8C    guibg=NONE    gui=NONE
                                                            
hi Identifier      guifg=#F2F2F2    guibg=NONE    gui=NONE
hi Function        guifg=#F2F2F2    guibg=NONE    gui=NONE

" --------------------------------
" Language constructs
" --------------------------------
hi Statement       guifg=#F2F2F2    guibg=NONE    gui=NONE
hi Conditional     guifg=#F2F2F2    guibg=NONE    gui=NONE
hi Repeat          guifg=#F2F2F2    guibg=NONE    gui=NONE
hi Label           guifg=#F2F2F2    guibg=NONE    gui=NONE
hi Operator        guifg=#F2F2F2    guibg=NONE    gui=NONE
hi Keyword         guifg=#F2F2F2    guibg=NONE    gui=NONE
hi Exception       guifg=#F2F2F2    guibg=NONE    gui=NONE
hi Comment         guifg=#474747    guibg=NONE    gui=NONE

hi Special         guifg=#F2F2F2    guibg=NONE    gui=NONE
hi SpecialChar     guifg=#F2F2F2    guibg=NONE    gui=NONE
hi Tag             guifg=#F2F2F2    guibg=NONE    gui=NONE
hi Delimiter       guifg=#F2F2F2    guibg=NONE    gui=NONE
hi SpecialComment  guifg=#404040    guibg=NONE    gui=NONE
hi Debug           guifg=#F2F2F2    guibg=NONE    gui=NONE

" ----------
" - C like -
" ----------
hi PreProc         guifg=#F2F2F2    guibg=NONE    gui=NONE
hi Include         guifg=#F2F2F2    guibg=NONE    gui=NONE
hi Define          guifg=#F2F2F2    guibg=NONE    gui=NONE
hi Macro           guifg=#F2F2F2    guibg=NONE    gui=NONE
hi PreCondit       guifg=#F2F2F2    guibg=NONE    gui=NONE
                                                            
hi Type            guifg=#F2F2F2    guibg=NONE    gui=NONE
hi StorageClass    guifg=#F2F2F2    guibg=NONE    gui=NONE
hi Structure       guifg=#F2F2F2    guibg=NONE    gui=NONE
hi Typedef         guifg=#F2F2F2    guibg=NONE    gui=NONE

" --------------------------------
" Diff
" --------------------------------
hi DiffAdd         guifg=#F2F2F2    guibg=NONE    gui=NONE
hi DiffChange      guifg=#F2F2F2    guibg=NONE    gui=NONE
hi DiffDelete      guifg=#F2F2F2    guibg=NONE    gui=NONE
hi DiffText        guifg=#F2F2F2    guibg=NONE    gui=NONE
hi diffAdded       guifg=#F2F2F2    guibg=NONE    gui=NONE
hi diffChanged     guifg=#F2F2F2    guibg=NONE    gui=NONE
hi diffRemoved     guifg=#F2F2F2    guibg=NONE    gui=NONE
hi diffLine        guifg=#F2F2F2    guibg=NONE    gui=NONE

" --------------------------------
" Completion menu
" --------------------------------
hi Pmenu           guifg=#8C8C8C    guibg=NONE    gui=NONE
hi PmenuSel        guifg=#8C8C8C    guibg=NONE    gui=NONE
hi PmenuSbar       guifg=#8C8C8C    guibg=NONE    gui=NONE
hi PmenuThumb      guifg=#8C8C8C    guibg=NONE    gui=NONE

" --------------------------------
" Spelling
" --------------------------------
hi SpellBad        guifg=#807476    guibg=NONE    gui=NONE
hi SpellCap        guifg=#F2F2F2    guibg=NONE    gui=NONE
hi SpellLocal      guifg=#F2F2F2    guibg=NONE    gui=NONE
hi SpellRare       guifg=#F2F2F2    guibg=NONE    gui=NONE

" --------------------------------
" LSP
" --------------------------------
hi LspDiagnosticsDefaultWarning         guifg=#404040    guibg=NONE    gui=NONE
hi LspDiagnosticsDefaultError           guifg=#807476    guibg=NONE    gui=NONE
hi LspDiagnosticsDefaultInformation     guifg=#404040    guibg=NONE    gui=NONE
hi LspDiagnosticsDefaultHint            guifg=#404040    guibg=NONE    gui=NONE

