#!/usr/bin/env bash

if ! command -v zwwmctl &>/dev/null || ! command -v jq &>/dev/null; then
    echo "Error: zwwmctl or jq not found" >&2
    exit 1
fi

tags_json() {
    zwwmctl tags -j 2>/dev/null | jq -c '
        if .ok then
            ([.tags[].active] | add // 0) as $mask
            | reduce range(1; 11) as $i ({};
                (reduce range($i - 1) as $_ (1; . * 2)) as $bit
                | . + {("ws" + ($i | tostring)): {
                    class: (if $i <= 9 and ((($mask / ($bit * 2)) | floor) % 2 == 1)
                            then "active" else "empty" end),
                    icon: ""
                  }})
        else {} end'
}

stream_tags() {
    local last_output="" line now

    emit_once() {
        current_output=$(tags_json)
        [ -z "$current_output" ] && return
        if [[ "$current_output" != "$last_output" ]]; then
            echo "$current_output"
            last_output="$current_output"
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
    "stream-json") stream_tags ;;
    "--help") echo "Usage: $0 stream-json" ;;
    *) echo "Usage: $0 stream-json"; exit 1 ;;
esac
