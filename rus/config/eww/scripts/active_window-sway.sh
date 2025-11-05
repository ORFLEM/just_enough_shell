#!/bin/sh

# Первичный вывод при старте
aw=$(swaymsg -t get_tree | jq -r '.. | select(.focused? == true) | .name // ""')
echo "${aw:-}"

# Подписка на события изменения фокуса окна
swaymsg -t subscribe -m '["window"]' | while read -r event; do
    # Парсим только события изменения фокуса
    change=$(echo "$event" | jq -r '.change // ""')
    
    if [ "$change" = "focus" ]; then
        aw=$(echo "$event" | jq -r '.container.name // ""')
        echo "${aw:-}"
    fi
done
