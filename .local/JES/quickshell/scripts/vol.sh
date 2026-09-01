#!/usr/bin/env bash

pkill -f pactl

# --- Функции получения текущих значений ---
get_volume() {
    pamixer --get-volume 2>/dev/null
}

get_mute() {
    pamixer --get-mute 2>/dev/null
}

# --- Формирование JSON с иконкой ---
get_output() {
    local vol="$1"
    local mute="$2"
    local sign=""
    local volout=""

    if [[ "$mute" == "true" ]] || [[ "$vol" -eq 0 ]]; then
        sign=""
        volout="muted"
    elif [[ "$vol" -le 35 ]]; then
        sign=""
        volout="$vol"
    elif [[ "$vol" -le 70 ]]; then
        sign=""
        volout="$vol"
    else
        sign=""
        volout="$vol"
    fi

    printf '{"sign":"%s","vol":"%s"}\n' "$sign" "$volout"
}

# --- Первоначальный вывод состояния при старте ---
vol=$(get_volume)
mute=$(get_mute)
old_out=""
if [[ -n "$vol" ]]; then
    output=$(get_output "$vol" "$mute")
    echo "$output"
    old_out="$output"
fi

# --- Основной цикл ---
# Запускаем pactl subscribe в фоновом пайпе и сохраняем его PID
pactl subscribe 2>/dev/null | while read -r event; do
    if [[ "$event" =~ (sink|server) ]]; then
        vol=$(get_volume)
        mute=$(get_mute)
        if [[ -n "$vol" ]]; then
            output=$(get_output "$vol" "$mute")
            if [[ "$output" != "$old_out" ]]; then
                echo "$output"
                old_out="$output"
            fi
        fi
    fi
done &

PA_PID=$!
wait "$PA_PID"
