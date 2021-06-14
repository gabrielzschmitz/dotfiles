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
#!bin/sh

scrot print-input.png		\
--quality 100			\
--exec 'mv $f ~/Pictures/$f'	\

convert ~/Pictures/print-input.png	\
-quality 100				\
-flop 					\
-crop 1440x900+0+0			\
-flop					\
~/Pictures/print-output.png		\
&& rm ~/Pictures/print-input.png	\
&& mv ~/Pictures/print-output.png ~/Pictures/Fullscreenshot-$(date +%H:%M:%S).png	\

