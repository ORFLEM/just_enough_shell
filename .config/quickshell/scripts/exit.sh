#!/bin/sh

if [ "$XDG_CURRENT_DESKTOP" == "sway" ]; then
    swaymsg exit
elif [ "$XDG_CURRENT_DESKTOP" == "Hyprland" ]; then
    hyprctl dispatch exit
elif [ "$XDG_CURRENT_DESKTOP" == "zwm" ]; then
    zwmctl exit
elif [ "$XDG_CURRENT_DESKTOP" == "niri" ]; then
    niri msg action quit
else
    echo "Неизвестный композитор или запущен из TTY"
fi
