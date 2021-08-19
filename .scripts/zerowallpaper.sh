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
#WALL_DIR='$HOME/pic/wall/zero-oceanblue/'
WALL_DIR=$(echo -e "~/pic/wall/zero-redlavender\n~/pic/wall/zero-oceanblue\n~/pic/wall/zero-yellowambar"|\
dmenu -l 3) \

# User interface
## X wallpaper options
WALL_OPT=$(echo -e "zoom\ncenter\ntile\nstretch\nmaximize\nno-randr"|\
dmenu -l 6) \
## Wallpaper setter function
WALL_FN=$(devour sxiv $WALL_DIR -to | tail -n 1)

# Set wallpaper
## For actual instance
xwallpaper --$WALL_OPT $WALL_FN
## For all instances
### Desktop
sed -i "s|xwallpaper.*|xwallpaper --$WALL_OPT $WALL_FN|\
" ~/.scripts/defaultwallpaper.sh

# Update picom
sleep 1 && \
pkill picom ;\
sh $HOME/.scripts/displayfix.sh ;\
picom --experimental-backends -b

