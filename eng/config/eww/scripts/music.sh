#!/bin/sh
DEFAULT_ART="$HOME/.config/eww/bar/images/music.png"
CACHE_DIR="$HOME/.cache/eww_music_art"
CURRENT_ART="$CACHE_DIR/current_art.jpg"
LAST_OUTPUT=""

# Создаем директорию для кэша обложек
mkdir -p "$CACHE_DIR"

generate_json() {
    local artist="$1" title="$2" art="$3" player_status="$4"
    if [ "$player_status" = "Playing" ]; then
        button_icon="󰏤"
    else
        button_icon="󰐊"
    fi
    printf '{"artist":"%s","title":"%s","art":"%s","status":"%s"}\n' "$artist" "$title" "$art" "$button_icon"
}

download_art() {
    local url="$1"
    
    # Удаляем предыдущую обложку
    rm -f "$CURRENT_ART"
    
    if [ -z "$url" ]; then
        echo "$DEFAULT_ART"
        return
    fi
    
    # Скачиваем новую обложку
    if curl -s -L "$url" -o "$CURRENT_ART" 2>/dev/null && [ -f "$CURRENT_ART" ]; then
        echo "$CURRENT_ART"
    else
        echo "$DEFAULT_ART"
    fi
}

get_current_track() {
    # Проверяем, есть ли активный плеер
    if ! playerctl status 2>/dev/null >/dev/null; then
        # Нет активного плеера - возвращаем пустые данные
        generate_json "" "" "$DEFAULT_ART" "Stopped"
        return
    fi
    
    local player_status=$(playerctl status 2>/dev/null || echo "Stopped")
    local metadata=$(playerctl metadata --format '{{artist}}␞{{title}}␞{{mpris:artUrl}}' 2>/dev/null || echo "␞␞")
    IFS="␞" read -r artist title art <<< "$metadata"
    
    # Обрабатываем обложку
    local art_path="$DEFAULT_ART"
    if [ -n "$art" ]; then
        if [[ "$art" == http* ]]; then
            # Это URL - скачиваем обложку
            art_path=$(download_art "$art")
        else
            # Локальный файл
            art="${art#file://}"
            art_path=$(printf '%b' "${art//%/\\x}")
            [ ! -f "$art_path" ] && art_path="$DEFAULT_ART"
        fi
    fi
    
    [ -z "$artist" ] && artist=""
    [ -z "$title" ] && title=""
    
    generate_json "$artist" "$title" "$art_path" "$player_status"
}

# Первичный вывод при запуске скрипта
LAST_OUTPUT=$(get_current_track)
echo "$LAST_OUTPUT"

# Мониторинг изменений плеера через playerctl
playerctl --follow metadata --format '{{status}}␞{{artist}}␞{{title}}␞{{mpris:artUrl}}' 2>/dev/null |
    while IFS="␞" read -r status artist title art; do
        # Проверяем, есть ли активный плеер
        if ! playerctl status 2>/dev/null >/dev/null; then
            current_output=$(generate_json "" "" "$DEFAULT_ART" "Stopped")
        else
            # Обрабатываем обложку
            local art_path="$DEFAULT_ART"
            if [ -n "$art" ]; then
                if [[ "$art" == http* ]]; then
                    # Это URL - скачиваем обложку
                    art_path=$(download_art "$art")
                else
                    # Локальный файл
                    art="${art#file://}"
                    art_path=$(printf '%b' "${art//%/\\x}")
                    [ ! -f "$art_path" ] && art_path="$DEFAULT_ART"
                fi
            fi
            
            [ -z "$artist" ] && artist=""
            [ -z "$title" ] && title=""
            current_output=$(generate_json "$artist" "$title" "$art_path" "$status")
        fi
        
        if [ "$current_output" != "$LAST_OUTPUT" ]; then
            echo "$current_output"
            LAST_OUTPUT="$current_output"
        fi
    done
