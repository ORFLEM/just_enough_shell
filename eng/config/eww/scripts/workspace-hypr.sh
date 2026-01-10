#!/bin/sh
: "${ICON_ACTIVE:=}"
: "${ICON_URGENT:=}"
: "${ICON_OCCUPIED:=}"
: "${ICON_EMPTY:=}"

get_workspace_data() {
    local active_ws=$(hyprctl activeworkspace -j | jq -r '.id')
    local workspaces=$(hyprctl workspaces -j)
    local existing_ws=$(echo "$workspaces" | jq -r '[.[].id] | join(",")')
    
    # Hyprland не имеет встроенного urgent, но можем эмулировать через lastwindow events
    # Для простоты пока оставим пустым
    local urgent_ws=""
    
    active_ws=${active_ws:-1}
    existing_ws=${existing_ws:-$active_ws}
    
    echo "$active_ws:$existing_ws:$urgent_ws"
}

get_max_workspaces() {
    local ws_count=$(hyprctl workspaces -j | jq -r '[.[].id] | max')
    ws_count=${ws_count:-10}
    ws_count=$(( ws_count < 10 ? 10 : ws_count ))
    echo "$ws_count"
}

get_workspace_state() {
    local id=$1
    local active=$2
    local existing=$3
    local urgent=$4
    
    if [ -n "$urgent" ] && echo "$urgent" | grep -qw "$id"; then
        echo "urgent:$ICON_URGENT"
    elif [ "$id" -eq "$active" ]; then
        echo "active:$ICON_ACTIVE"
    elif echo "$existing" | grep -qw "$id"; then
        echo "occupied:$ICON_OCCUPIED"
    else
        echo "empty:$ICON_EMPTY"
    fi
}

generate_json() {
    local data=$(get_workspace_data)
    local active=$(echo "$data" | cut -d: -f1)
    local existing=$(echo "$data" | cut -d: -f2)
    local urgent=$(echo "$data" | cut -d: -f3)
    
    local max_ws=$(get_max_workspaces)
    local json="{"
    local first=1
    
    for id in $(seq 1 $max_ws); do
        local state=$(get_workspace_state "$id" "$active" "$existing" "$urgent")
        local class=${state%:*}
        local icon=${state#*:}
        
        if [ $first -eq 1 ]; then
            json="$json\"ws$id\":{\"class\":\"$class\",\"icon\":\"$icon\"}"
            first=0
        else
            json="$json,\"ws$id\":{\"class\":\"$class\",\"icon\":\"$icon\"}"
        fi
    done
    
    json="$json}"
    echo "$json"
}

stream_workspaces_json() {
    # Первичный вывод
    generate_json
    
    # Подписка на события
    socat -U - UNIX-CONNECT:/tmp/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock | while read -r line; do
        event=$(echo "$line" | cut -d'>' -f1)
        
        case "$event" in
            workspace|createworkspace|destroyworkspace|moveworkspace|renameworkspace|activewindow|openwindow|closewindow|movewindow)
                generate_json
                ;;
        esac
    done
}

case "$1" in
    "stream-ws-json")
        stream_workspaces_json
        ;;
    "change-ws")
        [[ -n "$2" ]] && hyprctl dispatch workspace "$2" >/dev/null 2>&1
        ;;
    "--help")
        echo "Usage: $0 {--help | stream-ws-json | change-ws}"
        echo "commands:"
        echo "   stream-ws-json   -> show information about your workspaces (active|occupied|empty)"
        echo "   change-ws...     -> changing your active workspace (use workspace number)"
        ;;
    *)
        echo "Usage: $0 {stream-ws-json | change-ws}"
        exit 1
        ;;
esac
