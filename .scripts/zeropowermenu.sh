#         .             .              .                  
#         |             |              |           .      
# ,-. ,-. |-. ,-. . ,-. |  ,_, ,-. ,-. |-. ,-,-. . |- ,_, 
# | | ,-| | | |   | |-' |   /  `-. |   | | | | | | |   /  
# `-| `-^ ^-' '   ' `-' `' '"' `-' `-' ' ' ' ' ' ' `' '"' 
#  ,|                                                     
#  `'                                                     
#GITHUB:https://github.com/gabrielzschmitz                
#INSTAGRAM:https://www.instagram.com/gabrielz.schmitz/    
#DOTFILES:https://github.com/gabrielzschmitz/dotfiles/    
#!/bin/sh

#Directory
dir="~/.config/polybar/scripts/rofi"

#Start rofi
rofi_command="rofi -theme $dir/powermenu.rasi"

#Options
lock=" Lock"
suspend="⏾ Sleep"
logout=" Logout"
reboot=" Restart"
shutdown="⏻ Shutdown"
uptime=$(uptime -p | sed -e 's/up //g')

# Variables
options="$lock\n$suspend\n$logout\n$reboot\n$shutdown"

# Choices
chosen="$(echo -e "$options" | $rofi_command -p "Uptime: $uptime" -dmenu -selected-row 0)"
case $chosen in
    $lock)
		sh ~/.scripts/faintlock.sh 
        ;;
    $suspend)
		i3exit suspend
        ;;
    $logout)
		i3exit logout
        ;;
    $reboot)
		i3exit reboot
	;;
    $shutdown)
		i3exit shutdown
        ;;
esac

