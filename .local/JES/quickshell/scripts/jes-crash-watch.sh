#!/usr/bin/env bash
# Обёртка запуска JES. Пишет лог сессии в ~/.local/share/JES/log/,
# при крахе — сохраняет лог как *.crash.log и добавляет виновника в blacklist.
#
# Чистый выход: 0, 129 (SIGHUP), 130 (SIGINT), 137 (SIGKILL от stop-daemon), 143 (SIGTERM).
# Всё остальное ≥128 — НАСТОЯЩИЕ краши: 132 SIGILL, 133 SIGTRAP, 134 SIGABRT,
# 135 SIGBUS, 136 SIGFPE, 139 SIGSEGV, 134/139 — самые частые у Qt/QML.

SHELL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SHARE_DIR="$HOME/.local/share/JES"
LOG_DIR="$SHARE_DIR/log"
CACHE_DIR="$HOME/.cache/JES"
BLACKLIST="$CACHE_DIR/blacklist"
LAST_PLUGIN="$CACHE_DIR/.last_loaded_plugin"
GRACEFUL_FLAG="$CACHE_DIR/.graceful_stop"

mkdir -p "$LOG_DIR" "$CACHE_DIR"
touch "$BLACKLIST"

# Чистим все логи, кроме .crash.log
find "$LOG_DIR" -maxdepth 1 -type f -name "*.log" ! -name "*.crash.log" -delete 2>/dev/null
pkill -f "inotifywait.*JES/plugins" 2>/dev/null

LOG_FILE="$LOG_DIR/$(date +%Y%m%d-%H%M%S).log"
rm -f "$LAST_PLUGIN"

echo "[crash-watch] starting JES, log → $LOG_FILE" >&2

qs -c "$SHELL_DIR" "$@" > "$LOG_FILE" 2>&1
EXIT_CODE=$?

# Флаг graceful stop выставляет jes-cli ДО того, как убивает qs.
# Удаляем его сразу — он одноразовый.
graceful=0
if [[ -f "$GRACEFUL_FLAG" ]]; then
    graceful=1
    rm -f "$GRACEFUL_FLAG"
fi

case $EXIT_CODE in
    0|129|130|137|143)
        # Штатное завершение — сносим лог сессии
        rm -f "$LOG_FILE" 2>/dev/null
        ;;
    *)
        # Настоящий краш: ненулевой код, полученный не от разрешённого сигнала
        echo "[crash-watch] JES crashed with code $EXIT_CODE" >&2
        mv "$LOG_FILE" "${LOG_FILE%.log}.crash.log"

        # Не атрибутируем краш плагину, если это была управляемая остановка
        if [[ $graceful -eq 0 && -f "$LAST_PLUGIN" ]]; then
            PLUGIN_NAME=$(cat "$LAST_PLUGIN")
            if [[ -n "$PLUGIN_NAME" && "$PLUGIN_NAME" != "__unknown__" ]]; then
                echo "[crash-watch] last loaded plugin: $PLUGIN_NAME" >&2
                if ! grep -qxF "$PLUGIN_NAME" "$BLACKLIST"; then
                    echo "$PLUGIN_NAME" >> "$BLACKLIST"
                    echo "[crash-watch] blacklisted: $PLUGIN_NAME" >&2
                fi
            fi
        fi
        rm -f "$LAST_PLUGIN"
        ;;
esac

exit $EXIT_CODE
