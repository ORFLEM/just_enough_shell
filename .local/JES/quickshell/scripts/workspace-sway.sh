#!/bin/sh
# Настраиваемые иконки
: "${ICON_ACTIVE:=}"
: "${ICON_URGENT:=}"
: "${ICON_OCCUPIED:=}"
: "${ICON_EMPTY:=}"
export ICON_ACTIVE ICON_URGENT ICON_OCCUPIED ICON_EMPTY

# Весь JSON одним swaymsg + одним jq. index() вместо grep по каждому id.
generate_json() {
    swaymsg -t get_workspaces 2>/dev/null | jq -c --unbuffered '
        ([ .[].num ])                                  as $nums
        | ([ .[] | select(.focused) | .num ] | first // 1) as $active
        | ([ .[] | select(.urgent)  | .num ])          as $urgent
        | ([ .[].num ] | max // 10)                    as $maxRaw
        | (if $maxRaw < 10 then 10 else $maxRaw end)   as $max
        | reduce range(1; $max + 1) as $i ({};
            .["ws\($i)"] =
                if ($urgent | index($i)) then { class: "urgent",    icon: ($ENV.ICON_URGENT   // "") }
                elif $i == $active       then { class: "active",    icon: ($ENV.ICON_ACTIVE   // "") }
                elif ($nums | index($i))  then { class: "occupied",  icon: ($ENV.ICON_OCCUPIED // "") }
                else                           { class: "empty",     icon: ($ENV.ICON_EMPTY    // "") }
                end)
    '
}

# Потоковый вывод с подпиской, дебаунсом (80 мс) и дедупликацией
stream_workspaces_json() {
    prev=""
    out=$(generate_json)
    [ -n "$out" ] && { echo "$out"; prev="$out"; }

    swaymsg -t subscribe -m '["workspace","window"]' 2>/dev/null |
    while read -r event; do
        change=$(printf '%s' "$event" | jq -r '.change // ""')
        case "$change" in
            focus|init|empty|move|urgent|reload) ;;
            *) continue ;;
        esac
        # Дебаунс: склеиваем серии событий (move шлёт их пачками)
        sleep 0.08
        while read -t 0.05 -r _; do :; done
        out=$(generate_json)
        [ -n "$out" ] && [ "$out" != "$prev" ] && { echo "$out"; prev="$out"; }
    done
}

# Основная логика
case "$1" in
    "stream-ws-json")
        stream_workspaces_json
        ;;
    "change-ws")
        [ -n "$2" ] && swaymsg workspace number "$2" >/dev/null 2>&1
        ;;
    "--help")
        echo "Usage: $0 {--help | stream-ws-json | change-ws}"
        echo "commands:"
        echo "   stream-ws-json   -> show information about your workspaces (active|occupied|empty|urgent)"
        echo "   change-ws...     -> changing your active workspace on other workspace (use number other ws)"
        ;;
    *)
        echo "Usage: $0 {stream-ws-json | change-ws}"
        exit 1
        ;;
esac
