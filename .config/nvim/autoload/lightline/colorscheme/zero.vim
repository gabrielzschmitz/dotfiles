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

let s:mono0 = [ '#242734', 236 ]
let s:mono1 = [ '#1c1e29', 238 ]
let s:mono2 = [ '#35394a', 243 ]
let s:mono3 = [ '#9096ae', 255 ]

let s:yellow = [ '#8c8089', 180 ]
let s:red = [ '#806382', 168 ]
let s:magenta = [ '#436668', 176 ]
let s:blue = [ '#4f6589', 75 ]
let s:cyan = [ '#446781', 73 ]
let s:green = [ '#6d5a80', 114 ]

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

let g:lightline#colorscheme#zero#palette = lightline#colorscheme#flatten(s:p)
