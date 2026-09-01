#!/usr/bin/env bash
# brightness.sh — универсальное управление яркостью (внутренние + внешние мониторы)

set -euo pipefail

PID_FILE="/tmp/brightness_stream.pid"
MONITOR_METHODS=()     # "internal" (brightnessctl) или "external" (ddcutil)
MONITOR_IDENTIFIERS=() # имя устройства (e.g. intel_backlight) или номер шины
MONITOR_NAMES=()       # Имя интерфейса для вывода

# --- Сбор данных обо всех дисплеях ---
init_monitors() {
  # 1. Поиск встроенных дисплеев для brightnessctl
  for bl in /sys/class/backlight/*; do
    if [[ -d "$bl" ]]; then
      local bl_name="${bl##*/}"
      MONITOR_METHODS+=("internal")
      MONITOR_IDENTIFIERS+=("$bl_name")
      MONITOR_NAMES+=("$bl_name")
    fi
  done

  # 2. Поиск внешних мониторов для ddcutil через sysfs
  local link bus conn target card
  for link in /sys/bus/i2c/devices/i2c-*; do
    [ -L "$link" ] || continue
    bus="${link##*/i2c-}"
    target="$(readlink "$link")"

    if [[ "$target" =~ (card[0-9]+)-([A-Za-z0-9-]+)/i2c- ]]; then
      card="${BASH_REMATCH[1]}"
      conn="${BASH_REMATCH[2]}"

      if [[ -f "/sys/class/drm/${card}-${conn}/status" ]]; then
        if [[ "$(<"/sys/class/drm/${card}-${conn}/status")" == "connected" ]]; then
          # Пропускаем внутренние, так как они уже собраны через backlight
          if [[ "$conn" =~ ^(eDP|LVDS) ]]; then
            continue
          fi
          MONITOR_METHODS+=("external")
          MONITOR_IDENTIFIERS+=("$bus")
          MONITOR_NAMES+=("$conn")
        fi
      fi
    fi
  done

  if [[ ${#MONITOR_NAMES[@]} -eq 0 ]]; then
    echo "❌ Активные мониторы не найдены" >&2
    exit 1
  fi
}

init_monitors

get_brightness() {
  local method="$1"
  local id="$2"

  if [[ "$method" == "internal" ]]; then
    brightnessctl -d "$id" i -m 2>/dev/null | awk -F, '{print $4}' | tr -d '%' || echo ""
  else
    ddcutil -t getvcp 10 --bus "$id" 2>/dev/null | awk '{print $4}' || echo ""
  fi
}

find_targets_for_monitor() {
  local target_monitor="${1:-}"
  local found_indices=()

  if [[ -z "$target_monitor" ]]; then
    for i in "${!MONITOR_NAMES[@]}"; do echo "$i"; done
    return 0
  fi

  for i in "${!MONITOR_NAMES[@]}"; do
    if [[ "${MONITOR_NAMES[$i]}" == "$target_monitor" ]]; then
      found_indices+=("$i")
    fi
  done

  if [[ ${#found_indices[@]} -eq 0 ]]; then
    echo "❌ Монитор '$target_monitor' не найден." >&2
    exit 1
  fi

  for idx in "${found_indices[@]}"; do echo "$idx"; done
}

# --- Триггер обновления для stream ---
notify_stream() {
  if [[ -f "$PID_FILE" ]]; then
    local pid
    pid=$(cat "$PID_FILE" 2>/dev/null || echo "")
    if [[ -n "$pid" ]] && kill -0 "$pid" 2>/dev/null; then
      kill -USR1 "$pid" 2>/dev/null || true
    fi
  fi
}

# --- Основной цикл stream ---
stream() {
  echo "$$" >"$PID_FILE"
  trap 'rm -f "$PID_FILE"; exit 0' EXIT INT TERM

  declare -A last_values
  for i in "${!MONITOR_NAMES[@]}"; do
    last_values["$i"]=""
  done

  FORCE_UPDATE=0
  trap 'FORCE_UPDATE=1' USR1

  while true; do
    for i in "${!MONITOR_NAMES[@]}"; do
      method="${MONITOR_METHODS[$i]}"
      id="${MONITOR_IDENTIFIERS[$i]}"
      val=$(get_brightness "$method" "$id")

      if [[ -n "$val" && "$val" =~ ^[0-9]+$ ]]; then
        if [[ "$val" != "${last_values[$i]}" || "$FORCE_UPDATE" -eq 1 ]]; then
          if ((val <= 25)); then
            sign="󰃞"
          elif ((val <= 50)); then
            sign="󰃟"
          elif ((val <= 75)); then
            sign="󰃝"
          else sign="󰃠"; fi

          stdbuf -oL printf '{"sign":"%s","bright":"%s","monitor":"%s"}\n' "$sign" "$val" "${MONITOR_NAMES[$i]}"
          last_values["$i"]="$val"
        fi
      fi
    done
    FORCE_UPDATE=0

    sleep 1 &
    wait $! 2>/dev/null || true
  done
}

action_change_step() {
  local direction="$1"
  local target_monitor="${2:-}"

  mapfile -t target_indices < <(find_targets_for_monitor "$target_monitor")

  for i in "${target_indices[@]}"; do
    method="${MONITOR_METHODS[$i]}"
    id="${MONITOR_IDENTIFIERS[$i]}"

    if [[ "$method" == "internal" ]]; then
      brightnessctl -d "$id" set "5%${direction}" -q &
    else
      ddcutil --bus "$id" setvcp 10 "$direction" 5 2>/dev/null &
    fi
  done
  wait
  notify_stream
}

action_set() {
  local val="$1"
  local target_monitor="${2:-}"

  if [[ ! "$val" =~ ^[0-9]+$ ]] || ((val < 0 || val > 100)); then
    echo "❌ Значение яркости должно быть числом от 0 до 100" >&2
    exit 1
  fi

  mapfile -t target_indices < <(find_targets_for_monitor "$target_monitor")

  for i in "${target_indices[@]}"; do
    method="${MONITOR_METHODS[$i]}"
    id="${MONITOR_IDENTIFIERS[$i]}"

    if [[ "$method" == "internal" ]]; then
      brightnessctl -d "$id" set "${val}%" -q &
    else
      ddcutil --bus "$id" setvcp 10 "$val" 2>/dev/null &
    fi
  done
  wait
  notify_stream
}

action_get() {
  local target_monitor="${1:-}"

  if [[ -n "$target_monitor" ]]; then
    local i
    i=$(find_targets_for_monitor "$target_monitor" | head -n 1)
    local val
    val=$(get_brightness "${MONITOR_METHODS[$i]}" "${MONITOR_IDENTIFIERS[$i]}")
    echo "${val:-ERR}"
  else
    for i in "${!MONITOR_NAMES[@]}"; do
      local val
      val=$(get_brightness "${MONITOR_METHODS[$i]}" "${MONITOR_IDENTIFIERS[$i]}")
      echo "${MONITOR_NAMES[$i]}: ${val:-ERR}%"
    done
  fi
}

COMMAND="${1:-}"

case "$COMMAND" in
stream) stream ;;
brightness-up) action_change_step "+" "${2:-}" ;;
brightness-down) action_change_step "-" "${2:-}" ;;
brightness-set)
  if [[ -z "${2:-}" ]]; then
    echo "Использование: $0 brightness-set <0-100> [monitor]" >&2
    exit 1
  fi
  action_set "$2" "${3:-}"
  ;;
brightness-get) action_get "${2:-}" ;;
*)
  echo "Использование: $0 {stream | brightness-up [mon] | brightness-down [mon] | brightness-set <0-100> [mon] | brightness-get [mon]}" >&2
  exit 1
  ;;
esac
