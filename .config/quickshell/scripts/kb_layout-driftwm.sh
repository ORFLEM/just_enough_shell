#!/usr/bin/env bash

# Путь к файлу состояния DriftWM
RUNTIME_DIR="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"
STATE_FILE="${RUNTIME_DIR}/driftwm/state"

# Функция для чтения значения layout из state-файла
get_layout() {
    local layout="us"  # значение по умолчанию
    if [[ -f "$STATE_FILE" ]]; then
        local line=$(grep -m1 '^layout=' "$STATE_FILE")
        if [[ -n "$line" ]]; then
            layout="${line#*=}"
            layout="${layout//[$'\t\r\n ']}"  # убираем пробелы и переводы строк
        fi
    fi
    # Приводим к короткому формату, если нужно (us/ru)
    case "$layout" in
        "us"|"en"|"english"|"usa"|"English(US)") echo "EN" ;;
        "ru"|"russian"|"Russian") echo "RU" ;;
        *) echo "$layout" ;;
    esac
}

# Функция для потокового вывода (аналог sway-подписки)
stream_layout() {
    if ! command -v inotifywait &> /dev/null; then
        echo "Warning: inotifywait not found. Install 'inotify-tools' for live updates." >&2
        get_layout
        return 1
    fi

    local last_layout=""
    while true; do
        current_layout=$(get_layout)
        if [[ "$current_layout" != "$last_layout" ]]; then
            echo "$current_layout"
            last_layout="$current_layout"
        fi
        # Ждём изменения файла (close_write, delete_self, move_self)
        inotifywait -q -e close_write -e delete_self -e move_self "$STATE_FILE" >/dev/null 2>&1
        sleep 0.05  # небольшая пауза, чтобы не спамить при быстрых событиях
    done
}

# Основная логика
case "$1" in
    "stream-layout")
        stream_layout
        ;;
    "--help")
        echo "Usage: $0 {--help | stream-layout}"
        echo "  stream-layout   -> непрерывно выводит текущую раскладку (us/ru/...)"
        ;;
    *)
        echo "Usage: $0 stream-layout"
        exit 1
        ;;
esac
