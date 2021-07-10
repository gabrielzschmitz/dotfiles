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

# Auto lock script of zero for
# i3lock-color(https://github.com/Raymo111/i3lock-color) by
# gabrielzschmitz(https://github.com/gabrielzschmitz)

B='#262938' # Background
T='#9096ae' # Text
V='#4f6589' # Verifying ring
W='#806382' # Wrong ring
D='#436668' # Default color
K='#4f797b' # Keystroke
BLANK='#00000000' # Blank

xautolock		\
-time 15		\
-locker "i3lock         \
--indicator		\
--ringver-color=$V	\
--insidever-color=$B	\
--verif-color=$T	\
\
--ringwrong-color=$W	\
--insidewrong-color=$B	\
--wrong-color=$T	\
\
--ring-color=$D		\
--inside-color=$B	\
--line-color=$BLANK	\
\
--separator-color=$D	\
--layout-color=$T	\
--keyhl-color=$K	\
--bshl-color=$K		\
\
--clock			\
--time-str='%H:%M:%S'	\
--time-color=$T		\
--time-size=35		\
--date-str='%a, %b, %Y'	\
--date-color=$T		\
--date-size=18		\
\
--noinput-text='No Input'	\
--layout-size=30		\
--verif-text='Verifying'	\
--verif-size=30			\
--wrong-text='Wrong!'		\
--wrong-size=30			\
\
--ignore-empty-password				\
--nofork					\
--centered					\
--image=/home/gabrielzschmitz/pic/wall/nsx.png"

