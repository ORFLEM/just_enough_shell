#!/bin/sh

current=$(swaymsg -t get_workspaces | jq -r '.[] | select(.focused == true) | .num')

case "$1" in
    next)
        next=$((current % 10 + 1))
        swaymsg workspace number $next
        ;;
    prev)
        prev=$(( current == 1 ? 10 : current - 1 ))
        swaymsg workspace number $prev
        ;;
    move-next)
        next=$((current % 10 + 1))
        swaymsg move container to workspace number $next
        swaymsg workspace number $next
        ;;
    move-prev)
        prev=$(( current == 1 ? 10 : current - 1 ))
        swaymsg move container to workspace number $prev
        swaymsg workspace number $prev
        ;;
    *)
        echo "Usage: $0 {next|prev|move-next|move-prev}"
        exit 1
        ;;
esac
