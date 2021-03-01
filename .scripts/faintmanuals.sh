#   __ _  ____ ___
#  / _` ||_  // __| GITHUB:https://github.com/gabrielzschmitz
# | (_| | / / \__ \ INSTAGRAM:https://www.instagram.com/gabrielz.schmitz/
#  \__, |/___||___/ DOTFILES:https://github.com/gabrielzschmitz/dotfiles/
#  |___/
#
#!/bin/sh
# A script to read any man page in pdf by Luke Smith
man -k . | dmenu -nf '#6f798c' -nb '#232731' -sb '#3b8563' -sf '#9faab8' -fn 'FiraCode Nerd Font-12' -p 'man pages' -l 30 | awk '{print $1}' | xargs -r man -Tpdf | zathura -
-l 30 | awk '{print $1}' | xargs -r man -Tpdf | zathura -

