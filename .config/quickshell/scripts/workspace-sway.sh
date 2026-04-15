#!/bin/sh
# Настраиваемые иконки
: "${ICON_ACTIVE:=}"
: "${ICON_URGENT:=}"
: "${ICON_OCCUPIED:=}"
: "${ICON_EMPTY:=}"

# Функция получения данных о воркспейсах
get_workspace_data() {
    local workspaces_json=$(swaymsg -t get_workspaces)
    local active_ws=$(echo "$workspaces_json" | jq -r '.[] | select(.focused == true) | .num')
    local existing_ws=$(echo "$workspaces_json" | jq -r '[.[] | .num] | join(",")')
    local urgent_ws=$(echo "$workspaces_json" | jq -r '[.[] | select(.urgent == true) | .num] | join(",")')
    
    active_ws=${active_ws:-1}
    existing_ws=${existing_ws:-$active_ws}
    urgent_ws=${urgent_ws:-""}
    
    echo "$active_ws:$existing_ws:$urgent_ws"
}

# Динамическое определение количества воркспейсов
get_max_workspaces() {
    local ws_count=$(swaymsg -t get_workspaces | jq -r '[.[] | .num] | max')
    ws_count=${ws_count:-10}
    ws_count=$(( ws_count < 10 ? 10 : ws_count ))
    echo "$ws_count"
}

# Функция определения состояния и иконки для воркспейса
get_workspace_state() {
    local id=$1
    local active=$2
    local existing=$3
    local urgent=$4
    
    if echo "$urgent" | grep -qw "$id"; then
        echo "urgent:$ICON_URGENT"
    elif [ "$id" -eq "$active" ]; then
        echo "active:$ICON_ACTIVE"
    elif echo "$existing" | grep -qw "$id"; then
        echo "occupied:$ICON_OCCUPIED"  
    else
        echo "empty:$ICON_EMPTY"
    fi
}

# Функция генерации JSON для всех воркспейсов
generate_json() {
    local data=$(get_workspace_data)
    local active=$(echo "$data" | cut -d: -f1)
    local existing=$(echo "$data" | cut -d: -f2)
    local urgent=$(echo "$data" | cut -d: -f3)
    
    local max_ws=$(get_max_workspaces)
    local json="{"
    local id=1
    
    # Первый элемент без запятой
    local state=$(get_workspace_state "$id" "$active" "$existing" "$urgent")
    local class=${state%:*}
    local icon=${state#*:}
    json="$json\"ws$id\":{\"class\":\"$class\",\"icon\":\"$icon\"}"
    
    # Остальные элементы с запятыми
    id=2
    while [ "$id" -le "$max_ws" ]; do
        state=$(get_workspace_state "$id" "$active" "$existing" "$urgent")
        class=${state%:*}
        icon=${state#*:}
        json="$json,\"ws$id\":{\"class\":\"$class\",\"icon\":\"$icon\"}"
        id=$((id + 1))
    done
    
    json="$json}"
    echo "$json"
}

# Функция для потокового вывода JSON с подпиской на события
stream_workspaces_json() {
    # Первичный вывод при старте
    generate_json
    
    # Подписка на события воркспейсов
    swaymsg -t subscribe -m '["workspace","window"]' | while read -r event; do
        change=$(echo "$event" | jq -r '.change // ""')
        
        # Обновляем при изменении воркспейса, перемещении окон или изменении urgent
        case "$change" in
            focus|init|empty|move|urgent|reload)
                generate_json
                ;;
        esac
    done
}

# Основная логика
case "$1" in
    "stream-ws-json")
        stream_workspaces_json
        ;;
    "change-ws")
        [[ -n "$2" ]] && swaymsg workspace number "$2" >/dev/null 2>&1
        ;;
    "--help")
        echo "Usage: $0 {--help | stream-ws-json | change-ws}"
        sleep 0.1
        echo "commands:"
        sleep 0.1
        echo "   stream-ws-json   -> show information about your workspaces (active|occupied|empty|urgent)"
        sleep 0.1
        echo "   change-ws...     -> changing your active workspace on other workspace (use number other ws)"
        ;;
    *)
        echo "Usage: $0 {stream-ws-json | change-ws}"
        exit 1
        ;;
esac
