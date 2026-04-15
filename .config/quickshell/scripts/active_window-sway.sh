#!/bin/sh

get_app_name() {
    swaymsg -t get_tree | jq -r '
        .. | select(.focused? == true) | 
        .app_id // .window_properties.class // .name // ""
    ' | sed -E 's/^(org\.|app\.)//' | sed 's/\.desktop$//' | sed 's/.*\.//;s/_/ /g'
}

echo "$(get_app_name)"

swaymsg -t subscribe -m '["window"]' | while read -r event; do
    change=$(echo "$event" | jq -r '.change // ""')
    
    if [ "$change" = "focus" ]; then
        app=$(echo "$event" | jq -r '.container.app_id // .container.window_properties.class // .container.name // ""' | \
              sed -E 's/^(org\.|app\.)//' | sed 's/\.desktop$//' | sed 's/.*\.//;s/_/ /g')
        echo "${app:-}"
    fi
done
