#!/bin/sh
# A simple fix if the displays resolution have a bug in it

xrandr --output LVDS1 --off --output VGA1 --mode 1440x900 --primary --pos 0x0 --rotate normal;
xrandr --output LVDS1 --mode 1366x768 --pos 1440x132 --rotate normal --output VGA1 --primary --mode 1440x900 --pos 0x0 --rotate normal
