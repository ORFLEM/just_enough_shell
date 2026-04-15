#!/bin/sh

if [ "$XDG_CURRENT_DESKTOP" == "sway" ]; then
    swaymsg exit
elif [ "$XDG_CURRENT_DESKTOP" == "hyprland" ]; then
    hyprctl dispatch exit
elif [ "$XDG_CURRENT_DESKTOP" == "zwm" ]; then
    zwmctl exit
else
    echo "Неизвестный композитор или запущен из TTY"
fi
