#!/bin/sh
# vendor-trim.sh — удаляет из vendor код под чужие ОС.
# Оставляет linux (amd64/arm64) и все untagged/shared файлы.
# Использование: sh vendor-trim.sh [vendor-dir]   (по умолчанию ./vendor)
set -eu

VENDOR="${1:-./vendor}"

[ -d "$VENDOR" ] || { echo "no such dir: $VENDOR" >&2; exit 1; }

# пакет golang.org/x/sys/windows целиком виндовый
rm -rf "$VENDOR"/golang.org/x/sys/windows 2>/dev/null || true

find "$VENDOR" -type f \( \
    -name '*_windows.go' \
    -o -name '*_darwin*.go' \
    -o -name '*_freebsd*.go' \
    -o -name '*_netbsd*.go' \
    -o -name '*_openbsd*.go' \
    -o -name '*_dragonfly*.go' \
    -o -name '*_plan9*.go' \
    -o -name '*_solaris*.go' \
    -o -name '*_illumos*.go' \
    -o -name '*_aix*.go' \
    -o -name '*_zos_*.go' \
    -o -name '*_android*.go' \
    -o -name '*_ios*.go' \
    -o -name '*_js.go' \
    -o -name '*_wasip1*.go' \
    -o -name '*_bsd.go' \
  \) -print -delete

echo "trim done: $VENDOR"
