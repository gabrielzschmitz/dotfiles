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
if [[ "$(tty)" = "/dev/tty1" ]]; then
	startx "$XDG_CONFIG_HOME/X11/xinitrc"
fi

