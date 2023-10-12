#!/bin/sh

MIC="$(pulseaudio-ctl | grep "Is source muted" | wc -c)"
MODULE=$HOME/.config/polybar/modules/mic.ini
STATUS="$(grep fg ~/.config/polybar/modules/mic.ini)"

case $MIC in
    47)
        printf ""
        case $STATUS in
            '')
            ;;
            *)
                sed -i 's/colors.fg/colors.red/g' $MODULE
                xdotool key --clearmodifiers super+shift+b
            ;;
        esac
    ;;
    *)
        printf ""
        case $STATUS in
            '')
                sed -i 's/colors.red/colors.fg/g' $MODULE
                xdotool key --clearmodifiers super+shift+b
            ;;
            *)
            ;;
        esac
    ;;
esac

