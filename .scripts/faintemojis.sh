#   __ _  ____ ___ 
#  / _` ||_  // __| GITHUB:https://github.com/gabrielzschmitz               
# | (_| | / / \__ \ INSTAGRAM:https://www.instagram.com/gabrielz.schmitz/
#  \__, |/___||___/ DOTFILES:https://github.com/gabrielzschmitz/dotfiles/
#  |___/    
#
#!/bin/sh

# The famous "get a menu of emojis to copy" script by Luke Smith (just added the theme).

# Get user selection via dmenu from emoji file.
chosen=$(cut -d ';' -f1 ~/.scripts/emojis | dmenu -p 'emojis' -l 15 | sed "s/ .*//")

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

