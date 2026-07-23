#!/usr/bin/env bash

PLUGIN_LIST="$HOME/.cache/JES/JES_plugin_list.json"
OUTPUT_FILE="$HOME/.cache/JES/JES_launcher_modes.json"

if [[ ! -f "$PLUGIN_LIST" ]]; then
    echo "Ошибка: $PLUGIN_LIST не найден" >&2
    exit 1
fi

if ! command -v jq &> /dev/null; then
    echo "Ошибка: jq не установлен" >&2
    exit 1
fi

result="[]"

while IFS= read -r plugin; do
    has_launcher=$(echo "$plugin" | jq -r '.api_request | type == "array" and any(. == "launcher")')
    active=$(echo "$plugin" | jq -r '.active // false')
    plugin_name=$(echo "$plugin" | jq -r '.name // empty')
    plugin_icon=$(echo "$plugin" | jq -r '.icon // ""')
    source_dir=$(echo "$plugin" | jq -r '.source // empty')
    launch_file=$(echo "$plugin" | jq -r '.json_files.launcher // empty')

    echo "DEBUG: plugin=$plugin_name, has_launcher=$has_launcher, active=$active, source=$source_dir, launch_file=$launch_file" >&2

    if [[ "$has_launcher" != "true" || "$active" != "true" || -z "$plugin_name" ]]; then
        echo "DEBUG: Пропускаем из-за условий" >&2
        continue
    fi

    full_path="$source_dir/$launch_file"
    if [[ ! -f "$full_path" ]]; then
        echo "Предупреждение: $full_path не найден" >&2
        continue
    fi

    content=$(cat "$full_path" | jq -c '.' 2>/dev/null)
    if [[ -z "$content" || "$content" == "null" ]]; then
        echo "Предупреждение: $full_path не содержит валидный JSON" >&2
        continue
    fi

    # Проверяем, является ли содержимое готовой вкладкой (объект с полем info-массив)
    if echo "$content" | jq -e 'type == "object" and has("info") and (.info | type == "array")' >/dev/null 2>&1; then
        # Используем как есть, но подставляем значения по умолчанию из плагина, если отсутствуют
        tab=$(echo "$content" | jq \
            --arg default_name "$plugin_name" \
            --arg default_icon "$plugin_icon" \
            '.name //= $default_name | .icon //= $default_icon | .placeholder //= ("Search in " + (.name // $default_name) + "...")')
    else
        # Это массив режимов (или одиночный объект) — создаём вкладку
        # Гарантируем, что info — массив
        if echo "$content" | jq -e 'type == "array"' >/dev/null 2>&1; then
            info="$content"
        else
            # Если не массив, заворачиваем в массив (один элемент)
            info=$(echo "$content" | jq -c '[.]')
        fi

        tab=$(jq -n \
            --arg name "$plugin_name" \
            --arg icon "$plugin_icon" \
            --arg placeholder "Search in $plugin_name..." \
            --argjson info "$info" \
            '{name: $name, icon: $icon, placeholder: $placeholder, info: $info}')
    fi

    result=$(echo "$result" | jq --argjson tab "$tab" '. + [$tab]')
done < <(jq -c '.[]' "$PLUGIN_LIST")

echo "$result" > "$OUTPUT_FILE"
echo "Готово! Список вкладок плагинов записан в $OUTPUT_FILE"
