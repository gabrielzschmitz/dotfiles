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
# System management menu
#!/bin/sh


# Options
lock=" Lock             "
suspend="⏾ Sleep         "
logout=" Logout         "
reboot=" Restart        "
shutdown="⏻ Shutdown     "
uptime=$(uptime -p | sed -e 's/up //g')

# Variables
options="$lock\n$suspend\n$logout\n$reboot\n$shutdown\n Up: $uptime"

# Choices
chosen="$(echo -e "$options" | dmenu)"
case $chosen in
    $lock)
		sh ~/.scripts/zerolock.sh
        ;;
    $suspend)
		loginctl suspend
        ;;
    $logout)
		loginctl terminate-session $XDG_SESSION_ID
	;;
    $reboot)
		loginctl reboot
	;;
    $shutdown)
		loginctl poweroff
        ;;
    $uptime)
	    	notify-send "Choose another"
        ;;
esac

