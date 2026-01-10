#!/bin/sh


format_layout() {
    case "$1" in
        "English (US)"|"English"|"en_US"|"us")
            echo "EN";;
        "Russian"|"ru_RU"|"ru")
            echo "RU";;
        *)
            echo "$1";;
    esac
}

get_current_layout() {
    hyprctl devices -j | jq -r '.keyboards[] | select(.main == true) | .active_keymap' | head -n1
}

# Первичный вывод
format_layout "$(get_current_layout)"

# Подписка на события
socat -U - UNIX-CONNECT:/tmp/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock | while read -r line; do
    event=$(echo "$line" | cut -d'>' -f1)
    
    if [ "$event" = "activelayout" ]; then
        layout=$(echo "$line" | cut -d'>' -f2 | cut -d',' -f2)
        format_layout "$layout"
    fi
done
