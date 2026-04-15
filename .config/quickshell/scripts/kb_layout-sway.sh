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

# Первичный вывод при старте
current_layout=$(swaymsg -t get_inputs | jq -r '.[] | select(.type == "keyboard") | .xkb_active_layout_name' | head -n 1)
format_layout "$current_layout"

# Подписка на события изменения раскладки
swaymsg -t subscribe -m '["input"]' | while read -r event; do
    change=$(echo "$event" | jq -r '.change // ""')
    
    if [ "$change" = "xkb_layout" ] || [ "$change" = "xkb_keymap" ]; then
        layout=$(echo "$event" | jq -r '.input.xkb_active_layout_name // ""')
        [ -n "$layout" ] && format_layout "$layout"
    fi
done
