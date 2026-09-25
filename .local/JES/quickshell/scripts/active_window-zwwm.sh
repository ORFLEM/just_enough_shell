#!/usr/bin/env bash

if ! command -v zwwmctl &>/dev/null || ! command -v jq &>/dev/null; then
    echo "Error: zwwmctl or jq not found" >&2
    exit 1
fi

stream_window() {
    # state bit0 = focused
    zwwmctl listen | jq -r --unbuffered '
        [.clients[] | select(.state % 2 == 1) | .title][0] // empty' \
    | awk '$0 != "" && $0 != prev { print; prev = $0 }'
}

case "$1" in
    "stream-window") stream_window ;;
    "--help") echo "Usage: $0 stream-window" ;;
    *) echo "Usage: $0 stream-window"; exit 1 ;;
esac
