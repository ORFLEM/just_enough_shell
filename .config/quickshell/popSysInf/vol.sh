#!/bin/sh

oldvol="0"
oldout=""
last_change_time=0

volinf() {
    pamixer --get-volume
}

get_current_time() {
    date +%s
}

while true; do
    muted=$(pamixer --get-mute) 
    vol="$(volinf)"
    current_time=$(get_current_time)
    
    if [ "$muted" = "true" ] || [ "$vol" -eq 0 ]; then
        sign=""
        volout="muted"
    elif [ "$vol" -le 35 ]; then
        sign=""
        volout="$vol"
    elif [ "$vol" -le 70 ]; then
        sign=""
        volout="$vol"
    else
        sign=""
        volout="$vol"
    fi

    if [ -n "$volout" ] && [ "$volout" != "$oldout" ]; then
        printf '{"sign":"%s","vol":"%s"}\n' "$sign" "$volout"
        oldout="$volout"
    fi
   
    sleep 0.05
done
