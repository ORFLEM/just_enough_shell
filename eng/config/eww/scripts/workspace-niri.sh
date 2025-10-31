#!/bin/sh
# Настраиваемые иконки
: "${ICON_ACTIVE:=}"
: "${ICON_URGENT:=}"
: "${ICON_OCCUPIED:=}"
: "${ICON_EMPTY:=}"

# Функция получения данных о воркспейсах
get_workspace_data() {
    local workspaces_json=$(niri msg -j workspaces 2>/dev/null)
    
    # Получаем активный воркспейс
    local active_ws=$(echo "$workspaces_json" | jq -r '.[] | select(.is_active == true) | .idx')
    
    # Получаем существующие воркспейсы
    local existing_ws=$(echo "$workspaces_json" | jq -r '[.[] | .idx] | join(",")')
    
    active_ws=${active_ws:-1}
    existing_ws=${existing_ws:-$active_ws}
    
    echo "$active_ws:$existing_ws"
}

# Динамическое определение количества воркспейсов
get_max_workspaces() {
    local ws_count=$(niri msg -j workspaces 2>/dev/null | jq -r '[.[] | .idx] | length')
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
        return 1  # 1 = данные изменились
    fi
    return 0  # Данные не изменились
}

# Функция для потокового вывода JSON
stream_workspaces_json() {
    while true; do
        if update_all_workspaces; then
            :
        fi
        sleep 0.05
    done
}

# Основная логика
case "$1" in
    "stream-workspaces-json")
        stream_workspaces_json
        ;;
    *)
        echo "Usage: $0 {stream-workspaces-json}"
        exit 1
        ;;
esac
