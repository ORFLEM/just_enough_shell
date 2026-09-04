#!/usr/bin/env bash

if ! command -v driftwm &>/dev/null || ! command -v jq &>/dev/null; then
    echo "Error: driftwm or jq not found" >&2
    exit 1
fi

stream_json() {
    local last_output=""

    stdbuf -oL driftwm msg subscribe --json | while IFS= read -r line; do
        windows=$(echo "$line" | jq -c '.State.windows')
        current_output="{\"windows\":$windows}"
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
