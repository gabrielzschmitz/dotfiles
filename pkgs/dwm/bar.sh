#!/bin/sh

# dwm status bar for NixOS
# ^c$var^ = foreground color
# ^b$var^ = background color

set -u

# One Dark colors
black='#1e222a'
green='#7eca9c'
white='#abb2bf'
grey='#282c34'
blue='#7aa2f7'
red='#d47d85'
darkblue='#668ee3'

cpu() {
  local load
  load=$(awk '{ print $1 }' /proc/loadavg)

  printf '^c%s^^b%s^ CPU ' "$black" "$green"
  printf '^c%s^^b%s^ %s^b%s^' "$white" "$grey" "$load" "$black"
}

battery() {
  local battery_dir capacity status

  for battery_dir in /sys/class/power_supply/BAT*; do
    [[ -d "$battery_dir" ]] || continue

    capacity=$(cat "$battery_dir/capacity" 2>/dev/null) || continue
    status=$(cat "$battery_dir/status" 2>/dev/null || true)

    printf '^c%s^^b%s^ BAT' "$black" "$red"
    printf '^c%s^^b%s^ %s%%' "$white" "$grey" "$capacity"

    [[ "$status" == "Charging" ]] && printf '^c%s^+' "$green"
    printf '^b%s^' "$black"
    return
  done
}

brightness() {
  local device current maximum percentage

  for device in /sys/class/backlight/*; do
    [[ -d "$device" ]] || continue

    current=$(cat "$device/brightness" 2>/dev/null) || continue
    maximum=$(cat "$device/max_brightness" 2>/dev/null) || continue
    (( maximum > 0 )) || continue

    percentage=$((current * 100 / maximum))
    printf '^c%s^  %s%%' "$red" "$percentage"
    return
  done
}

volume() {
  local output volume icon

  output=$(wpctl get-volume @DEFAULT_AUDIO_SINK@ 2>/dev/null) || return

  if [[ "$output" == *"[MUTED]"* ]]; then
    icon=""
    volume=0
  else
    [[ "$output" =~ Volume:\ ([0-9.]+) ]] || return
    volume=$(awk -v v="${BASH_REMATCH[1]}" 'BEGIN { printf "%.0f", v * 100 }')

    if (( volume <= 33 )); then
      icon=""
    elif (( volume <= 66 )); then
      icon=""
    else
      icon=""
    fi
  fi

  printf '^c%s^^b%s^ %s  ' "$black" "$green" "$icon"
  printf '^c%s^^b%s^ %s%%^b%s^' "$green" "$black" "$volume" "$black"
}

mem() {
  local used

  used=$(awk '
  /^MemTotal:/ { total = $2 }
  /^MemAvailable:/ { available = $2 }
END {
  if (total > 0)
    printf "%.1fG", (total - available) / 1048576
}
' /proc/meminfo)

printf '^c%s^^b%s^   ' "$red" "$black"
printf '^c%s^%s' "$red" "${used:-N/A}"
}

wlan() {
  local device state

  for device in /sys/class/net/*; do
    [[ -d "$device/wireless" ]] || continue

    state=$(cat "$device/operstate" 2>/dev/null || true)

    case "$state" in
      up)
        printf '^c%s^^b%s^ 󰤨 ^d^%s' \
          "$black" "$blue" ' ^c#7aa2f7^Connected'
        return
        ;;
      down | dormant)
        printf '^c%s^^b%s^ 󰤭 ^d^%s' \
          "$black" "$blue" ' ^c#7aa2f7^Disconnected'
        return
        ;;
    esac
  done
}

ethernet() {
  local device state

  for device in /sys/class/net/enp*; do
    [[ -d "$device" ]] || continue

    state=$(cat "$device/operstate" 2>/dev/null || true)

    case "$state" in
      up)
        printf '^c%s^^b%s^ 󰈁 ^d^%s' \
          "$black" "$blue" ' ^c#7aa2f7^Connected'
        return
        ;;
      down | dormant | lowerlayerdown | unknown)
        printf '^c%s^^b%s^ 󰈂 ^d^%s' \
          "$black" "$blue" ' ^c#7aa2f7^Disconnected'
        return
        ;;
    esac
  done
}

clock() {
  printf '^c%s^^b%s^ 󱑆 ' "$black" "$darkblue"
  printf '^c%s^^b%s^ %s' "$black" "$blue" "$(date '+%H:%M')"
}

while true; do
  status=""

  for module in cpu battery brightness volume mem ethernet wlan clock; do
    output=$("$module")

    if [[ -n "$output" ]]; then
      [[ -n "$status" ]] && status+=" "
      status+="$output"
    fi
  done

  xsetroot -name " $status"
  sleep 1
done
