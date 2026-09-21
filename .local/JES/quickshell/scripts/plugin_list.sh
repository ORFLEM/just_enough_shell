#!/usr/bin/env bash
#
# JES plugin backend
#
# Usage:
#   plugin_list.sh [version] [command] [extra]
#
# Commands:
#   build [--force]  (default) — build JSON + refresh cache + run launchers
#   list                       — table: name, status, warning
#   list-json                  — same, but JSON to stdout
#   cache                      — force rebuild cache only
#   clear                      — wipe cache
#
# Config (read from ~/.config/JES/config.toml):
#   directory = "~/..."          — plugin source directory
#   [settings] enableFolders = true|false
#     true  (default) — plugins may live as folders in the plugins dir
#     false           — folder-based plugins become disabled (status=disabled)
#                       with warning "plugin not in plugin bundle"
#
# Status modes:
#   active        — registered, active=true, compatible
#   disabled      — registered but active=false, or blocked by enableFolders=false
#   unregistered  — not listed in config.toml
#   broken        — incompatible, or blacklisted (crashed UI)
#
set -uo pipefail

CONFIG_FILE="$HOME/.config/JES/config.toml"
if [[ ! -f "$CONFIG_FILE" ]]; then
    echo "Ошибка: файл конфига не найден: $CONFIG_FILE" >&2
    exit 1
fi

# --- Парсим config.toml один раз в JSON для доступа к [[plugin]] блокам ---
CONFIG_JSON="{}"
if command -v taplo &>/dev/null; then
    CONFIG_JSON=$(taplo get -f "$CONFIG_FILE" -o json 2>/dev/null || echo "{}")
fi

# --- Директория плагинов из конфига ---
DIR=$(grep -E '^[[:space:]]*directory[[:space:]]*=' "$CONFIG_FILE" \
    | head -1 | awk -F '=' '{print $2}' \
    | sed 's/^[[:space:]]*//;s/[[:space:]]*$//;s/^"//;s/"$//')
DIR="${DIR/#\~/$HOME}"

if [[ -z "$DIR" || ! -d "$DIR" ]]; then
    echo "Ошибка: директория плагинов не найдена: $DIR" >&2
    exit 1
fi

# --- enableFolders (default: true) ---
ENABLE_FOLDERS=$(grep -E '^[[:space:]]*enableFolders[[:space:]]*=' "$CONFIG_FILE" 2>/dev/null \
    | head -1 | awk -F '=' '{print $2}' \
    | sed 's/^[[:space:]]*//;s/[[:space:]]*$//;s/^"//;s/"$//' | tr -d "'")
ENABLE_FOLDERS="${ENABLE_FOLDERS:-true}"

# --- Пути ---
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CACHE_ROOT="$HOME/.cache/JES"
OUTPUT_FILE="$CACHE_ROOT/JES_plugin_list.json"
CACHE_DIR="$CACHE_ROOT/cached_plugins"
CACHE_STAMP="$CACHE_ROOT/.plugins_fingerprint"
BLACKLIST_FILE="$CACHE_ROOT/blacklist"

mkdir -p "$CACHE_ROOT"

# --- Разбор аргументов ---
if [[ "${1:-}" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    HOST_VERSION="$1"
    CMD="${2:-build}"
    CMD_EXTRA="${3:-}"
else
    HOST_VERSION="${JES_HOST_VERSION:-0.2.0}"
    CMD="${1:-build}"
    CMD_EXTRA="${2:-}"
fi

if ! command -v jq &>/dev/null; then
    echo "Ошибка: jq не установлен" >&2
    exit 1
fi

# =====================================================================
#  Хелперы
# =====================================================================

get_plugin_state() {
    local name="$1"
    awk -v n="$name" '
        BEGIN { state = "unset"; found = 0 }
        /^[[:space:]]*\[\[plugin\]\]/ { in_plugin = 1; cur_matched = 0; next }
        /^[[:space:]]*\[/ && !/^[[:space:]]*\[\[plugin\]\]/ { in_plugin = 0 }
        in_plugin && /^[[:space:]]*name[[:space:]]*=/ {
            val = $0; sub(/^[[:space:]]*name[[:space:]]*=[[:space:]]*/, "", val); gsub(/^"|"$/, "", val)
            if (val == n) { cur_matched = 1; found = 1 }
        }
        in_plugin && cur_matched && /^[[:space:]]*active[[:space:]]*=/ {
            val = $0; sub(/^[[:space:]]*active[[:space:]]*=[[:space:]]*/, "", val); gsub(/^"|"$/, "", val)
            state = tolower(val) == "true" ? "true" : "false"
        }
        END {
            if (found == 1 && state == "unset") state = "false"
            print state
        }
    ' "$CONFIG_FILE" | tr -d '\n\r'
}

# Возвращает JSON-объект со всеми кастомными ключами из [[plugin]] блока
# (кроме name и active). Пустой объект если ключей нет.
get_plugin_config_json() {
    local name="$1"
    if [[ "$CONFIG_JSON" == "{}" ]]; then
        echo "{}"
        return
    fi
    echo "$CONFIG_JSON" | jq -c --arg n "$name" '
        (.plugin // [])
        | map(select(.name == $n))[0] // {}
        | del(.name, .active)
    ' 2>/dev/null || echo "{}"
}

is_blacklisted() {
    local name="$1"
    [[ ! -f "$BLACKLIST_FILE" ]] && return 1
    grep -qxF "$name" "$BLACKLIST_FILE"
}

check_compatibility() {
    local host_ver="$1"
    local plugin_ver="$2"

    IFS='.' read -r h_major h_minor h_patch <<< "$host_ver"
    IFS='.' read -r p_major p_minor p_patch <<< "$plugin_ver"

    if [[ -z "$h_major" || -z "$h_minor" || -z "$h_patch" ||
          -z "$p_major" || -z "$p_minor" || -z "$p_patch" ]]; then
        echo "INCOMPATIBLE:Invalid version format"
        return 1
    fi

    (( h_minor > 50 || h_patch > 50 )) && echo "WARNING:Host minor/patch > 50" >&2
    (( p_minor > 50 || p_patch > 50 )) && echo "WARNING:Plugin minor/patch > 50" >&2

    if (( h_major != p_major )); then
        echo "INCOMPATIBLE:Major mismatch (host $h_major, plugin $p_major)"
        return 1
    fi

    local warning=""
    local last_breaking=$(( (h_minor / 5) * 5 ))
    if (( last_breaking > 0 && p_minor < last_breaking )); then
        warning="Plugin version $plugin_ver is behind the latest breaking release $h_major.$last_breaking.0, please update."
    fi

    echo "COMPATIBLE:$warning"
    return 0
}

_plugins_fingerprint() {
    local src_fp script_mtime cfg_mtime bl_mtime
    src_fp=$(find "$DIR" \( -type f -o -type l \) -printf '%T@ %s %p\n' 2>/dev/null \
        | sort | md5sum | awk '{print $1}')
    script_mtime=$(stat -c '%Y' "${BASH_SOURCE[0]}" 2>/dev/null || echo 0)
    cfg_mtime=$(stat -c '%Y' "$CONFIG_FILE" 2>/dev/null || echo 0)
    bl_mtime=$(stat -c '%Y' "$BLACKLIST_FILE" 2>/dev/null || echo 0)
    echo "$src_fp-$script_mtime-$cfg_mtime-$bl_mtime"
}

_each_cached_manifest() {
    find "$CACHE_DIR" -maxdepth 2 -type f -name "manifest.json" 2>/dev/null | sort
}

# =====================================================================
#  Кэш
# =====================================================================

cache_plugins() {
    local force="${1:-}"
    mkdir -p "$CACHE_DIR" || return 1

    local fp
    fp=$(_plugins_fingerprint)

    if [[ "$force" != "--force" && -f "$CACHE_STAMP" ]]; then
        local old_fp
        old_fp=$(<"$CACHE_STAMP")
        if [[ "$old_fp" == "$fp" ]]; then
            return 0
        fi
    fi

    rm -rf "$CACHE_DIR"
    mkdir -p "$CACHE_DIR"

    # 1. Обычные папки с manifest.json
    local manifest pname src_dir
    while IFS= read -r -d '' manifest; do
        pname=$(jq -r '.name' "$manifest" 2>/dev/null)
        [[ -z "$pname" || "$pname" == "null" ]] && continue

        src_dir=$(dirname "$manifest")
        cp -al "$src_dir" "$CACHE_DIR/$pname" 2>/dev/null \
            || cp -a "$src_dir" "$CACHE_DIR/$pname"

        rm -f "$CACHE_DIR/$pname/.jes_from_bundle"
        touch "$CACHE_DIR/$pname/.jes_from_folder"
    done < <(find "$DIR" -type f -name "manifest.json" -print0)

    # 2. Архивы .jes.pb
    local archive pname2 tmp_dir
    while IFS= read -r -d '' archive; do
        pname2="$(basename "$archive" .jes.pb)"

        tmp_dir=$(mktemp -d)
        if ! unzip -q "$archive" -d "$tmp_dir" 2>/dev/null; then
            echo "[cache] failed to unzip: $archive" >&2
            rm -rf "$tmp_dir"
            continue
        fi

        rm -rf "$CACHE_DIR/$pname2"
        mkdir -p "$CACHE_DIR/$pname2"

        if [[ -f "$tmp_dir/manifest.json" ]]; then
            cp -a "$tmp_dir/." "$CACHE_DIR/$pname2/"
        elif [[ -d "$tmp_dir/$pname2" && -f "$tmp_dir/$pname2/manifest.json" ]]; then
            cp -a "$tmp_dir/$pname2/." "$CACHE_DIR/$pname2/"
        else
            local found_manifest
            found_manifest=$(find "$tmp_dir" -name manifest.json -type f | head -1)
            if [[ -n "$found_manifest" ]]; then
                cp -a "$(dirname "$found_manifest")/." "$CACHE_DIR/$pname2/"
            else
                echo "[cache] no manifest.json inside: $archive" >&2
                rm -rf "$tmp_dir" "$CACHE_DIR/$pname2"
                continue
            fi
        fi

        rm -f "$CACHE_DIR/$pname2/.jes_from_folder"
        touch "$CACHE_DIR/$pname2/.jes_from_bundle"

        rm -rf "$tmp_dir"
    done < <(find "$DIR" -maxdepth 1 -type f -name "*.jes.pb" -print0)

    echo "$fp" > "$CACHE_STAMP"
    echo "[cache] rebuilt: $CACHE_DIR" >&2
}

clear_plugin_cache() {
    rm -rf "$CACHE_DIR" "$CACHE_STAMP"
    echo "[cache] cleared" >&2
}

# =====================================================================
#  Листинг
# =====================================================================

_plugin_entry_json() {
    local manifest="$1" host="$2"
    local pname pver active warning compat_out compat_code api_ext
    local pdir cfg_state status

    pname=$(jq -r '.name' "$manifest" 2>/dev/null)
    [[ -z "$pname" || "$pname" == "null" ]] && return 1

    pver=$(jq -r '.api_version' "$manifest" 2>/dev/null)
    [[ -z "$pver" || "$pver" == "null" ]] && return 1

    pdir=$(dirname "$manifest")

    compat_out=$(check_compatibility "$host" "$pver" 2>/dev/null)
    compat_code=$?

    if (( compat_code == 0 )); then
        warning="${compat_out#COMPATIBLE:}"
    else
        warning="${compat_out#INCOMPATIBLE:}"
    fi

    api_ext=$(jq -r '
        ((.api_request // .api_reqest) // [])
        | if type == "array" then . else [] end
        | any(. == "api_extending")
    ' "$manifest" 2>/dev/null)

    if [[ "$api_ext" == "true" ]]; then
        if [[ -n "$warning" ]]; then
            warning="$warning; this plugin extended api"
        else
            warning="this plugin extended api"
        fi
    fi

    # --- Статус ---
    cfg_state=$(get_plugin_state "$pname")

    if is_blacklisted "$pname"; then
        status="broken"
        if [[ -n "$warning" ]]; then
            warning="$warning; plugin offed JES, it's moved in black register"
        else
            warning="plugin offed JES, it's moved in black register"
        fi
    elif (( compat_code != 0 )); then
        status="broken"
    elif [[ "$cfg_state" == "unset" ]]; then
        status="unregistered"
    elif [[ -f "$pdir/.jes_from_folder" && "$ENABLE_FOLDERS" != "true" ]]; then
        status="disabled"
        if [[ -n "$warning" ]]; then
            warning="$warning; plugin not in plugin bundle"
        else
            warning="plugin not in plugin bundle"
        fi
    elif [[ "$cfg_state" == "false" ]]; then
        status="disabled"
    else
        status="active"
    fi

    [[ "$status" == "active" ]] && active="true" || active="false"

    local main_src apireq json_files icon reqset pcfg
    main_src=$(jq -r '.main_source // "Main.qml"' "$manifest" 2>/dev/null)
    apireq=$(jq -c '(.api_request // .api_reqest // []) | if type == "array" then . else [] end' "$manifest" 2>/dev/null)
    json_files=$(jq -c '.json_files // {}' "$manifest" 2>/dev/null)
    icon=$(jq -r '.icon // "󰈔"' "$manifest" 2>/dev/null)
    reqset=$(jq -c '.required_settings // [] | if type == "array" then . else [] end' "$manifest" 2>/dev/null)
    pcfg=$(get_plugin_config_json "$pname")

    [[ -z "$apireq"     || "$apireq"     == "null" ]] && apireq="[]"
    [[ -z "$json_files" || "$json_files" == "null" ]] && json_files="{}"
    [[ -z "$icon"       || "$icon"       == "null" ]] && icon="󰈔"
    [[ -z "$reqset"     || "$reqset"     == "null" ]] && reqset="[]"
    [[ -z "$pcfg"       || "$pcfg"       == "null" ]] && pcfg="{}"

    jq -nc \
        --arg     name  "$pname" \
        --arg     ver   "$pver" \
        --argjson active "$active" \
        --arg     stat  "$status" \
        --arg     warn  "$warning" \
        --arg     src   "$CACHE_DIR/$pname" \
        --arg     main  "$main_src" \
        --argjson apireq "$apireq" \
        --argjson jsonf  "$json_files" \
        --arg     icon  "$icon" \
        --argjson reqset "$reqset" \
        --argjson pcfg   "$pcfg" \
        '{name:$name, api_version:$ver, active:$active, status:$stat, warning:$warn,
          source:$src, main_source:$main, api_request:$apireq,
          json_files:$jsonf, icon:$icon, required_settings:$reqset,
          plugin_config:$pcfg}'
}

list_plugins_info() {
    local mode="${1:-table}"
    local host="${2:-$HOST_VERSION}"
    local first=true entry

    if [[ "$mode" == "json" ]]; then
        echo "["
        while IFS= read -r manifest; do
            entry=$(_plugin_entry_json "$manifest" "$host") || continue
            if $first; then first=false; else echo ","; fi
            printf '  %s\n' "$entry"
        done < <(_each_cached_manifest)
        echo "]"
        return
    fi

    local C_RESET="" C_ACTIVE="" C_DISABLED="" C_UNREG="" C_BROKEN=""
    if [[ -t 1 ]]; then
        C_RESET=$'\033[0m'
        C_ACTIVE=$'\033[32m'
        C_DISABLED=$'\033[33m'
        C_UNREG=$'\033[37m'
        C_BROKEN=$'\033[31m'
    fi

    printf "%-26s %-14s %s\n" "NAME" "STATUS" "WARNING"
    printf "%-26s %-14s %s\n" "----" "------" "-------"

    local st_color padded
    while IFS= read -r manifest; do
        entry=$(_plugin_entry_json "$manifest" "$host") || continue
        local pname status warning
        pname=$(jq -r '.name'    <<<"$entry")
        status=$(jq -r '.status'  <<<"$entry")
        warning=$(jq -r '.warning' <<<"$entry")
        [[ -z "$warning" ]] && warning="—"

        case "$status" in
            active)       st_color="$C_ACTIVE"   ;;
            disabled)     st_color="$C_DISABLED" ;;
            unregistered) st_color="$C_UNREG"    ;;
            broken)       st_color="$C_BROKEN"   ;;
            *)            st_color=""            ;;
        esac

        padded=$(printf "%-14s" "$status")
        printf "%-26s %s%s%s %s\n" "$pname" "$st_color" "$padded" "$C_RESET" "$warning"
    done < <(_each_cached_manifest)
}

# =====================================================================
#  Диспетчер
# =====================================================================

case "$CMD" in
    build)
        if [[ "$CMD_EXTRA" != "--force" && -f "$CACHE_STAMP" && -f "$OUTPUT_FILE" ]]; then
            fp_old=$(<"$CACHE_STAMP")
            fp_now=$(_plugins_fingerprint)
            if [[ "$fp_old" == "$fp_now" ]]; then
                exit 0
            fi
        fi

        cache_plugins --force

        {
            echo "["
            first=true
            while IFS= read -r manifest; do
                entry=$(_plugin_entry_json "$manifest" "$HOST_VERSION") || continue

                name=$(jq -r '.name'   <<<"$entry")
                warn=$(jq -r '.warning' <<<"$entry")
                [[ -n "$warn" ]] && echo "[WARN] Plugin $name: $warn" >&2

                if $first; then first=false; else echo ","; fi
                printf '  %s\n' "$entry"
            done < <(_each_cached_manifest)
            echo ""
            echo "]"
        } > "$OUTPUT_FILE.tmp.$$"
        mv "$OUTPUT_FILE.tmp.$$" "$OUTPUT_FILE"

        echo "Готово! Список плагинов записан в $OUTPUT_FILE"

        "$SCRIPT_DIR/plugin_list_launcher.sh"
        "$SCRIPT_DIR/plugin_list_center.sh"
        "$SCRIPT_DIR/plugin_list_osd.sh"
        "$SCRIPT_DIR/plugin_list_Jwindow.sh"
        ;;

    list)       cache_plugins; list_plugins_info table "$HOST_VERSION" ;;
    list-json)  cache_plugins; list_plugins_info json  "$HOST_VERSION" ;;
    cache)      cache_plugins --force ;;
    clear)      clear_plugin_cache ;;

    -h|--help)
        cat <<EOF
Usage: $0 [version] [command] [extra]

Commands:
  build [--force]  (default) — build JSON + refresh cache + run launchers
  list                       — table: name, status, warning
  list-json                  — same, but JSON
  cache                      — force rebuild cache only
  clear                      — wipe cache

Status:
  active        — registered, active=true, compatible
  disabled      — registered but active=false (or blocked by enableFolders=false)
  unregistered  — not listed in config.toml
  broken        — incompatible, or blacklisted (crashed UI)

Config:
  [settings] enableFolders = true|false   (default: true)
    false — folder-based plugins become disabled
            with warning "plugin not in plugin bundle"
EOF
        ;;
    *)
        echo "Unknown command: $CMD" >&2
        exit 1
        ;;
esac
