#!/bin/sh

while true; do
    vol=$(pamixer --get-volume)
    muted=$(pamixer --get-mute)
    
    if [ "$muted" = "true" ] || [ "$vol" -eq 0 ]; then
        sign=""
        volout="muted"
    elif [ "$vol" -le 35 ]; then
        sign=""
        volout="$vol%"
    elif [ "$vol" -le 70 ]; then
        sign=""
        volout="$vol%"
    else
        sign=""
        volout="$vol%"
    fi

    printf '{"sign":"%s","vol":"%s"}\n' "$sign" "$volout"
    sleep 0.05
done

