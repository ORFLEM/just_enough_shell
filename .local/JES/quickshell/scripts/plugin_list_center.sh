#!/usr/bin/env bash

PLUGIN_LIST="$HOME/.cache/JES/JES_plugin_list.json"
OUTPUT_FILE="$HOME/.cache/JES/JES_center_loaders.json"

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
    has_center=$(echo "$plugin" | jq -r '.api_request | type == "array" and any(. == "plugin_center")')
    active=$(echo "$plugin" | jq -r '.active // false')
    plugin_name=$(echo "$plugin" | jq -r '.name // empty')
    plugin_icon=$(echo "$plugin" | jq -r '.icon // ""')
    source_dir=$(echo "$plugin" | jq -r '.source // empty')
    center_file=$(echo "$plugin" | jq -r '.json_files.plugin_center // empty')

    echo "DEBUG: plugin=$plugin_name, has_center=$has_center, active=$active, source=$source_dir, launch_file=$launch_file" >&2

    if [[ "$has_center" != "true" || "$active" != "true" || -z "$plugin_name" ]]; then
        echo "DEBUG: Пропускаем из-за условий" >&2
        continue
    fi

    full_path="$source_dir/$center_file"
    if [[ ! -f "$full_path" ]]; then
        echo "Предупреждение: $full_path не найден" >&2
        continue
    fi

    content=$(cat "$full_path" | jq -c '.' 2>/dev/null)
    if [[ -z "$content" || "$content" == "null" ]]; then
        echo "Предупреждение: $full_path не содержит валидный JSON" >&2
        continue
    fi

        if echo "$content" | jq -e 'type == "array"' >/dev/null 2>&1; then
            info="$content"
        else
            info=$(echo "$content" | jq -c '[.]')
        fi

        tab=$(jq -n \
            --arg source "$source_dir" \
            --argjson info "$info" \
            '{source: $source, info: $info}')

    result=$(echo "$result" | jq --argjson tab "$tab" '. + [$tab]')
done < <(jq -c '.[]' "$PLUGIN_LIST")

echo "$result" > "$OUTPUT_FILE"
echo "Готово! Список вкладок плагинов записан в $OUTPUT_FILE"
