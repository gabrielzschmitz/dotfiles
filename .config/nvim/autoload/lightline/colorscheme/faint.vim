"   __ _  ____ ___ 
"  / _` ||_  // __| GITHUB:https://github.com/gabrielzschmitz               
" | (_| | / / \__ \ INSTAGRAM:https://www.instagram.com/gabrielz.schmitz/
"  \__, |/___||___/ DOTFILES:https://github.com/gabrielzschmitz/dotfiles/
"  |___/    
"
" A dark vim colorscheme based on OneHalfDark.
" See github.com/gabrielzschmitz/.dotfiles for more info

let s:mono0 = [ '#20232d', 236 ]
let s:mono1 = [ '#20232d', 238 ]
let s:mono2 = [ '#343b4b', 243 ]
let s:mono3 = [ '#9faab8', 255 ]

let s:yellow = [ '#b39669', 180 ]
let s:red = [ '#a65f69', 168 ]
let s:magenta = [ '#b9637e', 176 ]
let s:blue = [ '#487799', 75 ]
let s:cyan = [ '#348396', 73 ]
let s:green = [ '#3b8563', 114 ]

let s:p = {'normal': {}, 'inactive': {}, 'insert': {}, 'replace': {}, 'visual': {}, 'tabline': {}}

let s:p.normal.left = [ [ s:mono0, s:green ], [ s:mono3, s:mono2 ] ]
let s:p.normal.middle = [ [ s:green, s:mono1 ] ]
let s:p.normal.right = [ [ s:mono0, s:green ], [ s:mono3, s:mono2 ] ]

let s:p.normal.error = [ [ s:mono0, s:red ] ]
let s:p.normal.warning = [ [ s:mono0, s:yellow ] ]

let s:p.inactive.left =  [ [ s:mono3, s:mono2 ], [ s:mono3, s:mono2 ] ]
let s:p.inactive.middle = [ [ s:mono3, s:mono1 ] ]
let s:p.inactive.right = [ [ s:mono0, s:mono3 ], [ s:mono3, s:mono2 ] ]

let s:p.insert.left = [ [ s:mono0, s:blue ], [ s:mono3, s:mono2 ] ]
let s:p.insert.middle = [ [ s:blue, s:mono1 ] ]
let s:p.insert.right = [ [ s:mono0, s:blue ], [ s:mono3, s:mono2 ] ]

let s:p.replace.left = [ [ s:mono0, s:red ], [ s:mono3, s:mono2 ] ]
let s:p.replace.middle = [ [ s:red, s:mono1 ] ]
let s:p.replace.right = [ [ s:mono0, s:red ], [ s:mono3, s:mono2 ] ]

let s:p.visual.left = [ [ s:mono0, s:yellow ], [ s:mono3, s:mono2 ] ]
let s:p.visual.middle = [ [ s:yellow, s:mono1 ] ]
let s:p.visual.right = [ [ s:mono0, s:yellow ], [ s:mono3, s:mono2 ] ]

let s:p.tabline.left = [ [ s:mono2, s:mono1] ]
let s:p.tabline.tabsel = [ [ s:mono3, s:mono2 ] ]
let s:p.tabline.middle = [ [ s:mono2, s:mono1] ]
let s:p.tabline.right = [ [ s:mono0, s:green ] ]

let g:lightline#colorscheme#faint#palette = lightline#colorscheme#flatten(s:p)
