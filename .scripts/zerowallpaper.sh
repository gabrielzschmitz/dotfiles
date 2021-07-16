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

# Directory of the wallpapers
WALL_DIR='~/pic/wall/*.png'

# User interface
## X wallpaper options
WALL_OPT=$(echo -e "zoom\ncenter\ntile\nstretch\nmaximize\nno-randr"|\
dmenu -p 'xwallpaper options' -l 6) \
## Wallpaper setter function
WALL_FN=$(devour sxiv $WALL_DIR -to | tail -n 1)

# Set wallpaper
## For actual instance
xwallpaper --$WALL_OPT $WALL_FN
## For all instances
### Desktop
sed -i "s|xwallpaper.*|xwallpaper --$WALL_OPT $WALL_FN|\
" ~/.scripts/defaultwallpaper.sh
### Screen protector
sed -i "s|--image=.*|--image=$WALL_FN|\
" ~/.scripts/zerolock.sh
sed -i "s|--image=.*|--image=$WALL_FN\"|\
" ~/.scripts/zeroautolock.sh

# Update picom
sleep 1 && \
i3 restart && \
pkill picom &&\
picom --experimental-backends -b

