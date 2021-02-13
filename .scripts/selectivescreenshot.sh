#   __ _  ____ ___
#  / _` ||_  // __| GITHUB:https://github.com/gabrielzschmitz
# | (_| | / / \__ \ INSTAGRAM:https://www.instagram.com/gabrielz.schmitz/
#  \__, |/___||___/ DOTFILES:https://github.com/gabrielzschmitz/dotfiles/
#  |___/
#
#!bin/sh

scrot Selectivescreenshot-%H:%M:%S.png           \
--quality 100                   \
--select			\
--freeze			\
--border			\
--exec 'mv $f ~/Pictures/$f'    \

