#!/usr/bin/env bash

if ! command -v zwwmctl &>/dev/null || ! command -v jq &>/dev/null; then
    echo "Error: zwwmctl or jq not found" >&2
    exit 1
fi

export LC_NUMERIC=C

camera_state() {
    zwwmctl camera -j 2>/dev/null | jq -r '
        if .ok and (.cameras | length > 0) then
            (.cameras[] | select(.active) // .cameras[0]) |
            "\(.x) \(.y) \(.zoom)"
        else empty end'
}

emit_once() {
    local x_raw y_raw zoom_raw current_output
    read -r x_raw y_raw zoom_raw <<< "$(camera_state)"
    [ -z "$x_raw" ] && return

    current_output=$(printf '{"x":"%s","y":"%s","zoom":"%s"}' \
        "$(printf "%.4f" "$x_raw")" \
        "$(printf "%.4f" "$y_raw")" \
        "$(printf "%.4f" "$zoom_raw")")

    if [[ "$current_output" != "$last_output" ]]; then
        echo "$current_output"
        last_output="$current_output"
    fi
}

stream_json() {
    last_output=""
    local line now

    emit_once

    # события: троттлинг 300 мс — во время драга/пана их десятки в секунду
    # таймаут 0.5 c: дожимает финальное состояние после всплеска событий
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
    done < <(stdbuf -oL zwwmctl events tag window output -j 2>/dev/null)
}

case "$1" in
    "stream-json") stream_json ;;
    "--help") echo "Usage: $0 stream-json" ;;
    *) echo "Usage: $0 stream-json"; exit 1 ;;
esac
