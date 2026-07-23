#!/usr/bin/env bash

RUNTIME_DIR="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"
STATE_FILE="${RUNTIME_DIR}/driftwm/state"

get_windows() {
    if [[ -f "$STATE_FILE" ]]; then
        grep -m1 '^windows=' "$STATE_FILE" | cut -d'=' -f2-
    else
        echo "[]"
    fi
}

generate_json() {
    local windows=$(get_windows)

    # Проверяем, что windows – валидный JSON
    if ! echo "$windows" | jq empty 2>/dev/null; then
        windows="[]"
    fi

    # Выводим одну строку JSON
    echo "{\"windows\":$windows}"
}

stream_json() {
    if ! command -v inotifywait &>/dev/null; then
        echo "Warning: inotifywait not found." >&2
        generate_json
        return 1
    fi

    touch "$STATE_FILE" 2>/dev/null || true

    local last_output=""
    while true; do
        current_output=$(generate_json)
        if [[ "$current_output" != "$last_output" ]]; then
            echo "$current_output"
            last_output="$current_output"
        fi
        inotifywait -q -e close_write -e delete_self -e move_self "$STATE_FILE" >/dev/null 2>&1
        sleep 0.05
    done
}

case "$1" in
    "stream-json")
        stream_json
        ;;
    "--help")
        echo "Usage: $0 {--help | stream-json}"
        echo "  stream-json   -> непрерывно выводит JSON с камерой и окнами"
        ;;
    *)
        echo "Usage: $0 stream-json"
        exit 1
        ;;
esac
