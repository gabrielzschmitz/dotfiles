#   __ _  ____ ___
#  / _` ||_  // __| GITHUB:https://github.com/gabrielzschmitz
# | (_| | / / \__ \ INSTAGRAM:https://www.instagram.com/gabrielz.schmitz/
#  \__, |/___||___/ DOTFILES:https://github.com/gabrielzschmitz/dotfiles/
#  |___/
#
#!bin/sh

scrot print-input.png		\
--quality 100			\
--exec 'mv $f ~/Pictures/$f'	\

convert ~/Pictures/print-input.png	\
-crop 1440x900+0+0			\
~/Pictures/print-output.png		\
&& rm ~/Pictures/print-input.png	\
&& mv ~/Pictures/print-output.png ~/Pictures/Fullscreenshot-$(date +%H:%M:%S).png	\

