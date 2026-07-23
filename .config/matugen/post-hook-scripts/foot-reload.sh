#!/usr/bin/env bash

FOOT_CONFIG="$HOME/.config/foot/foot.ini"
SECTION="colors-dark"

# --- Функция извлечения цвета ---
get_color() {
    local key="$1"
    awk -F'=' -v section="$SECTION" -v key="$key" '
        $0 == "[" section "]" { in_section=1; next }
        /^\[/ { in_section=0 }
        in_section && $1 == key {
            gsub(/^[[:space:]]+|[[:space:]]+$/, "", $2)
            gsub(/^"|"$/, "", $2)
            if ($2 !~ /^#/ && $2 !~ /^[[:space:]]*$/) {
                $2 = "#" $2
            }
            print $2
            exit
        }
    ' "$FOOT_CONFIG"
}

# --- Функция отправки команды во все доступные TTY ---
send_cmd() {
    local cmd="$1"
    for tty in /dev/pts/*; do
        if [[ -w "$tty" ]]; then
            # Используем printf без форматирования, просто выводим строку как есть
            printf "%b" "$cmd" > "$tty"
        fi
    done
}

# --- Отправляем все цвета ---

# 0-7: regular
for i in {0..7}; do
    color=$(get_color "regular$i")
    [[ -n "$color" ]] && send_cmd "\033]4;$i;${color}\033\\"
done

# 8-15: bright
for i in {0..7}; do
    color=$(get_color "bright$i")
    [[ -n "$color" ]] && send_cmd "\033]4;$((i+8));${color}\033\\"
done

# фон и текст
bg=$(get_color "background")
fg=$(get_color "foreground")
[[ -n "$bg" ]] && send_cmd "\033]11;${bg}\033\\"
[[ -n "$fg" ]] && send_cmd "\033]10;${fg}\033\\"

echo "Цвета обновлены во всех терминалах."
