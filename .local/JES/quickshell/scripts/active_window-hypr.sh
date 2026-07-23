#!/bin/sh

last_aw=""

while true; do

	aw=$(hyprctl activewindow | grep 'initialTitle' | cut -d' ' -f2-)

	if [ "$aw" == "" ]; then
		aw=""
	fi

	if [ "$aw" != "$last_aw" ]; then
		echo "$aw"
		last_aw="$aw"
	fi

	sleep 0.05
done

