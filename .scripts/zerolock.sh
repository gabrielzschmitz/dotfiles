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

# Zero for i3lock-color(https://github.com/Raymo111/i3lock-color)
# by gabrielzschmitz(https://github.com/gabrielzschmitz)

B='#262938' # Background
T='#9096ae' # Text
V='#4f6589' # Verifying ring
W='#806382' # Wrong ring
D='#436668' # Default color
K='#4f797b' # Keystroke
BLANK='#00000000' # Blank

i3lock			\
--ringvercolor=$V	\
--insidevercolor=$B	\
--verifcolor=$T		\
\
--ringwrongcolor=$W	\
--insidewrongcolor=$B	\
--wrongcolor=$T		\
\
--ringcolor=$D		\
--insidecolor=$B	\
--linecolor=$BLANK	\
\
--separatorcolor=$D	\
--layoutcolor=$T	\
--keyhlcolor=$K		\
--bshlcolor=$K		\
\
--clock			\
--timestr='%H:%M:%S'	\
--timecolor=$T		\
--timesize=35		\
--datestr='%a, %b, %Y'	\
--datecolor=$T		\
--datesize=18		\
\
--noinputtext='No Input'	\
--layoutsize=30			\
--veriftext='Verifying'		\
--verifsize=30			\
--wrongtext='Wrong!'		\
--wrongsize=30			\
\
--ignore-empty-password				\
--nofork					\
--centered					\
--image=$HOME/Pictures/Wallpapers/smoking.png	\

