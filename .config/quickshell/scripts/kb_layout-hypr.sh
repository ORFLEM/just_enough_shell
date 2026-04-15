#!/bin/sh

last_layout=""

while true; do
    # Находим main клавиатуру и берём её раскладку
    current_layout=$(hyprctl devices | grep -B 5 "main: yes" | grep "active keymap:" | head -n 1 | awk -F': ' '{print $2}')
    
    # Форматируем раскладку
    case "$current_layout" in
        "English (US)"|"English"|"en_US"|"us")
            layout_name="EN";;
        "Russian"|"ru_RU"|"ru")
            layout_name="RU";;
        *)
            layout_name="$current_layout";;
    esac
    
    # Выводим только если раскладка изменилась
    if [ -n "$layout_name" ] && [ "$layout_name" != "$last_layout" ]; then
        echo "$layout_name"
        last_layout="$layout_name"
    fi
    
    sleep 0.05
done
