#!/usr/bin/env bash

# === Получаем радиус ===
if [ -n "$1" ]; then
    TARGET_RAD="$1"
else
    TARGET_RAD=$(grep -oP 'mainRad\s*=\s*\K\d+' ~/.config/JES/config.toml 2>/dev/null)
fi

if [[ -z "$TARGET_RAD" || ! "$TARGET_RAD" =~ ^[0-9]+$ ]]; then
    echo "❌ Не удалось получить mainRad"
    exit 1
fi

echo "Целевой радиус: $TARGET_RAD"

# === Функции применения ===
apply_swayfx() {
    local config="$HOME/.config/sway/config"
    [[ ! -f "$config" ]] && return
    if grep -q '^corner_radius' "$config"; then
        sed -i "s/^corner_radius .*/corner_radius $TARGET_RAD/" "$config"
    else
        echo "corner_radius $TARGET_RAD" >> "$config"
    fi
}

apply_hyprland() {
    local config="$HOME/.config/hypr/hyprland.conf"
    [[ ! -f "$config" ]] && return
    if grep -q '^decoration\s*{' "$config"; then
        if awk '/^decoration\s*{/,/^}/' "$config" | grep -q 'rounding\s*='; then
            sed -i "/^decoration\s*{/,/^}/ s/rounding\s*=.*/rounding = $TARGET_RAD/" "$config"
        else
            sed -i "/^decoration\s*{/a \ \ rounding = $TARGET_RAD" "$config"
        fi
    else
        echo -e "\ndecoration {\n    rounding = $TARGET_RAD\n}" >> "$config"
    fi
}

apply_niri() {
    local config="$HOME/.config/niri/config.kdl"
    [[ ! -f "$config" ]] && return
    if grep -q 'window-rule\s*{' "$config" && grep -q 'geometry-corner-radius' "$config"; then
        sed -i "s/geometry-corner-radius [0-9]*/geometry-corner-radius $TARGET_RAD/" "$config"
    else
        echo -e "\nwindow-rule {\n    geometry-corner-radius $TARGET_RAD\n    clip-to-geometry true\n}" >> "$config"
    fi
}

apply_driftwm() {
    local config="$HOME/.config/driftwm/config.toml"
    [[ ! -f "$config" ]] && return
    if grep -q '^\[decorations\]' "$config"; then
        if grep -A 5 '^\[decorations\]' "$config" | grep -q 'corner_radius\s*='; then
            sed -i "/^\[decorations\]/,/^\[/ s/corner_radius\s*=.*/corner_radius = $TARGET_RAD/" "$config"
        else
            sed -i "/^\[decorations\]/a corner_radius = $TARGET_RAD" "$config"
        fi
    else
        echo -e "\n[decorations]\ncorner_radius = $TARGET_RAD" >> "$config"
    fi
}

# === Применяем ко всем ===
echo "Обновляем конфиги всех WM..."
apply_swayfx
apply_hyprland
apply_niri
apply_driftwm

# === Определяем активный WM и перезагружаем ===
if pgrep -x "sway" >/dev/null 2>&1; then
    echo "Перезагружаем Sway"
    swaymsg reload 2>/dev/null
elif pgrep -x "Hyprland" >/dev/null 2>&1; then
    echo "Перезагружаем Hyprland"
    hyprctl reload 2>/dev/null
elif pgrep -x "niri" >/dev/null 2>&1; then
    echo "Перезагружаем Niri"
    niri-msg reload 2>/dev/null
elif pgrep -x "driftwm" >/dev/null 2>&1; then
    echo "Перезагружаем Driftwm"
else
    echo "Активный WM не найден, перезагрузка не требуется"
fi

echo "Готово!"
