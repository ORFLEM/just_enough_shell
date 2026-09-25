#!/usr/bin/env bash

if ! command -v zwwmctl &>/dev/null || ! command -v jq &>/dev/null; then
    echo "Error: zwwmctl or jq not found" >&2
    exit 1
fi

stream_layout() {
    zwwmctl listen | jq -r --unbuffered '
        if .keyboard then
            (.keyboard.layout | split(",")) as $l
            | ($l[.keyboard.group] // "us")
            | ascii_upcase
            | ({"US":"EN","GB":"EN"}[.]) // .
        else empty end' \
    | awk '$0 != "" && $0 != prev { print; prev = $0 }'
}

case "$1" in
    "stream-layout") stream_layout ;;
    "--help") echo "Usage: $0 stream-layout" ;;
    *) echo "Usage: $0 stream-layout"; exit 1 ;;
esac
