#!/usr/bin/env bash

if ! command -v driftwm &>/dev/null || ! command -v jq &>/dev/null; then
    echo "Error: driftwm or jq not found" >&2
    exit 1
fi

stream_layout() {
    local last_layout=""

    stdbuf -oL driftwm msg subscribe --json | while IFS= read -r line; do
        layout=$(echo "$line" | jq -r '.State.layout_short // ""')
        case "$layout" in
            "us"|"en"|"english"|"usa"|"English(US)") current="EN" ;;
            "ru"|"russian"|"Russian") current="RU" ;;
            *) current="$layout" ;;
        esac
        if [[ "$current" != "$last_layout" ]]; then
            echo "$current"
            last_layout="$current"
        fi
    done
}

case "$1" in
    "stream-layout") stream_layout ;;
    "--help") echo "Usage: $0 stream-layout" ;;
    *) echo "Usage: $0 stream-layout"; exit 1 ;;
esac
