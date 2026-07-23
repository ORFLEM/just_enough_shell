#!/bin/sh
# Настраиваемые иконки
: "${ICON_ACTIVE:=}"
: "${ICON_URGENT:=}"
: "${ICON_OCCUPIED:=}"
: "${ICON_EMPTY:=}"

# Функция получения данных о воркспейсах (используем activeworkspace как в оригинале)
get_workspace_data() {
    local active_ws
    active_ws=$(hyprctl activeworkspace -j | jq -r '.id')
    local existing_ws  
    existing_ws=$(hyprctl workspaces -j | jq -r '[.[] | .id] | join(",")')
    active_ws=${active_ws:-1}
    existing_ws=${existing_ws:-$active_ws}
    echo "$active_ws:$existing_ws"
}

# Динамическое определение количества воркспейсов
get_max_workspaces() {
    local ws_count=$(hyprctl workspaces -j | jq -r '[.[] | .id] | length')
    ws_count=$(( ws_count > 0 ? ws_count : 10 ))
    ws_count=$(( ws_count < 10 ? 10 : ws_count ))
    echo "$ws_count"
}

# Функция определения состояния и иконки для воркспейса
get_workspace_state() {
    local id=$1
    local active=$2
    local existing=$3
    
    if [ "$id" -eq "$active" ]; then
        echo "active:$ICON_ACTIVE"
    elif echo "$existing" | grep -q "$id"; then
        echo "occupied:$ICON_OCCUPIED"  
    else
        echo "empty:$ICON_EMPTY"
    fi
}

# Глобальные переменные для кэширования
LAST_ACTIVE=""
LAST_EXISTING=""
LAST_JSON=""

# Функция обновления всех воркспейсов
update_all_workspaces() {
    local data=$(get_workspace_data)
    local active=${data%:*}
    local existing=${data#*:}
    
    if [ "$active:$existing" != "$LAST_ACTIVE:$LAST_EXISTING" ]; then
        local max_ws=$(get_max_workspaces)
        local json="{"
        local id=1
        
        # Первый элемент без запятой
        local state=$(get_workspace_state "$id" "$active" "$existing")
        local class=${state%:*}
        local icon=${state#*:}
        json="$json\"ws$id\":{\"class\":\"$class\",\"icon\":\"$icon\"}"
        
        # Остальные элементы с запятыми
        id=2
        while [ "$id" -le "$max_ws" ]; do
            state=$(get_workspace_state "$id" "$active" "$existing")
            class=${state%:*}
            icon=${state#*:}
            json="$json,\"ws$id\":{\"class\":\"$class\",\"icon\":\"$icon\"}"
            id=$((id + 1))
        done
        
        json="$json}"
        
        # Проверяем, изменился ли JSON
        if [ "$json" != "$LAST_JSON" ]; then
            echo "$json"
            LAST_JSON="$json"
        fi
        
        LAST_ACTIVE="$active"
        LAST_EXISTING="$existing"
        return 1  # Как в оригинале: 1 = данные изменились
    fi
    return 0  # Данные не изменились
}

# Функция для потокового вывода JSON
stream_workspaces_json() {
    while true; do
        if update_all_workspaces; then
            # JSON уже выведен в update_all_workspaces
            :
        fi
        sleep 0.05
    done
}



# Основная логика
case "$1" in
    "stream-ws-json")
        stream_workspaces_json
        ;;
    "change-ws")
    [[ -n "$2" ]] && hyprctl dispatch workspace "$2" >/dev/null 2>&1
    ;;
    "--help")
    echo "Usage: $0 {--help | stream-ws-json | change-ws}"
    sleep 0.1
    echo "commands:"
    sleep 0.1
    echo "   stream-ws-json   -> show information about your workspaces (active|occupied|empty)"
    sleep 0.1
    echo "   change-ws...     -> shanging your active workspace on other workspace (use number other ws)"
    ;;
    *)
        echo "Usage: $0 {stream-ws-json | change-ws}"
        exit 1
        ;;
esac
