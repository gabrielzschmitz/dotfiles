#!/bin/bash
CONFIG_DIR=$HOME/.config/polybar/config.ini

# Terminate already running bar instances
killall -q polybar

# Launch Polybar, using default config location ~/.config/polybar/config
if type "xrandr"; then
    for m in $(xrandr --query | grep " connected" | cut -d" " -f1); do
        MONITOR=$m polybar bar-dwm -c $CONFIG_DIR &
    done
else
    polybar bar-dwm -c $CONFIG_DIR &
fi

