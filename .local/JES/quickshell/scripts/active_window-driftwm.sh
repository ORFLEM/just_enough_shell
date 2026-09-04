#!/usr/bin/env bash

if ! command -v driftwm &>/dev/null || ! command -v jq &>/dev/null; then
    echo "Error: driftwm or jq not found" >&2
    exit 1
fi

stream_window() {
    local last_name=""

    stdbuf -oL driftwm msg subscribe --json | while IFS= read -r line; do
        name=$(echo "$line" | jq -r '.State.windows[] | select(.is_focused==true) | .app_id // .title // ""')
        if [[ -n "$name" ]]; then
            name=$(echo "$name" | sed -E 's/^(org\.|app\.)//' | sed 's/\.desktop$//' | sed 's/.*\.//;s/_/ /g')
            if [[ "$name" != "$last_name" ]]; then
                echo "$name"
                last_name="$name"
            fi
        fi
    done
}

case "$1" in
    "stream-window") stream_window ;;
    "--help") echo "Usage: $0 stream-window" ;;
    *) echo "Usage: $0 stream-window"; exit 1 ;;
esac
