#!/bin/sh

if [ -n "$SWAYSOCK" ]; then
    swaymsg exit
elif [ -n "$HYPRLAND_INSTANCE_SIGNATURE" ]; then
    hyprctl dispatch exit
else
    echo "Неизвестный композитор или запущен из TTY"
fi
