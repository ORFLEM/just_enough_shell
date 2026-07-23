#!/usr/bin/env bash

CONFIG_FILE="$HOME/.config/JES/config.toml"
if [[ ! -f "$CONFIG_FILE" ]]; then
    echo "Ошибка: файл конфига не найден" >&2
    exit 1
fi

# Получаем directory
DIR=$(grep directory "$CONFIG_FILE" | awk -F '=' '{print $2}' | sed 's/^[[:space:]]*//;s/[[:space:]]*$//;s/^"//;s/"$//;s/^~/$HOME/')
eval DIR="$DIR"

if [[ -z "$DIR" || ! -d "$DIR" ]]; then
    echo "Ошибка: директория плагинов не найдена: $DIR" >&2
    exit 1
fi

OUTPUT_FILE="$HOME/.cache/JES/JES_plugin_list.json"

# Функция получения active (возвращает только true или false)
get_active() {
    local name="$1"
    awk -v n="$name" '
        BEGIN { active = "false" }
        /^[[:space:]]*\[\[plugin\]\]/ { in_plugin = 1; found = 0; next }
        /^[[:space:]]*\[/ && !/^[[:space:]]*\[\[plugin\]\]/ { in_plugin = 0 }
        in_plugin && /^[[:space:]]*name[[:space:]]*=/ {
            val = $0; sub(/^[[:space:]]*name[[:space:]]*=[[:space:]]*/, "", val); gsub(/^"|"$/, "", val)
            if (val == n) found = 1
        }
        in_plugin && found && /^[[:space:]]*active[[:space:]]*=/ {
            val = $0; sub(/^[[:space:]]*active[[:space:]]*=[[:space:]]*/, "", val); gsub(/^"|"$/, "", val)
            active = tolower(val) == "true" ? "true" : "false"
        }
        END { print active }
    ' "$CONFIG_FILE" | tr -d '\n\r'
}

# Функция проверки совместимости
check_compatibility() {
    local host_ver="$1"
    local plugin_ver="$2"

    IFS='.' read -r h_major h_minor h_patch <<< "$host_ver"
    IFS='.' read -r p_major p_minor p_patch <<< "$plugin_ver"

    if [[ -z "$h_major" || -z "$h_minor" || -z "$h_patch" ||
          -z "$p_major" || -z "$p_minor" || -z "$p_patch" ]]; then
        echo "INVALID"
        return 1
    fi

    # Ограничения minor/patch <= 50 (только предупреждение)
    if (( h_minor > 50 || h_patch > 50 )); then
        echo "WARNING:Host minor/patch > 50"
    fi
    if (( p_minor > 50 || p_patch > 50 )); then
        echo "WARNING:Plugin minor/patch > 50"
    fi

    # Major должен совпадать – иначе несовместим
    if (( h_major != p_major )); then
        echo "INCOMPATIBLE:Major mismatch"
        return 1
    fi

    local warning=""
    # Последний ломающий релиз (кратный 5) <= h_minor
    local last_breaking=$(( (h_minor / 5) * 5 ))
    if (( last_breaking > 0 && p_minor < last_breaking )); then
        warning="Plugin version $plugin_ver is behind the latest breaking release $h_major.$last_breaking.0, please update."
    fi

    echo "COMPATIBLE:$warning"
    return 0
}

HOST_VERSION="$1"
if [[ -z "$HOST_VERSION" ]]; then
    echo "Usage: $0 <host_api_version>" >&2
    exit 1
fi

if ! command -v jq &> /dev/null; then
    echo "Ошибка: jq не установлен" >&2
    exit 1
fi

# Формируем JSON
{
    echo "["
    first=true
    find "$DIR" -type f -name "manifest.json" | sort | while read -r manifest; do
        name=$(jq -r '.name' "$manifest" 2>/dev/null)
        if [[ -z "$name" || "$name" == "null" ]]; then
            continue
        fi

        plugin_version=$(jq -r '.api_version' "$manifest" 2>/dev/null)
        if [[ -z "$plugin_version" || "$plugin_version" == "null" ]]; then
            continue
        fi

        compat_output=$(check_compatibility "$HOST_VERSION" "$plugin_version")
        compat_code=$?
        compat_warning=""
        active=false

        if (( compat_code == 0 )); then
            active=$(get_active "$name")
            if [[ "$compat_output" == COMPATIBLE:* ]]; then
                compat_warning="${compat_output#COMPATIBLE:}"
            fi
        else
            compat_warning="${compat_output#INCOMPATIBLE:}"
        fi

        # Выводим предупреждение в stderr для отладки
        if [[ -n "$compat_warning" ]]; then
            echo "[WARN] Plugin $name: $compat_warning" >&2
        fi

        source_dir=$(dirname "$manifest")
        obj=$(jq -c \
            --arg src "$source_dir" \
            --argjson act "$active" \
            --arg warn "$compat_warning" \
            '. + {source: $src, active: $act, compatibility_warning: $warn}' \
            "$manifest" 2>/dev/null)
        if [[ -z "$obj" || "$obj" == "null" ]]; then
            continue
        fi
        if $first; then
            first=false
        else
            echo ","
        fi
        echo "  $obj"
    done
    echo ""
    echo "]"
} > "$OUTPUT_FILE"

echo "Готово! Список плагинов записан в $OUTPUT_FILE"


SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
$SCRIPT_DIR/plugin_list_launcher.sh
$SCRIPT_DIR/plugin_list_center.sh
