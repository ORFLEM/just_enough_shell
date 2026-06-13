#!/bin/sh

oldbrightness="0"
oldout=""
last_change_time=0

brightinf() {
    ddcutil --bus 11 getvcp 10 | grep -oP 'current value =\s+\K\d+'
}

get_current_time() {
    date +%s
}

while true; do
    brightness="$(brightinf)"
    current_time=$(get_current_time)
    
    # Определяем иконку в зависимости от яркости
    if [ "$brightness" -le 25 ]; then
        sign="󰃞"
    elif [ "$brightness" -le 50 ]; then
        sign="󰃟"
    elif [ "$brightness" -le 75 ]; then
        sign="󰃝"
    else
        sign="󰃠"
    fi

    brightout="$brightness"

    if [ -n "$brightout" ] && [ "$brightout" != "$oldout" ]; then
        printf '{"sign":"%s","bright":"%s"}\n' "$sign" "$brightout"
        oldout="$brightout"
    fi
   
    sleep 0.1
done
