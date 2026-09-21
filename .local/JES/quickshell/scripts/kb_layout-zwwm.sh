#!/usr/bin/env bash

if ! command -v zwwmctl &>/dev/null || ! command -v jq &>/dev/null; then
    echo "Error: zwwmctl or jq not found" >&2
    exit 1
fi

current_layout() {
    local raw group
    raw=$(zwwmctl keyboard -j 2>/dev/null)
    [ -z "$raw" ] && return

    # путь №1: валидный JSON (после фикса zwwmctl):
    # {"ok":true,"layout":"us,ru","group":0}
    if group=$(printf '%s' "$raw" | jq -r '
        if .ok then
            (.layout | split(",")) as $l | ($l[.group] // "us") | ascii_upcase
        else empty end' 2>/dev/null) && [ -n "$group" ]; then
        echo "$group"
        return
    fi

    # путь №2: текущий багованный формат {"ok":true,"layout":"1","group":Russian}
        # путь №2: текущий багованный формат {"ok":true,"layout":"1","group":English (US)}
    group=$(printf '%s' "$raw" | grep -oP '"group":\K[^,}]+' | tr -d '"')
    case "$group" in
        Russian*)     echo "RU" ;;
        English*|US|GB) echo "EN" ;;
        *) [ -n "$group" ] && printf '%s' "$group" | tr '[:lower:]' '[:upper:]' ;;
    esac
}

stream_layout() {
    local last_name="" line now

    emit_once() {
        local current_output
        current_output=$(current_layout)
        [ -z "$current_output" ] && return
        if [[ "$current_output" != "$last_name" ]]; then
            echo "$current_output"
            last_name="$current_output"
        fi
    }

    emit_once

    while true; do
        if IFS= read -r -t 0.5 line; then
            now=$(date +%s%3N)
            if (( now - last_q >= 300 )); then
                last_q=$now
                emit_once
            fi
        else
            last_q=$(date +%s%3N)
            emit_once
        fi
    done < <(stdbuf -oL zwwmctl events config tag window -j 2>/dev/null)
}

case "$1" in
    "stream-layout") stream_layout ;;
    "--help") echo "Usage: $0 stream-layout" ;;
    *) echo "Usage: $0 stream-layout"; exit 1 ;;
esac
