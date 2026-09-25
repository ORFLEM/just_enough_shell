#!/usr/bin/env bash

if ! command -v zwwmctl &>/dev/null || ! command -v jq &>/dev/null; then
    echo "Error: zwwmctl or jq not found" >&2
    exit 1
fi

export LC_NUMERIC=C

stream_json() {
    zwwmctl listen | jq -r --unbuffered '
        if (.cameras | length) == 0 then empty
        else (.cameras[] | select(.active) // .cameras[0]) | "\(.x) \(.y) \(.zoom)"
        end' \
    | awk '$0 != prev {
            prev = $0
            printf "{\"x\":\"%.4f\",\"y\":\"%.4f\",\"zoom\":\"%.4f\"}\n", $1, $2, $3
          }'
}

case "$1" in
    "stream-json") stream_json ;;
    "--help") echo "Usage: $0 stream-json" ;;
    *) echo "Usage: $0 stream-json"; exit 1 ;;
esac
