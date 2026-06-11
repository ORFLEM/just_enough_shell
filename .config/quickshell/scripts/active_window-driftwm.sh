#!/usr/bin/env bash

# Путь к файлу состояния DriftWM
RUNTIME_DIR="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"
STATE_FILE="${RUNTIME_DIR}/driftwm/state"

# Функция получения имени активного окна из JSON-поля windows
get_active_window() {
    local name=""
    if [[ -f "$STATE_FILE" ]]; then
        # Извлекаем значение windows=... (оно может быть многострочным, но скорее всего однострочное)
        # Используем grep, sed, jq для парсинга (jq предпочтительнее, но можно и без него)
        if command -v jq &> /dev/null; then
            # Красиво через jq
            name=$(grep -m1 '^windows=' "$STATE_FILE" | cut -d'=' -f2- | jq -r '.[] | select(.is_focused==true) | .app_id // .title // ""' 2>/dev/null)
        else
            # Fallback без jq — менее надёжно, но работает
            local windows_line=$(grep -m1 '^windows=' "$STATE_FILE")
            if [[ -n "$windows_line" ]]; then
                # Вырезаем JSON после знака =
                local json="${windows_line#*=}"
                # Ищем объект с "is_focused":true и извлекаем app_id или title
                # Простой grep-подход (хрупкий, но для типового случая подойдёт)
                local focused_obj=$(echo "$json" | sed 's/},{/}\n{/g' | grep '"is_focused":true')
                if [[ -n "$focused_obj" ]]; then
                    # Пытаемся достать app_id
                    name=$(echo "$focused_obj" | grep -o '"app_id":"[^"]*"' | cut -d'"' -f4)
                    if [[ -z "$name" ]]; then
                        name=$(echo "$focused_obj" | grep -o '"title":"[^"]*"' | cut -d'"' -f4)
                    fi
                fi
            fi
        fi
    fi
    name=$(echo "$name" | sed -E 's/^(org\.|app\.)//' | sed 's/\.desktop$//' | sed 's/.*\.//;s/_/ /g')
    # Если ничего не нашли, выводим пустую строку
    echo "${name:-}"
}

# Функция потокового вывода
stream_active_window() {
    if ! command -v inotifywait &> /dev/null; then
        echo "Warning: inotifywait not found. Install 'inotify-tools' for live updates." >&2
        get_active_window
        return 1
    fi

    local last_name=""
    while true; do
        current_name=$(get_active_window)
        if [[ "$current_name" != "$last_name" ]]; then
            echo "$current_name"
            last_name="$current_name"
        fi
        # Ждём изменения файла
        inotifywait -q -e close_write -e delete_self -e move_self "$STATE_FILE" >/dev/null 2>&1
        sleep 0.05
    done
}

# Основная логика
case "$1" in
    "stream-window")
        stream_active_window
        ;;
    "--help")
        echo "Usage: $0 {--help | stream-window}"
        echo "  stream-window   -> непрерывно выводит имя активного окна (app_id или title)"
        ;;
    *)
        echo "Usage: $0 stream-window"
        exit 1
        ;;
esac
