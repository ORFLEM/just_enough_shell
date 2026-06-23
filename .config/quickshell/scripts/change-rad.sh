#!/usr/bin/env bash

# === Парсим радиус из quickshell config ===
RAD=$(grep mainRad ~/.config/quickshell/config.toml | awk -F ' ' '{print $3}' 2>/dev/null)

if [[ -z "$RAD" || ! "$RAD" =~ ^[0-9]+$ ]]; then
    echo "❌ Не удалось получить mainRad из $QUICKSHELL_CONFIG"
    exit 1
fi

echo "✅ Найден радиус: $RAD"

# === Функция для SwayFX ===
apply_swayfx() {
    local config="$HOME/.config/sway/config"
    if [[ ! -f "$config" ]]; then
        echo "⚠️  Файл $config не найден, пропускаем SwayFX"
        return
    fi
    # Ищем строку corner_radius и заменяем
    if grep -q '^corner_radius' "$config"; then
        sed -i "s/^corner_radius .*/corner_radius $RAD/" "$config"
    else
        echo "corner_radius $RAD" >> "$config"
    fi
    echo "✅ SwayFX: радиус обновлён до $RAD"
    # SwayFX перезагружается автоматически, но можно отправить сигнал
    swaymsg reload 2>/dev/null || true
}

# === Функция для Hyprland ===
apply_hyprland() {
    local config="$HOME/.config/hypr/hyprland.conf"
    if [[ ! -f "$config" ]]; then
        echo "⚠️  Файл $config не найден, пропускаем Hyprland"
        return
    fi
    # Ищем секцию decoration и параметр rounding
    if grep -q '^decoration\s*{' "$config"; then
        # Если rounding уже есть в секции — заменяем
        if awk '/^decoration\s*{/,/^}/' "$config" | grep -q 'rounding\s*='; then
            sed -i "/^decoration\s*{/,/^}/ s/rounding\s*=.*/rounding = $RAD/" "$config"
        else
            # Если нет — добавляем после открывающей скобки
            sed -i "/^decoration\s*{/a \ \ rounding = $RAD" "$config"
        fi
    else
        # Если секции нет — создаём
        echo -e "\ndecoration {\n    rounding = $RAD\n}" >> "$config"
    fi
    echo "✅ Hyprland: радиус обновлён до $RAD"
    hyprctl reload 2>/dev/null || true
}

# === Функция для Niri ===
apply_niri() {
    local config="$HOME/.config/niri/config.kdl"
    if [[ ! -f "$config" ]]; then
        echo "⚠️  Файл $config не найден, пропускаем Niri"
        return
    fi
    # Ищем window-rule с geometry-corner-radius
    if grep -q 'window-rule\s*{' "$config" && grep -q 'geometry-corner-radius' "$config"; then
        sed -i "s/geometry-corner-radius [0-9]*/geometry-corner-radius $RAD/" "$config"
    else
        # Если правила нет — добавляем в конец
        echo -e "\nwindow-rule {\n    geometry-corner-radius $RAD\n    clip-to-geometry true\n}" >> "$config"
    fi
    echo "✅ Niri: радиус обновлён до $RAD"
    # Niri перезагружается по Ctrl+Shift+R, но можно отправить сигнал через niri-msg
    niri-msg reload 2>/dev/null || true
}

# === Функция для Driftwm ===
apply_driftwm() {
    local config="$HOME/.config/driftwm/config.toml"
    if [[ ! -f "$config" ]]; then
        echo "⚠️  Файл $config не найден, пропускаем Driftwm"
        return
    fi
    # Ищем секцию [decorations] и параметр corner_radius
    if grep -q '^\[decorations\]' "$config"; then
        if grep -A 5 '^\[decorations\]' "$config" | grep -q 'corner_radius\s*='; then
            sed -i "/^\[decorations\]/,/^\[/ s/corner_radius\s*=.*/corner_radius = $RAD/" "$config"
        else
            sed -i "/^\[decorations\]/a corner_radius = $RAD" "$config"
        fi
    else
        # Если секции нет — добавляем
        echo -e "\n[decorations]\ncorner_radius = $RAD" >> "$config"
    fi
    echo "✅ Driftwm: радиус обновлён до $RAD"
    # Driftwm перезагружается автоматически при изменении config.toml
}

# === Определяем, какой WM запущен, и применяем ===
if pgrep -x "sway" >/dev/null 2>&1; then
    # SwayFX — это форк Sway, процесс тот же
    apply_swayfx
elif pgrep -x "Hyprland" >/dev/null 2>&1; then
    apply_hyprland
elif pgrep -x "niri" >/dev/null 2>&1; then
    apply_niri
elif pgrep -x "driftwm" >/dev/null 2>&1; then
    apply_driftwm
else
    echo "⚠️  Не удалось определить запущенный WM. Применяем ко всем возможным конфигам..."
    apply_swayfx
    apply_hyprland
    apply_niri
    apply_driftwm
fi

echo "🎉 Готово!"
