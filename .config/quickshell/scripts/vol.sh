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

    newvol="$(volinf)"
    if [ "$oldvol" != "$newvol" ]; then
        oldvol="$newvol"
        eww update rvol="true"
        last_change_time=$current_time
    fi
    
    time_diff=$((current_time - last_change_time))
    if [ $last_change_time -gt 0 ] && [ $time_diff -ge 2 ]; then
        eww update rvol="false"
        last_change_time=0
    fi
    
    sleep 0.05
done
