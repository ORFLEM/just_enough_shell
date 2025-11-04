#!/bin/sh
DEFAULT_ART="$HOME/.config/eww/bar/images/music.png"
LAST_OUTPUT=""

generate_json() {
    local artist="$1" title="$2" art="$3" player_status="$4"
    if [ "$player_status" = "Playing" ]; then
        button_icon="󰏤"
    else
        button_icon="󰐊"
    fi
    printf '{"artist":"%s","title":"%s","art":"%s","status":"%s"}\n' "$artist" "$title" "$art" "$button_icon"
}

get_current_track() {
    local player_status=$(playerctl status 2>/dev/null || echo "Stopped")
    local metadata=$(playerctl metadata --format '{{artist}}␞{{title}}␞{{mpris:artUrl}}' 2>/dev/null || echo "␞␞")
    IFS="␞" read -r artist title art <<< "$metadata"
    
    local art_path="${art#file://}"
    [ -z "$art_path" ] && art_path="$DEFAULT_ART"
    [ -z "$artist" ] && artist=""
    [ -z "$title" ] && title=""
    
    generate_json "$artist" "$title" "$art_path" "$player_status"
}

# Первичный вывод при запуске скрипта
LAST_OUTPUT=$(get_current_track)
echo "$LAST_OUTPUT"

# Точный мониторинг: только MPRIS Player changes (status/track)
dbus-monitor --session "interface='org.freedesktop.DBus.Properties',member='PropertiesChanged',arg0='org.mpris.MediaPlayer2.Player'" |
    while IFS= read -r line; do
        # Парсим, если есть MPRIS path (игнор других)
        if echo "$line" | grep -q "/org/mpris/MediaPlayer2"; then
            current_output=$(get_current_track)
            if [ "$current_output" != "$LAST_OUTPUT" ]; then
                echo "$current_output"
                LAST_OUTPUT="$current_output"
            fi
        fi
    done
