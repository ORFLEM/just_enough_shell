#!/usr/bin/env bash

if ! command -v zwwmctl &>/dev/null || ! command -v jq &>/dev/null; then
    echo "Error: zwwmctl or jq not found" >&2
    exit 1
fi

focused_title() {
    zwwmctl clients -j 2>/dev/null | jq -r '
        if .ok then
            [.clients[]? | select((.state / 2 | floor) % 2 == 1) | .title] | .[0] // ""
        else empty end'
}

stream_window() {
    local last_name="" line title now

    emit_once() {
        title=$(focused_title)
        if [[ -n "$title" && "$title" != "$last_name" ]]; then
            echo "$title"
            last_name="$title"
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
    done < <(stdbuf -oL zwwmctl events tag window -j 2>/dev/null)
}

case "$1" in
    "stream-window") stream_window ;;
    "--help") echo "Usage: $0 stream-window" ;;
    *) echo "Usage: $0 stream-window"; exit 1 ;;
esac
