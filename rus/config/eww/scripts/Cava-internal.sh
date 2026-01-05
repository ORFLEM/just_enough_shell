#!/bin/sh
# Проверяем, запущен ли уже cava
if pgrep -x cava >/dev/null; then
    pkill -x cava
    sleep 0.3
fi

# Настройки
PIPE="/tmp/cava_eww.fifo"
CONFIG_FILE="/tmp/cava_eww_config"

# Очищаем pipe
[ -p "$PIPE" ] && rm -f "$PIPE"
mkfifo "$PIPE"

# Создаем конфигурацию cava с оптимизированными настройками
cat > "$CONFIG_FILE" << 'CAVA_EOF'
[general]
bars = 20
framerate = 30
sleep_timer = 1
[input]
method = pulse
[output]
method = raw
raw_target = /tmp/cava_eww.fifo
data_format = ascii
ascii_max_range = 7
CAVA_EOF

# Запускаем cava в фоне
cava -p "$CONFIG_FILE" &
CAVA_PID=$!

# Функция очистки при выходе
cleanup() {
    kill $CAVA_PID 2>/dev/null
    rm -f "$PIPE" "$CONFIG_FILE"
    exit 0
}
trap cleanup EXIT INT TERM

# Используем awk вместо sed - быстрее для Unicode
# Кэширование последнего вывода
LAST_OUTPUT=""

# Читаем данные из pipe с кэшированием и throttling
while IFS= read -r line; do
    # awk обрабатывает быстрее чем sed для таких замен
    result=$(echo "$line" | awk '{
        gsub(/;/, "")
        gsub(/0/, "▁")
        gsub(/1/, "▂")
        gsub(/2/, "▃")
        gsub(/3/, "▄")
        gsub(/4/, "▅")
        gsub(/5/, "▆")
        gsub(/6/, "▇")
        gsub(/7/, "█")
        print
    }')
    
    # Выводим только если результат изменился
    if [ "$result" != "$LAST_OUTPUT" ]; then
        echo "$result"
        LAST_OUTPUT="$result"
    fi
done < "$PIPE"
