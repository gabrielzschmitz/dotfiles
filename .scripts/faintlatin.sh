#   __ _  ____ ___ 
#  / _` ||_  // __| GITHUB:https://github.com/gabrielzschmitz               
# | (_| | / / \__ \ INSTAGRAM:https://www.instagram.com/gabrielz.schmitz/
#  \__, |/___||___/ DOTFILES:https://github.com/gabrielzschmitz/dotfiles/
#  |___/    
#
#!/bin/sh

# A script to copy latin characters in a us keyboard by gabrielzschmitz.

# Get user selection via dmenu from latin file.
chosen=$(cut -d ';' -f1 ~/.scripts/latin | dmenu -nf '#6f798c' -nb '#232731' -sb '#3b8563' -sf '#9faab8' -fn 'FiraCode Nerd Font-12' -p 'latin' -i -l 15 | sed "s/ .*//")

# Exit if none chosen.
[ -z "$chosen" ] && exit

# If you run this command with an argument, it will automatically insert the
# character. Otherwise, show a message that the emoji has been copied.
if [ -n "$1" ]; then
	xdotool type "$chosen"
else
	echo "$chosen" | tr -d '\n' | xclip -selection clipboard
	notify-send -t 500 "'$chosen' copied to clipboard." &
fi

