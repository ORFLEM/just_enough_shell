#!/usr/bin/env bash

# Кеш-файл для шин мониторов
CACHE_FILE="$HOME/.cache/qs_monitors"

# --- Функция получения яркости для конкретной шины ---
get_brightness() {
    local bus="$1"
    # Используем -t для terse-вывода, чтобы проще парсить
    ddcutil -t getvcp 10 --bus "$bus" 2>/dev/null | awk '{print $4}'
}

# --- Определение шин мониторов (с кешированием) ---
if [[ -f "$CACHE_FILE" && -s "$CACHE_FILE" ]]; then
    # Читаем шины из кеша
    mapfile -t MONITOR_BUSES < "$CACHE_FILE"
else
    # Определяем шины через ddcutil detect
    MONITOR_BUSES=()
    while IFS= read -r line; do
        # Ищем строки вида "I2C bus: /dev/i2c-7"
        if [[ "$line" =~ I2C\ bus:\ +/dev/i2c-([0-9]+) ]]; then
            MONITOR_BUSES+=("${BASH_REMATCH[1]}")
        fi
    done < <(ddcutil detect 2>/dev/null)

    # Если шин не найдено — выходим
    if [[ ${#MONITOR_BUSES[@]} -eq 0 ]]; then
        echo "❌ Мониторы с DDC/CI не найдены" >&2
        exit 1
    fi

    # Сохраняем в кеш
    printf "%s\n" "${MONITOR_BUSES[@]}" > "$CACHE_FILE"
fi

# --- Основной цикл ---

stream () {
old_brightness=""

while true; do
    sum=0
    count=0

    # Опрашиваем все найденные шины
    for bus in "${MONITOR_BUSES[@]}"; do
        val=$(get_brightness "$bus")
        if [[ -n "$val" && "$val" =~ ^[0-9]+$ ]]; then
            sum=$((sum + val))
            count=$((count + 1))
        fi
    done

    # Пропускаем итерацию, если ни один монитор не ответил
    if [[ $count -eq 0 ]]; then
        sleep 0.1
        continue
    fi

    # Среднее арифметическое с округлением вверх
    avg=$(( (sum + count - 1) / count ))

    # Иконка в зависимости от яркости
    if [[ $avg -le 25 ]]; then
        sign="󰃞"
    elif [[ $avg -le 50 ]]; then
        sign="󰃟"
    elif [[ $avg -le 75 ]]; then
        sign="󰃝"
    else
        sign="󰃠"
    fi

    # Вывод только при изменении
    if [[ "$avg" != "$old_brightness" ]]; then
        printf '{"sign":"%s","bright":"%s"}\n' "$sign" "$avg"
        old_brightness="$avg"
    fi

    sleep 0.3
done
}

# --- Смена яркости ---
change_up () {
    for bus in "${MONITOR_BUSES[@]}"; do
        ddcutil --bus "$bus" setvcp 10 + 5
    done
}
change_down () {
    for bus in "${MONITOR_BUSES[@]}"; do
        ddcutil --bus "$bus" setvcp 10 - 5
    done
}

case "$1" in
    "stream")
        stream
        ;;
    "change-up")
        change_up
        ;;
    "change-down")
        change_down
        ;;
    *)
        echo "Usage: $0 {stream | change-up | change-down}"
        exit 1
        ;;
esac
