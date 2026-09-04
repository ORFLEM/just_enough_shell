#!/usr/bin/env bash

if ! command -v driftwm &>/dev/null || ! command -v jq &>/dev/null; then
    echo "Error: driftwm or jq not found" >&2
    exit 1
fi

stream_json() {
    local last_output=""
    export LC_NUMERIC=C

    stdbuf -oL driftwm msg subscribe --json | while IFS= read -r line; do
        read -r x_raw y_raw zoom_raw <<< "$(echo "$line" | jq -r '.State | "\(.camera[0]) \(.camera[1]) \(.zoom)"')"
        x_fmt=$(printf "%.4f" "$x_raw")
        y_fmt=$(printf "%.4f" "$y_raw")
        zoom_fmt=$(printf "%.4f" "$zoom_raw")
        current_output=$(printf '{"x":"%s","y":"%s","zoom":"%s"}' "$x_fmt" "$y_fmt" "$zoom_fmt")
        if [[ "$current_output" != "$last_output" ]]; then
            echo "$current_output"
            last_output="$current_output"
        fi
    done
}

case "$1" in
    "stream-json") stream_json ;;
    "--help") echo "Usage: $0 stream-json" ;;
    *) echo "Usage: $0 stream-json"; exit 1 ;;
esac
