#!/bin/sh
CACHE_FILE="/tmp/eww_weather_cache.json"
CACHE_TIMEOUT=600  # 10 минут

# Иконки погоды
get_icon() {
    case $1 in
        01d) echo "";;   # clear sky day
        01n) echo "";;   # clear sky night
        02d|02n) echo "";; # few clouds
        03*|04*) echo "󰖐";; # clouds
        09*) echo "󰖖";;   # shower rain
        10d) echo "";;   # rain day
        10n) echo "";;   # rain night
        11*) echo "󰖓";;   # thunderstorm
        13*) echo "󰼶";;   # snow
        50*) echo "";;   # mist
        *) echo "";;     # default
    esac
}

# Получение данных о погоде
get_weather_data() {
    local KEY="e434b5435a979de6e155570590bee89b"
    local CITY="Tomsk"
    local API="https://api.openweathermap.org/data/2.5"

    # Текущая погода
    local current
    current=$(curl -sf --max-time 10 "$API/weather?appid=$KEY&q=$CITY&units=metric&lang=ru") || return 1

    local temp feels humidity pressure wind icon_code icon desc
    temp=$(echo "$current" | jq -r '.main.temp | round')
    feels=$(echo "$current" | jq -r '.main.feels_like | round')
    humidity=$(echo "$current" | jq -r '.main.humidity')
    pressure=$(echo "$current" | jq -r '.main.pressure / 1.333 | round')
    wind=$(echo "$current" | jq -r '.wind.speed | round')
    icon_code=$(echo "$current" | jq -r '.weather[0].icon')
    icon=$(get_icon "$icon_code")
    desc=$(echo "$current" | jq -r '.weather[0].description | ascii_upcase')

    # Прогноз (берём каждый день в 12:00:00)
        # Прогноз (берём каждый день в 12:00:00)
    local forecast_raw
    forecast_raw=$(curl -sf --max-time 10 "$API/forecast?appid=$KEY&q=$CITY&units=metric&lang=ru" \
      | jq '
        .list
        | map(select(.dt_txt | contains("12:00:00")))
        | .[0:7]
        | map({
            day: ( .dt_txt | strptime("%Y-%m-%d %H:%M:%S") | strftime("%a") ),
            min: (.main.temp_min | round),
            max: (.main.temp_max | round),
            icon_code: ( .weather[0].icon ),
            desc: ( .weather[0].description )
          })
      ') || forecast_raw="[]"

    # Теперь конвертим icon_code → icon с помощью get_icon
    local forecast
    forecast=$(echo "$forecast_raw" | jq -c '.[]' | while read -r item; do
        code=$(echo "$item" | jq -r '.icon_code')
        glyph=$(get_icon "$code")
        echo "$item" | jq --arg glyph "$glyph" '. + {icon: $glyph}'
    done | jq -s '.')

    # Когда обновилось
    updated=$(date '+%H:%M')

    # Формируем JSON итоговый
    jq -n \
        --arg temp "$temp" \
        --arg feels "$feels" \
        --arg humidity "$humidity" \
        --arg pressure "$pressure" \
        --arg wind "$wind" \
        --arg icon "$icon" \
        --arg desc "$desc" \
        --arg updated "$updated" \
        --argjson forecast "$forecast" \
        '{
            temp: $temp,
            feels: $feels,
            humidity: $humidity,
            pressure: $pressure,
            wind: $wind,
            icon: $icon,
            desc: $desc,
            updated: $updated,
            forecast: $forecast
        }'
}

# Кэширование
update_cache() {
    local data
    data=$(get_weather_data)
    [ -z "$data" ] && return 1
    echo "$data" > "$CACHE_FILE"
    echo "$data"
}

# Проверяем кэш
if [ -f "$CACHE_FILE" ]; then
    cache_age=$(($(date +%s) - $(stat -c %Y "$CACHE_FILE")))
    if [ "$cache_age" -lt "$CACHE_TIMEOUT" ]; then
        cat "$CACHE_FILE"
    else
        update_cache
    fi
else
    update_cache
fi
