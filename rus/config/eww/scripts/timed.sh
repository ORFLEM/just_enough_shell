#!/bin/sh

# Файл для хранения состояния (можно использовать /tmp)
STATE_FILE="/tmp/time_date_toggle"

# Инициализация состояния если файл не существует
if [ ! -f "$STATE_FILE" ]; then
    echo "time" > "$STATE_FILE"
fi

case "$1" in
"t-d")
    # Читаем текущее состояние
    current_state=$(cat "$STATE_FILE")
    
    # Переключаем состояние
    if [ "$current_state" = "time" ]; then
        echo "date" > "$STATE_FILE"
    else
        echo "time" > "$STATE_FILE"
    fi
    ;;
"show")
    while true; do
        # Читаем состояние каждый раз в цикле
        state=$(cat "$STATE_FILE")
        
        if [ "$state" = "time" ]; then
            date '+%H:%M:%S'
        else
            date '+%d-%m-%Y'
        fi
        
        sleep 0.05
    done
    ;;
esac
