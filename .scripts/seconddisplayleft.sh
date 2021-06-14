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
# A simple display set (second on left)

xrandr 		\
--output LVDS1	\
--mode 1366x768	\
--pos 0x132	\
--rotate normal	\
--output VGA1	\
--primary	\
--mode 1440x900	\
--pos 1366x0	\
--rotate normal	\

