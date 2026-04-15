#! /bin/sh

last_focused_id=""

swaymsg -t subscribe -m '["window"]' | while read -r line; do
    # Получить ID и app_id сфокусированного окна
    focused_id=$(swaymsg -t get_tree | jq -r '.. | select(.focused? == true) | .id')
    focused_app=$(swaymsg -t get_tree | jq -r '.. | select(.focused? == true) | (.app_id // .window_properties.class // "")')
    
    # Если фокус не изменился - пропускаем
    if [ "$focused_id" = "$last_focused_id" ]; then
        continue
    fi
    
    # Не трогаем eww и rofi
    case "$focused_app" in
        eww|rofi)
            last_focused_id="$focused_id"
            continue
            ;;
    esac
    
    last_focused_id="$focused_id"
    
    # Получить все ID окон и установить opacity - ИСПРАВЛЕНО
    swaymsg -t get_tree | jq -r '.. | select(.type? == "con") | select(.id?) | "\(.id)|\(.app_id // .window_properties.class // "")"' | while IFS='|' read -r id app; do
        
        case "$app" in
            eww|rofi)
                continue
                ;;
        esac
        
        if [ "$id" = "$focused_id" ]; then
            swaymsg "[con_id=$id] opacity 0.85" > /dev/null
        else
            swaymsg "[con_id=$id] opacity 0.45" > /dev/null
        fi
    done
done
