#!/usr/bin/env bash

# --- Функции получения текущих значений ---
get_volume() {
    pamixer --get-volume
}

get_mute() {
    pamixer --get-mute
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

# --- Основной цикл с подпиской на события PulseAudio ---
# Используем process substitution, чтобы все переменные сохранялись в текущей оболочке
while read -r event; do
    # Фильтруем события: нас интересуют изменения громкости (sink) или переключение сервера
    if [[ "$event" =~ (sink|server) ]]; then
        # Небольшая задержка, чтобы изменение точно успело примениться
        sleep 0.1
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
done < <(pactl subscribe 2>/dev/null)
