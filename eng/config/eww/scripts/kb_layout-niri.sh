#!/bin/sh

last_layout=""

while true; do
    # Получаем информацию о раскладках
    layouts_json=$(niri msg -j keyboard-layouts 2>/dev/null)
    
    # Извлекаем текущую раскладку по индексу
    current_layout=$(echo "$layouts_json" | jq -r '.names[.current_idx] // ""')
    
    # Форматируем раскладку
    case "$current_layout" in
        "English (US)"|"English"|"en_US"|"us"|*"English"*)
            layout_name="EN";;
        "Russian"|"ru_RU"|"ru"|*"Russian"*)
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
