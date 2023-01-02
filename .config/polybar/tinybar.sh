# script to Tiny-launch polybar

#!/usr/bin/env bash

CONFIG_DIR=$HOME/.config/polybar/config.ini

pid=$(cat /tmp/tray.pid)
if [ $pid = "0" ]; then
    polybar tray -c $CONFIG_DIR &
    echo "1" > /tmp/tray.pid
else
    /home/gabrielzschmitz/.config/polybar/killbar.sh
    echo "0" > /tmp/tray.pid
fi

