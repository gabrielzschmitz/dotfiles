#         .             .              .		  
#         |             |              |           .	  
# ,-. ,-. |-. ,-. . ,-. |  ,_, ,-. ,-. |-. ,-,-. . |- ,_, 
# | | ,-| | | |   | |-' |   /  `-. |   | | | | | | |   /  
# `-| `-^ ^-' '   ' `-' `' '"' `-' `-' ' ' ' ' ' ' `' '"' 
#  ,|							  
#  `'							  
# GITHUB:https://github.com/gabrielzschmitz		  
# INSTAGRAM:https://www.instagram.com/gabrielz.schmitz/   
# DOTFILES:https://github.com/gabrielzschmitz/dotfiles/   
#!/bin/sh

# A script to read any man page in pdf by Luke Smith
man -k . | dmenu -nf '#6f798c' -nb '#232731' -sb '#3b8563' -sf '#9faab8' -fn 'FiraCode Nerd Font-12' -p 'man pages' -l 30 | awk '{print $1}' | xargs -r man -Tpdf | zathura -
-l 30 | awk '{print $1}' | xargs -r man -Tpdf | zathura -

