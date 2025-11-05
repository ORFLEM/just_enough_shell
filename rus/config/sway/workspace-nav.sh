#!/bin/sh

# Получаем текущий воркспейс
current=$(swaymsg -t get_workspaces | jq -r '.[] | select(.focused == true) | .num')

case "$1" in
    "next")
        next=$((current + 1))
        [ $next -gt 10 ] && next=1
        swaymsg workspace number $next
        ;;
    "prev")
        prev=$((current - 1))
        [ $prev -lt 1 ] && prev=10
        swaymsg workspace number $prev
        ;;
	"move-next")
        next=$((current + 1))
        [ $next -gt 10 ] && next=1
        swaymsg move container to workspace $next
        swaymsg workspace number $next
        ;;
    "move-prev")
        prev=$((current - 1))
        [ $prev -lt 1 ] && prev=10
        swaymsg move container to workspace $prev
        swaymsg workspace number $prev
        ;;
    *)
        echo "Usage: $0 {next|prev}"
        exit 1
        ;;
esac

