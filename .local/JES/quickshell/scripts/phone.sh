#! /usr/bin/env bash

prev_json=""

while true; do
  # Получаем имя и ID первого подключённого устройства (берём первый элемент)
  name=$(kdeconnect-cli -a --name-only 2>/dev/null | head -n1)
  id=$(kdeconnect-cli -a --id-only 2>/dev/null | head -n1)
  
  if [[ -z "$id" ]]; then
    # Если устройство не найдено – выводим null
    current_json='{"name":"null","charge":null,"isCharging":null,"icon":null}'
  else
    # Получаем заряд и статус зарядки через dbus
    charge=$(dbus-send --print-reply --dest=org.kde.kdeconnect /modules/kdeconnect/devices/$id/battery org.freedesktop.DBus.Properties.Get string:org.kde.kdeconnect.device.battery string:charge | grep "int32" | awk '{print $3}')
    ch_stat=$(dbus-send --print-reply --dest=org.kde.kdeconnect /modules/kdeconnect/devices/$id/battery org.freedesktop.DBus.Properties.Get string:org.kde.kdeconnect.device.battery string:isCharging | grep "boolean" | awk '{print $3}')

    # Выбор иконки (как в оригинале)
    stat=""
    if [[ $charge -lt 20 && $ch_stat == "true" ]]; then
      stat="󰢜"
    elif [[ $charge -lt 30 && $ch_stat == "true" ]]; then
      stat="󰂆"
    elif [[ $charge -lt 40 && $ch_stat == "true" ]]; then
      stat="󰂇"
    elif [[ $charge -lt 50 && $ch_stat == "true" ]]; then
      stat="󰂈"
    elif [[ $charge -lt 60 && $ch_stat == "true" ]]; then
      stat="󰢝"
    elif [[ $charge -lt 70 && $ch_stat == "true" ]]; then
      stat="󰂉"
    elif [[ $charge -lt 80 && $ch_stat == "true" ]]; then
      stat="󰢞"
    elif [[ $charge -lt 90 && $ch_stat == "true" ]]; then
      stat="󰂊"
    elif [[ $charge -lt 100 && $ch_stat == "true" ]]; then
      stat="󰂋"
    elif [[ $charge == 100 && $ch_stat == "true" ]]; then
      stat="󰂅"
    elif [[ $charge -lt 20 && $ch_stat == "false" ]]; then
      stat="󰁺"
    elif [[ $charge -lt 30 && $ch_stat == "false" ]]; then
      stat="󰁻"
    elif [[ $charge -lt 40 && $ch_stat == "false" ]]; then
      stat="󰁼"
    elif [[ $charge -lt 50 && $ch_stat == "false" ]]; then
      stat="󰁽"
    elif [[ $charge -lt 60 && $ch_stat == "false" ]]; then
      stat="󰁾"
    elif [[ $charge -lt 70 && $ch_stat == "false" ]]; then
      stat="󰁿"
    elif [[ $charge -lt 80 && $ch_stat == "false" ]]; then
      stat="󰂀"
    elif [[ $charge -lt 90 && $ch_stat == "false" ]]; then
      stat="󰂁"
    elif [[ $charge -lt 100 && $ch_stat == "false" ]]; then
      stat="󰂂"
    elif [[ $charge == 100 && $ch_stat == "false" ]]; then
      stat="󰁹"
    fi

    # Экранируем двойные кавычки в имени (на случай, если имя содержит кавычки)
    name_escaped=$(printf "%s" "$name" | sed 's/"/\\"/g')

    # Формируем JSON с помощью printf
    current_json=$(printf '{"name":"%s","charge":%d,"isCharging":%s,"icon":"%s"}' \
      "$name_escaped" \
      "$charge" \
      "$ch_stat" \
      "$stat")
  fi

  # Выводим только при изменении состояния
  if [[ "$current_json" != "$prev_json" ]]; then
    echo "$current_json"
    prev_json="$current_json"
  fi

  sleep 1
done
