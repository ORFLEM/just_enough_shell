#!/usr/bin/env bash

if ! command -v zwwmctl &>/dev/null || ! command -v jq &>/dev/null; then
    echo "Error: zwwmctl or jq not found" >&2
    exit 1
fi

stream_tags() {
    zwwmctl listen | jq -c --unbuffered '
        ([.tags[].active] | add // 0) as $mask
        | reduce range(1; 11) as $i ({};
            (reduce range($i - 1) as $_ (1; . * 2)) as $bit
            | . + {("ws" + ($i | tostring)): {
                class: (if $i <= 9 and ((($mask / ($bit * 2)) | floor) % 2 == 1)
                        then "active" else "empty" end),
                icon: "" }})' \
    | awk '$0 != prev { print; prev = $0 }'
}

case "$1" in
    "stream-json") stream_tags ;;
    "--help") echo "Usage: $0 stream-json" ;;
    *) echo "Usage: $0 stream-json"; exit 1 ;;
esac
