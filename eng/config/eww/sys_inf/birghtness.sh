#!/bin/sh

oldbrightness="0"
oldout=""
last_change_time=0

brightinf() {
    ddcutil --bus 12 getvcp 10 | grep -oP 'current value =\s+\K\d+'
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

    newbrightness="$(brightinf)"
    if [ "$oldbrightness" != "$newbrightness" ]; then
        oldbrightness="$newbrightness"
        eww update rbright="true"
        last_change_time=$current_time
    fi
    
    time_diff=$((current_time - last_change_time))
    if [ $last_change_time -gt 0 ] && [ $time_diff -ge 2 ]; then
        eww update rbright="false"
        last_change_time=0
    fi
    
    sleep 0.1
done
