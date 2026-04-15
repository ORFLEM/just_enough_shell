#!/usr/bin/env bash

DEFAULT_ART="$HOME/.config/quickshell/bar/images/music.png"
CACHE_DIR="$HOME/.cache/qs_music_art"
CURRENT_ART="$CACHE_DIR/current_art.jpg"
LAST_OUTPUT=""
LAST_URL=""
LAST_TRACK_ID=""
COOLDOWN=0

mkdir -p "$CACHE_DIR"

# Генерация JSON (с экранированием кавычек, чтобы не ломать парсер)
generate_json() {
    local artist="$1" title="$2" art="$3" status="$4"
    local icon="󰐊"
    [[ "$status" == "Playing" ]] && icon="󰏤"
    artist="${artist//\"/\\\"}"
    title="${title//\"/\\\"}"
    printf '{"artist":"%s","title":"%s","art":"%s","status":"%s"}\n' "$artist" "$title" "$art" "$icon"
}

# Скачивание обложки с атомарной записью
download_art() {
    local url="$1"
    [[ -z "$url" ]] && { echo "$DEFAULT_ART"; return; }
    [[ "$url" == "$LAST_URL" && -f "$CURRENT_ART" ]] && { echo "$CURRENT_ART"; return; }

    local tmp="${CURRENT_ART}.tmp"
    rm -f "$tmp"
    if curl -s -L -m 5 "$url" -o "$tmp" 2>/dev/null && [[ -s "$tmp" ]]; then
        mv "$tmp" "$CURRENT_ART"
        LAST_URL="$url"
        echo "$CURRENT_ART"
    else
        rm -f "$tmp"
        echo "$DEFAULT_ART"
    fi
}

# Обработка всех типов обложек
process_art() {
    local art="$1"
    local art_path="$DEFAULT_ART"

    if [[ -n "$art" ]]; then
        case "$art" in
            http*|https*)
                art_path=$(download_art "$art")
                ;;
            data:*)
                local tmp="${CURRENT_ART}.tmp"
                rm -f "$tmp"
                # Убираем пробелы/переносы, чтобы base64 не падал
                if printf '%s' "${art#*,}" | tr -d ' \n\r' | base64 -d > "$tmp" 2>/dev/null && [[ -s "$tmp" ]]; then
                    mv "$tmp" "$CURRENT_ART"
                    art_path="$CURRENT_ART"
                    LAST_URL="cached"
                else
                    rm -f "$tmp"
                fi
                ;;
            file://*)
                local raw="${art#file://}"
                art_path=$(printf '%b' "${raw//%/\\x}")
                [[ ! -f "$art_path" ]] && art_path="$DEFAULT_ART"
                ;;
        esac
    fi
    echo "$art_path"
}

# Основной обработчик с debounce и детектом смены трека
get_and_output() {
    # Debounce: не чаще 1 раза в секунду (убирает "колдаёб" при быстрых событиях)
    (( SECONDS < COOLDOWN )) && return

    if ! playerctl status &>/dev/null; then
        local out
        out=$(generate_json "" "" "$DEFAULT_ART" "Stopped")
        [[ "$out" != "$LAST_OUTPUT" ]] && { echo "$out"; LAST_OUTPUT="$out"; }
        COOLDOWN=$(( SECONDS + 1 ))
        return
    fi

    local fmt='{{status}}␞{{artist}}␞{{title}}␞{{mpris:artUrl}}␞{{mpris:trackid}}'
    local meta
    meta=$(playerctl metadata --format "$fmt" 2>/dev/null) || return

    IFS='␞' read -r status artist title art track_id <<< "$meta"

    # Детект смены трека в плейлисте
    if [[ "$track_id" != "$LAST_TRACK_ID" ]]; then
        LAST_TRACK_ID="$track_id"
        LAST_URL=""
        rm -f "$CURRENT_ART"  # сброс кэша, чтобы подтянуть новую обложку
    fi

    [[ -z "$status" ]] && status="Stopped"
    local art_path
    art_path=$(process_art "$art")

    local out
    out=$(generate_json "$artist" "$title" "$art_path" "$status")
    if [[ "$out" != "$LAST_OUTPUT" ]]; then
        echo "$out"
        LAST_OUTPUT="$out"
    fi
    COOLDOWN=$(( SECONDS + 1 ))
}

# Первичный вывод
get_and_output

# Мониторинг через process substitution (нет subshell, переменные сохраняются)
while IFS='␞' read -r status artist title art track_id; do
    get_and_output
done < <(playerctl --follow metadata --format '{{status}}␞{{artist}}␞{{title}}␞{{mpris:artUrl}}␞{{mpris:trackid}}' 2>/dev/null)
