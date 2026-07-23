#! /usr/bin/env bash

# Путь к файлу состояния DriftWM
RUNTIME_DIR="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"
STATE_FILE="${RUNTIME_DIR}/driftwm/state"

# Функция для безопасного чтения значения из state-файла
get_state_value() {
    local key="$1"
    local value="0"
    if [[ -f "$STATE_FILE" ]]; then
        # Убираем лишние пробелы в grep и обработке
        local line=$(grep -m1 "^${key}=" "$STATE_FILE")
        if [[ -n "$line" ]]; then
            value="${line#*=}"
            value="${value//[$'\t\r\n ']}"  # Обрезаем пробелы и переводы строк
        fi
    fi
    echo "$value"
}

# Функция для генерации JSON
generate_json() {
    local x=$(get_state_value "x")
    local y=$(get_state_value "y")
    local zoom=$(get_state_value "zoom")
    printf '{"x":"%s","y":"%s","zoom":"%s"}\n' "$x" "$y" "$zoom"
}

# Функция для непрерывного отслеживания файла состояния
stream_json() {
    # Проверяем, установлен ли inotifywait
    if ! command -v inotifywait &> /dev/null; then
        echo "Warning: inotifywait not found. Install 'inotify-tools' for live updates." >&2
        generate_json
        return 1
    fi

    # Сначала убедимся, что файл существует
    touch "$STATE_FILE" 2>/dev/null || {
        echo "Error: Cannot create or write to $STATE_FILE" >&2
        return 1
    }

    # Запускаем бесконечный цикл наблюдения
    while true; do
        # Выводим текущее состояние
        generate_json

        # Ожидаем любые изменения в файле, включая его удаление или перемещение
        # Опции: close_write (запись завершена), delete_self (файл удален), move_self (файл перемещен)
        inotifywait -q -e close_write -e delete_self -e move_self "$STATE_FILE" > /dev/null 2>&1

        # Если файл был удален или перемещен, ждем 0.1 секунды перед пересозданием наблюдения
        # inotifywait завершится с ненулевым кодом, и мы просто продолжим цикл
        sleep 0.1
    done
}

# Основная логика
case "$1" in
    "stream-json")
        stream_json
        ;;
    "--help")
        echo "Usage: $0 {--help | stream-json}"
        echo ""
        echo "Commands:"
        echo "   stream-json   -> Continuously output camera coordinates and zoom in JSON format."
        ;;
    *)
        echo "Usage: $0 {stream-json}"
        exit 1
        ;;
esac
