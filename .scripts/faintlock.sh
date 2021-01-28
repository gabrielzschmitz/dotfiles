#   __ _  ____ ___
#  / _` ||_  // __| GITHUB:https://github.com/gabrielzschmitz
# | (_| | / / \__ \ INSTAGRAM:https://www.instagram.com/gabrielz.schmitz/
#  \__, |/___||___/ DOTFILES:https://github.com/gabrielzschmitz/dotfiles/
#  |___/
#
#!bin/bash/sh

# Faint Theme for i3lock-color(https://github.com/Raymo111/i3lock-color) by gabrielzschmitz(https://github.com/gabrielzschmitz)

B='#232731' # Background
T='#9faab8' # Text
V='#487799' # Verifying ring
W='#a65f69' # Wrong ring
D='#3b8563' # Default color
K='#5fb98f' # Keystroke
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
--ignore-empty-password					\
--tiling						\
--nofork						\
--image=$HOME/Pictures/Wallpapers/wallpaper-blur.png	\
