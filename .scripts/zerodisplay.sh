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
#
# Wallpaper setter program using sxiv and xwallpaper by
# gabrielzschmitz (https://github.com/gabrielzschmitz/dotfiles)
#!/bin/sh

DSP_OPT=$(echo -e "800x600display.sh\nseconddisplayright.sh\nnotedisplay.sh\nseconddisplayleft.sh\nseconddisplay.sh"|\
dmenu -p 'display scripts options' -l 5) \

## Set display resolution
# For actual instance
DSP_FN=$(sh ~/.scripts/displayscripts/$DSP_OPT)
sleep 1
killall -q polybar
sh ~/.config/polybar/launch.sh
sh ~/.scripts/defaultwallpaper.sh
# For all instances
sed -i "s|sh.*|sh ~/.scripts/displayscripts/$DSP_OPT|\
" ~/.scripts/defaultdisplay.sh

