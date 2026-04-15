#!/bin/sh

last_aw=""

while true; do
	# niri msg -j windows возвращает JSON с информацией о всех окнах
	# is_focused: true показывает активное окно
	aw=$(niri msg -j windows | jq -r '.[] | select(.is_focused == true) | .title // ""')

	if [ -z "$aw" ]; then
		aw=""
	fi

	if [ "$aw" != "$last_aw" ]; then
		echo "$aw"
		last_aw="$aw"
	fi

	sleep 0.05
done
