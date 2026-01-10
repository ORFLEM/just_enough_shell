#!/bin/sh

get_active_window() {
    hyprctl activewindow -j | jq -r '.initialTitle // ""'
}

# Первичный вывод
get_active_window

# Подписка на события через socat
socat -U - UNIX-CONNECT:/tmp/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock | while read -r line; do
    event=$(echo "$line" | cut -d'>' -f1)
    
    case "$event" in
        activewindow|openwindow|closewindow|movewindow)
            get_active_window
            ;;
    esac
done

