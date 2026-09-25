#!/usr/bin/env bash

if ! command -v zwwmctl &>/dev/null || ! command -v jq &>/dev/null; then
    echo "Error: zwwmctl or jq not found" >&2
    exit 1
fi

# zwwm endless-canvas живёт в y-DOWN мире, а MiniMap.qml написан под driftwm
# с y-UP миром (центр окна: (camY - posY)). Поэтому Y эмитим негированным.
# Камера из camera-zwwm.sh — тоже y-up и по ЦЕНТРУ вьюпорта.
#
#   world_x = cam.x + (tile - out.logical.x) / zoom
#   world_y = -(cam.y + (tile - out.logical.y) / zoom)
#   size    = tile_size / zoom
#
# Оговорки: workarea (минус резервации layer-shell) zwwmctl не отдаёт — берём
# логическое начало выхода, сдвиг ~высота_панели/zoom, пренебрежимо.
# state окна: 1 | (focused ? 4 : 0) — фокус это бит 4.

FILTER='
  . as $state
  | ($origins) as $o
  | { windows:
      [ $state.clients[]?
        | . as $w
        | ([ $state.cameras[]? | select(.output == $w.output) ] | first) as $cam
        | if $cam == null then empty
          else
            ($o[($w.output | tostring)] // {x: 0, y: 0}) as $out
            | ($cam.zoom | tonumber) as $z
            | {
                position: [
                  (($cam.x | tonumber) + (($w.x - $out.x) / $z)),
                  (-1 * (($cam.y | tonumber) + (($w.y - $out.y) / $z)))
                ],
                size: [ ($w.width / $z), ($w.height / $z) ],
                id: $w.id,
                app_id: $w.app_id,
                title: $w.title,
                is_focused: (((($w.state // 0) / 4) | floor) % 2 == 1)
              }
          end
      ] }
'

OUTPUTS='{}'

refresh_outputs() {
    local origins
    origins=$(zwwmctl outputs -j 2>/dev/null | jq -c '
        [.outputs[]? | { key: (.id | tostring),
                         value: { x: .logical.x, y: .logical.y } }] | from_entries')
    [ -n "$origins" ] && OUTPUTS="$origins"
}

stream_json() {
    local last_output="" line now

    emit() {
        local state current_output
        state=$(zwwmctl states -j 2>/dev/null)
        [ -z "$state" ] && return
        current_output=$(jq -c --argjson origins "$OUTPUTS" "$FILTER" <<<"$state")
        [ -z "$current_output" ] && return
        if [[ "$current_output" != "$last_output" ]]; then
            echo "$current_output"
            last_output="$current_output"
        fi
    }

    refresh_outputs
    emit

    while true; do
        if IFS= read -r -t 0.5 line; then
            case "$line" in
                *'"event":"output"'*|*'"event": "output"'*|*'"event":"config"'*|*'"event": "config"'*)
                    refresh_outputs ;;
            esac
            now=$(date +%s%3N)
            if (( now - last_q >= 300 )); then
                last_q=$now
                emit
            fi
        else
            last_q=$(date +%s%3N)
            emit
        fi
    done < <(stdbuf -oL zwwmctl events window camera output config -j 2>/dev/null)
}

case "$1" in
    "stream-json") stream_json ;;
    "--help") echo "Usage: $0 stream-json" ;;
    *) echo "Usage: $0 stream-json"; exit 1 ;;
esac
