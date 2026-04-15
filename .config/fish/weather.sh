#!/usr/bin/fish

# Получаем данные
set -l location (curl -s "http://ip-api.com/json" | jq -r ".city")
set -l weather_data (curl -s "wttr.in/$location?format=%c+%t+%h+%w+%m&lang=ru")

# Парсим данные
set -l icon (echo $weather_data | awk '{print $1}')
set -l temp (echo $weather_data | awk '{print $2}')
set -l humidity (echo $weather_data | awk '{print $3}')
set -l wind (echo $weather_data | awk '{print $4}')

# Nerd Font иконки
set -l nerd_icons
switch $icon
    case "☀️"  # Солнце
        set nerd_icons ""
    case "☁️"  # Облака
        set nerd_icons ""
    case ""  # Дождь
        set nerd_icons ""
    case "❄️"  # Снег
        set nerd_icons ""
    case "*"
        set nerd_icons ""
end

# Выводим интерфейс
echo "╭───────────────────────────────╮"
echo "│    E.W.USB    󱣶  $nerd_icons      │"
echo "│  󰺻  Poststaff   $wind      │"
echo "│  󱗺  WindCore    $temp    │"
echo "│  󰻾  ID P4:04    $humidity  │"
echo "╰───────────────────────────────╯"
echo ""
echo "╭────[  WEATHER STATION @ $location ]───╮"
echo "│                                        │"
echo "│    Condition:   $nerd_icons $icon     │"
echo "│    Temperature: $temp                 │"
echo "│    Humidity:    $humidity             │"
echo "│    Wind:        $wind                 │"
echo "│                                        │"
echo "╰────────────────────────────────────────╯"

