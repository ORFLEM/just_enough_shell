#!/usr/bin/env bash

set -euo pipefail

# ==================== JSON ====================
if command -v jq &>/dev/null; then
    JSON_TOOL="jq"
elif command -v python3 &>/dev/null; then
    JSON_TOOL="python3"
else
    echo '{"error": "Need jq or python3"}' >&2
    exit 1
fi

to_json() {
    if [[ "$JSON_TOOL" == "jq" ]]; then
        jq -n --argjson data "$1" '$data'
    else
        python3 -c "import json,sys; print(json.dumps($1))"
    fi
}

# ==================== ОС ====================
get_os() {
    local distro kernel arch
    if [[ "$OSTYPE" == "darwin"* ]]; then
        distro="$(sw_vers -productName 2>/dev/null) $(sw_vers -productVersion 2>/dev/null)"
        kernel="$(uname -r)"
        arch="$(uname -m)"
    elif [[ "$OSTYPE" == freebsd* ]] || [[ "$OSTYPE" == openbsd* ]] || [[ "$OSTYPE" == netbsd* ]]; then
        distro="$(uname -sr)"
        kernel="$(uname -r)"
        arch="$(uname -m)"
    else
        if command -v lsb_release &>/dev/null; then
            distro=$(lsb_release -ds 2>/dev/null || echo "")
        elif [[ -f /etc/os-release ]]; then
            . /etc/os-release
            distro="${PRETTY_NAME:-}"
        else
            distro="$(uname -s) $(uname -r)"
        fi
        distro=$(echo "$distro" | sed -e 's/^"//' -e 's/"$//' -e "s/^'//" -e "s/'$//")
        kernel=$(uname -r)
        arch=$(uname -m)
    fi
    to_json "{\"distro\": \"$distro\", \"kernel\": \"$kernel\", \"arch\": \"$arch\"}"
}

# ==================== CPU ====================
get_cpu() {
    local model cores freq
    if command -v lscpu &>/dev/null; then
        model=$(lscpu 2>/dev/null | grep -i "Model name" | head -1 | cut -d: -f2- | sed 's/^[ \t]*//')
        cores=$(lscpu 2>/dev/null | grep -i "^CPU(s):" | awk '{print $2}')
    else
        model=$(grep -m1 "model name" /proc/cpuinfo 2>/dev/null | cut -d: -f2- | sed 's/^[ \t]*//')
        cores=$(grep -c "^processor" /proc/cpuinfo 2>/dev/null || echo "null")
    fi

    freq=$(grep -m1 "cpu MHz" /proc/cpuinfo 2>/dev/null | cut -d: -f2- | sed 's/^[ \t]*//' | cut -d. -f1)
    if [[ -z "$freq" ]] && command -v lscpu &>/dev/null; then
        freq=$(lscpu 2>/dev/null | grep -E "MHz|GHz" | head -1 | grep -oE '[0-9]+([.][0-9]+)?' | head -1 | cut -d. -f1)
    fi

    local cores_json="null"
    [[ "$cores" != "null" && -n "$cores" ]] && cores_json="$cores"
    local freq_json="null"
    [[ -n "$freq" ]] && freq_json="$freq"

    to_json "{\"model\": \"$model\", \"cores\": $cores_json, \"freq_mhz\": $freq_json}"
}

# ==================== RAM ====================
get_ram() {
    if [[ -f /proc/meminfo ]]; then
        local total_kb avail_kb used_kb
        total_kb=$(awk '/^MemTotal:/ {print $2}' /proc/meminfo)
        avail_kb=$(awk '/^MemAvailable:/ {print $2}' /proc/meminfo 2>/dev/null || echo "")
        if [[ -z "$avail_kb" ]]; then
            local free_kb buffers_kb cached_kb
            free_kb=$(awk '/^MemFree:/ {print $2}' /proc/meminfo)
            buffers_kb=$(awk '/^Buffers:/ {print $2}' /proc/meminfo)
            cached_kb=$(awk '/^Cached:/ {print $2}' /proc/meminfo)
            avail_kb=$((free_kb + buffers_kb + cached_kb))
        fi
        used_kb=$((total_kb - avail_kb))
        to_json "{\"total_bytes\": $((total_kb * 1024)), \"used_bytes\": $((used_kb * 1024)), \"available_bytes\": $((avail_kb * 1024))}"
    elif command -v vm_stat &>/dev/null; then
        local page_size total_pages free_pages
        page_size=$(vm_stat | grep "page size" | awk '{print $8}' || echo "4096")
        total_pages=$(vm_stat | grep "Pages free" | awk '{print $3}' | tr -d '.')
        free_pages=$(vm_stat | grep "Pages free" | awk '{print $3}' | tr -d '.')
        local total_bytes=$((total_pages * page_size))
        local avail_bytes=$((free_pages * page_size))
        local used_bytes=$((total_bytes - avail_bytes))
        to_json "{\"total_bytes\": $total_bytes, \"used_bytes\": $used_bytes, \"available_bytes\": $avail_bytes}"
    else
        to_json "null"
    fi
}

# ==================== GPU ====================
get_gpu() {
    local gpu="null"
    if command -v lspci &>/dev/null; then
        gpu=$(lspci -nn 2>/dev/null | grep -iE "vga|3d|display" | head -1 | cut -d: -f3- | sed 's/^[ \t]*//')
        if [[ -z "$gpu" ]]; then
            gpu=$(lspci 2>/dev/null | grep -i "VGA" | head -1 | cut -d: -f3- | sed 's/^[ \t]*//')
        fi
    fi
    if [[ -z "$gpu" || "$gpu" == "null" ]] && [[ -d /sys/class/drm ]]; then
        for card in /sys/class/drm/card*/device/vendor; do
            if [[ -f "$card" ]]; then
                local vendor_id
                vendor_id=$(cat "$card" 2>/dev/null)
                case "$vendor_id" in
                    *"0x10de"*) gpu="NVIDIA"; break ;;
                    *"0x1002"*) gpu="AMD"; break ;;
                    *"0x8086"*) gpu="Intel"; break ;;
                esac
            fi
        done
    fi
    if [[ -f /proc/driver/nvidia/version ]]; then
        gpu="NVIDIA ($(grep -m1 "NVRM version" /proc/driver/nvidia/version 2>/dev/null | sed 's/^[ \t]*//'))"
    fi
    to_json "{\"model\": \"$gpu\"}"
}

# ==================== DISK ====================
get_disk() {
    if command -v df &>/dev/null; then
        local disk_info
        disk_info=$(df -B1 --output=size,used,avail / 2>/dev/null | tail -n 1)
        if [[ -n "$disk_info" ]]; then
            local total_bytes used_bytes avail_bytes
            total_bytes=$(echo "$disk_info" | awk '{print $1}')
            used_bytes=$(echo "$disk_info" | awk '{print $2}')
            avail_bytes=$(echo "$disk_info" | awk '{print $3}')
            to_json "{\"total_bytes\": $total_bytes, \"used_bytes\": $used_bytes, \"available_bytes\": $avail_bytes}"
            return
        fi
        disk_info=$(df -k / 2>/dev/null | tail -n 1)
        if [[ -n "$disk_info" ]]; then
            local total_bytes used_bytes avail_bytes
            total_bytes=$(echo "$disk_info" | awk '{print $2}')
            used_bytes=$(echo "$disk_info" | awk '{print $3}')
            avail_bytes=$(echo "$disk_info" | awk '{print $4}')
            to_json "{\"total_bytes\": $((total_bytes * 1024)), \"used_bytes\": $((used_bytes * 1024)), \"available_bytes\": $((avail_bytes * 1024))}"
            return
        fi
    fi
    to_json "null"
}

# ==================== NIX (точный алгоритм fastfetch) ====================

# Проверка одного пути из nix store — как isValidNixPkg в fastfetch
is_valid_nix_pkg() {
    local pkg="$1"
    # Должен быть директорией
    [[ -d "$pkg" ]] || return 1

    # basename — всё после последнего /
    local basename="${pkg##*/}"

    # Исключения
    [[ "$basename" == nixos-system-nixos-* ]] && return 1
    [[ "$basename" == *-doc ]] && return 1
    [[ "$basename" == *-man ]] && return 1
    [[ "$basename" == *-info ]] && return 1
    [[ "$basename" == *-dev ]] && return 1
    [[ "$basename" == *-bin ]] && return 1

    # Должна быть версия вида цифры.цифры
    [[ "$basename" =~ [0-9]+\.[0-9]+ ]] && return 0
    return 1
}

# Подсчёт пакетов для одного nix-пути — как getNixPackagesImpl в fastfetch
count_nix_path() {
    local path="$1"
    [[ -e "$path" ]] || { echo 0; return; }

    local count=0
    while IFS= read -r line; do
        if is_valid_nix_pkg "$line"; then
            ((count++))
        fi
    done < <(nix-store --query --requisites "$path" 2>/dev/null)

    echo "$count"
}

get_packages() {
    local packages="[]"

    add_pkg() {
        local manager="$1" scope="$2" count="$3"
        if [[ "$JSON_TOOL" == "jq" ]]; then
            packages=$(echo "$packages" | jq --arg m "$manager" --arg s "$scope" --argjson c "$count" '. + [{"manager": $m, "scope": $s, "count": $c}]')
        else
            packages=$(python3 -c "import json; d=json.loads('$packages'); d.append({'manager':'$manager','scope':'$scope','count':$count}); print(json.dumps(d))")
        fi
    }

    # --- Nix system: /run/current-system + /nix/var/nix/profiles/default ---
    local nix_system=0
    if [[ -d /run/current-system ]]; then
        nix_system=$((nix_system + $(count_nix_path "/run/current-system")))
    fi
    if [[ -e /nix/var/nix/profiles/default ]]; then
        nix_system=$((nix_system + $(count_nix_path "/nix/var/nix/profiles/default")))
    fi
    if [[ "$nix_system" -gt 0 ]]; then
        add_pkg "nix" "system" "$nix_system"
    fi

    # --- Nix user: ~/.nix-profile + $XDG_STATE_HOME/nix/profile + /etc/profiles/per-user/$USER ---
    local nix_user=0
    if [[ -e "$HOME/.nix-profile" ]]; then
        nix_user=$((nix_user + $(count_nix_path "$HOME/.nix-profile")))
    fi

    local state_home="${XDG_STATE_HOME:-$HOME/.local/state}"
    if [[ -e "$state_home/nix/profile" ]]; then
        nix_user=$((nix_user + $(count_nix_path "$state_home/nix/profile")))
    fi

    local user_name="${USER:-$(id -un)}"
    if [[ -e "/etc/profiles/per-user/$user_name" ]]; then
        nix_user=$((nix_user + $(count_nix_path "/etc/profiles/per-user/$user_name")))
    fi
    if [[ "$nix_user" -gt 0 ]]; then
        add_pkg "nix" "user" "$nix_user"
    fi

    # --- Flatpak ---
    if command -v flatpak &>/dev/null; then
        local flatpak_system flatpak_user
        flatpak_system=$(flatpak list --system --columns=ref 2>/dev/null | wc -l | tr -d ' ')
        flatpak_user=$(flatpak list --user --columns=ref 2>/dev/null | wc -l | tr -d ' ')
        add_pkg "flatpak" "system" "${flatpak_system:-0}"
        add_pkg "flatpak" "user" "${flatpak_user:-0}"
    fi

    # --- Другие менеджеры ---
    local count

    if command -v dpkg-query &>/dev/null; then
        count=$(dpkg-query -l 2>/dev/null | tail -n +2 | wc -l | tr -d ' ')
        add_pkg "dpkg" "system" "$count"
    fi

    if command -v rpm &>/dev/null; then
        count=$(rpm -qa 2>/dev/null | wc -l | tr -d ' ')
        add_pkg "rpm" "system" "$count"
    fi

    if command -v pacman &>/dev/null; then
        count=$(pacman -Q 2>/dev/null | wc -l | tr -d ' ')
        add_pkg "pacman" "system" "$count"
    fi

    if command -v snap &>/dev/null; then
        count=$(snap list 2>/dev/null | tail -n +2 | wc -l | tr -d ' ')
        add_pkg "snap" "system" "$count"
    fi

    if command -v apk &>/dev/null; then
        count=$(apk list --installed 2>/dev/null | wc -l | tr -d ' ')
        add_pkg "apk" "system" "$count"
    fi

    if command -v emerge &>/dev/null; then
        if [[ -d /var/db/pkg ]]; then
            count=$(find /var/db/pkg -mindepth 2 -maxdepth 2 -type d 2>/dev/null | wc -l | tr -d ' ')
        else
            count=$(qlist -I 2>/dev/null | wc -l | tr -d ' ')
        fi
        add_pkg "emerge" "system" "$count"
    fi

    if command -v xbps-query &>/dev/null; then
        count=$(xbps-query -l 2>/dev/null | wc -l | tr -d ' ')
        add_pkg "xbps" "system" "$count"
    fi

    if command -v brew &>/dev/null; then
        count=$(brew list --formula 2>/dev/null | wc -l | tr -d ' ')
        add_pkg "brew" "system" "$count"
    fi

    if command -v guix &>/dev/null; then
        count=$(guix package -I 2>/dev/null | wc -l | tr -d ' ')
        add_pkg "guix" "user" "$count"
    fi

    if command -v pkg &>/dev/null && [[ "$OSTYPE" == "freebsd"* ]]; then
        count=$(pkg info 2>/dev/null | wc -l | tr -d ' ')
        add_pkg "pkg" "system" "$count"
    fi

    echo "$packages"
}

# ==================== СБОРКА ====================
os_json=$(get_os)
cpu_json=$(get_cpu)
ram_json=$(get_ram)
gpu_json=$(get_gpu)
disk_json=$(get_disk)
packages_json=$(get_packages)

if [[ "$JSON_TOOL" == "jq" ]]; then
    jq -n \
        --argjson os "$os_json" \
        --argjson cpu "$cpu_json" \
        --argjson ram "$ram_json" \
        --argjson gpu "$gpu_json" \
        --argjson disk "$disk_json" \
        --argjson packages "$packages_json" \
        '{os: $os, cpu: $cpu, ram: $ram, gpu: $gpu, disk: $disk, packages: $packages}'
else
    python3 -c "
import json
data = {
    'os': json.loads('$os_json'),
    'cpu': json.loads('$cpu_json'),
    'ram': json.loads('$ram_json'),
    'gpu': json.loads('$gpu_json'),
    'disk': json.loads('$disk_json'),
    'packages': json.loads('$packages_json')
}
print(json.dumps(data, indent=2))
"
fi
