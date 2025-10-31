#!/usr/bin/env bash

# Универсальный скрипт для eww launcher

CURRENT_MODE="drun"
SEARCH_QUERY=""
CMD_FILE="/tmp/eww-launcher-cmd"
CACHE_FILE="/tmp/eww-launcher-cache"
CACHE_TIMEOUT=300  # 5 минут

# ==================== DRUN ====================

parse_desktop_file() {
    local file="$1"
    local search="$2"
    
    [[ ! -f "$file" ]] && return
    
    local name="" exec="" icon="" comment="" terminal="false" 
    local nodisplay="false" hidden="false" type=""
    
    local in_section=false
    while IFS= read -r line; do
        if [[ "$line" =~ ^\[Desktop\ Entry\] ]]; then
            in_section=true
            continue
        fi
        
        if [[ "$line" =~ ^\[.*\] ]]; then
            in_section=false
            continue
        fi
        
        if [[ "$in_section" == true ]]; then
            case "$line" in
                Name=*) name="${line#Name=}" ;;
                Exec=*) exec="${line#Exec=}" ;;
                Icon=*) icon="${line#Icon=}" ;;
                Comment=*) comment="${line#Comment=}" ;;
                Terminal=*) terminal="${line#Terminal=}" ;;
                NoDisplay=*) nodisplay="${line#NoDisplay=}" ;;
                Hidden=*) hidden="${line#Hidden=}" ;;
                Type=*) type="${line#Type=}" ;;
            esac
        fi
    done < "$file"
    
    [[ "$type" != "Application" ]] && return
    [[ "$nodisplay" == "true" ]] && return
    [[ "$hidden" == "true" ]] && return
    [[ -z "$name" ]] && return
    [[ -z "$exec" ]] && return
    
    if [[ -n "$search" ]]; then
        local search_lower=$(echo "$search" | tr '[:upper:]' '[:lower:]')
        local name_lower=$(echo "$name" | tr '[:upper:]' '[:lower:]')
        local comment_lower=$(echo "$comment" | tr '[:upper:]' '[:lower:]')
        
        if [[ ! "$name_lower" =~ $search_lower ]] && \
           [[ ! "$comment_lower" =~ $search_lower ]]; then
            return
        fi
    fi
    
    exec=$(echo "$exec" | sed -E 's/%[a-zA-Z]//g' | xargs)
    
    name=$(echo "$name" | sed 's/\\/\\\\/g; s/"/\\"/g')
    exec=$(echo "$exec" | sed 's/\\/\\\\/g; s/"/\\"/g')
    icon=$(echo "$icon" | sed 's/\\/\\\\/g; s/"/\\"/g')
    comment=$(echo "$comment" | sed 's/\\/\\\\/g; s/"/\\"/g')
    file=$(echo "$file" | sed 's/\\/\\\\/g; s/"/\\"/g')
    
    printf '{"name":"%s","exec":"%s","icon":"%s","comment":"%s","terminal":%s,"file":"%s"}' \
        "$name" "$exec" "$icon" "$comment" \
        "$([[ "$terminal" == "true" ]] && echo "true" || echo "false")" \
        "$file"
}

get_desktop_files() {
    echo "${XDG_DATA_DIRS:-/usr/local/share:/usr/share}:${XDG_DATA_HOME:-$HOME/.local/share}" | \
    tr ':' '\n' | \
    while read -r dir; do
        find "$dir/applications" -maxdepth 1 -name "*.desktop" 2>/dev/null
    done | sort -u
}

list_drun() {
    local search="$1"
    
    local -a items_array
    while IFS= read -r desktop_file; do
        item=$(parse_desktop_file "$desktop_file" "$search")
        if [[ -n "$item" ]]; then
            items_array+=("$item")
        fi
    done < <(get_desktop_files)
    
    printf "["
    local first=true
    for item in "${items_array[@]}"; do
        [[ "$first" == false ]] && printf ","
        printf "%s" "$item"
        first=false
    done
    printf "]\n"
}

launch_drun() {
    local desktop_file="$1"
    
    [[ ! -f "$desktop_file" ]] && exit 1
    
    local exec_line=$(grep "^Exec=" "$desktop_file" | head -1 | cut -d= -f2-)
    local terminal=$(grep "^Terminal=" "$desktop_file" | head -1 | cut -d= -f2-)
    
    exec_line=$(echo "$exec_line" | sed -E 's/%[a-zA-Z]//g' | xargs)
    
    if [[ "$terminal" == "true" ]]; then
        ${TERMINAL:-kitty} -e $exec_line &
    else
        setsid -f $exec_line >/dev/null 2>&1
    fi
}

# ==================== CLIPHIST ===================

launch_cliphist() {
    local id="$1"
    echo -e "${id}\t" | cliphist decode | wl-copy
}

list_cliphist() {
    tmp_dir="/tmp/cliphist"
    
    if [[ $1 =~ ^[0-9]+$ ]]; then
        cliphist decode <<<"$1" | wl-copy
        exit
    fi

    local search="$1"
    rm -rf "$tmp_dir"
    mkdir -p "$tmp_dir"

    read -r -d '' prog <<'EOF'
BEGIN { cnt = 0; search_lower = tolower(search) }
{
    if ($0 ~ /^[0-9]+\s<meta http-equiv=/) next;
    if (match($0, /^([0-9]+)\s/, mid)) {
        id = mid[1];
        content = substr($0, RLENGTH + 1);
        if (match(content, /binary[^\n]*(jpg|jpeg|png|bmp)/, imggrp)) {
            ext = imggrp[1];
            icon_path = tmp_dir "/" id "." ext;
            cmd = sprintf("echo '%s\t' | cliphist decode > '%s'", id, icon_path);
            system(cmd);
            name = id " (" ext ")";
            gsub(/\\/, "\\\\", name);
            gsub(/"/, "\\\"", name);
            gsub(/\\/, "\\\\", icon_path);
            gsub(/"/, "\\\"", icon_path);
            name_lower = tolower(name);
            if (length(search) == 0 || index(name_lower, search_lower) > 0) {
                item = sprintf("{\"name\":\"%s\",\"exec\":\"\",\"icon\":\"%s\",\"comment\":\"\",\"terminal\":false,\"file\":\"%s\"}", name, icon_path, id);
                items[cnt++] = item;
            }
            next;
        }
        orig_content = content;
        gsub(/\\/, "\\\\", content);
        gsub(/"/, "\\\"", content);
        content_lower = tolower(orig_content);
        if (length(search) == 0 || index(content_lower, search_lower) > 0) {
            item = sprintf("{\"name\":\"%s\",\"exec\":\"\",\"icon\":\"\",\"comment\":\"\",\"terminal\":false,\"file\":\"%s\"}", content, id);
            items[cnt++] = item;
        }
    }
}
END {
    printf "[";
    for (i = 0; i < cnt; i++) {
        if (i > 0) printf ",";
        printf "%s", items[i];
    }
    printf "]\n";
}
EOF
    gawk -v search="$search" -v tmp_dir="$tmp_dir" "$prog" < <(cliphist list)
}

# ==================== OUTPUT ====================

output_list() {
    case "$CURRENT_MODE" in
        drun)
            list_drun "$SEARCH_QUERY"
            ;;
        clipboard)
            list_cliphist "$SEARCH_QUERY"
            ;;
        files)
            printf "[]\n"
            ;;
        windows)
            printf "[]\n"
            ;;
    esac
}

# ==================== LISTEN MODE ====================

listen_mode() {
    touch "$CMD_FILE"
    
    output_list
    
    tail -f -n0 "$CMD_FILE" 2>/dev/null | while read -r line; do
        cmd=$(echo "$line" | cut -d' ' -f1)
        arg=$(echo "$line" | cut -d' ' -f2-)
        
        case "$cmd" in
            change)
                CURRENT_MODE="$arg"
                SEARCH_QUERY=""
                output_list
                ;;
            search)
                SEARCH_QUERY="$arg"
                output_list
                ;;
            quit)
                break
                ;;
        esac
    done
}

# ==================== MAIN ====================

MODE="${1:-listen}"

case "$MODE" in
    listen)
        listen_mode
        ;;
    
    change)
        echo "change ${2:-drun}" >> "$CMD_FILE"
        ;;
    
    search)
        echo "search ${2:-}" >> "$CMD_FILE"
        ;;
    
    launch)
        case "${2:-drun}" in
            drun) launch_drun "$3" ;;
            clipboard) launch_cliphist "$3" ;;
        esac
        ;;
    
    *)
        echo "Usage: $0 {listen|change <mode>|search <query>|launch <mode> <arg>}"
        exit 1
        ;;
esac
