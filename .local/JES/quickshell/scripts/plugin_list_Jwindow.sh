#!/usr/bin/env bash

PLUGIN_LIST="$HOME/.cache/JES/JES_plugin_list.json"
OUTPUT_FILE="$HOME/.cache/JES/JES_Jwindow_tabs.json"

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
    has_jwindow=$(echo "$plugin" | jq -r '.api_request | type == "array" and any(. == "Jwindow")')
    active=$(echo "$plugin" | jq -r '.active // false')
    plugin_name=$(echo "$plugin" | jq -r '.name // empty')
    source_dir=$(echo "$plugin" | jq -r '.source // empty')
    jwindow_file=$(echo "$plugin" | jq -r '.json_files.Jwindow // empty')

    echo "DEBUG: plugin=$plugin_name, has_jwindow=$has_jwindow, active=$active, source=$source_dir, jwindow_file=$jwindow_file" >&2

    if [[ "$has_jwindow" != "true" || "$active" != "true" || -z "$plugin_name" ]]; then
        echo "DEBUG: Пропускаем из-за условий" >&2
        continue
    fi

    # Путь к JSON-файлу со списком вкладок плагина
    json_path="$source_dir/$jwindow_file"

    if [[ ! -f "$json_path" ]]; then
        echo "Предупреждение: $json_path не найден" >&2
        continue
    fi

    # Проверяем, что это массив
    if ! jq -e 'type == "array"' "$json_path" >/dev/null 2>&1; then
        echo "Предупреждение: $json_path не содержит массив" >&2
        continue
    fi

    # Читаем вкладки из JSON плагина.
    # Если source относительный — дополняем до абсолютного от source_dir
    tabs=$(jq -c --arg source_dir "$source_dir" '
        .[] |
        if (.source | startswith("/") | not) then
            .source = $source_dir + "/" + .source
        else
            .
        end
    ' "$json_path")

    while IFS= read -r tab; do
        tab_source=$(echo "$tab" | jq -r '.source // empty')
        tab_name=$(echo "$tab" | jq -r '.name // empty')

        if [[ -z "$tab_name" || -z "$tab_source" ]]; then
            echo "Предупреждение: пропускаем вкладку без name/source" >&2
            continue
        fi

        if [[ ! -f "$tab_source" ]]; then
            echo "Предупреждение: QML $tab_source не найден, пропускаем" >&2
            continue
        fi

        result=$(echo "$result" | jq --argjson tab "$tab" '. + [$tab]')
        echo "DEBUG: добавлена вкладка '$tab_name' → $tab_source" >&2
    done <<< "$tabs"

done < <(jq -c '.[]' "$PLUGIN_LIST")

echo "$result" > "$OUTPUT_FILE"
echo "Готово! Записано в $OUTPUT_FILE" >&2
echo "$result"
