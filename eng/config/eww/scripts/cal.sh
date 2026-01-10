#!/bin/sh

STATE_FILE="$HOME/.config/eww/calendar_state"
HOLIDAYS_FILE="$HOME/.config/eww/holidays.txt"

month_name() {
    case $1 in
        1) echo "январь" ;; 2) echo "февраль" ;; 3) echo "март" ;;
        4) echo "апрель" ;; 5) echo "май" ;; 6) echo "июнь" ;;
        7) echo "июль" ;; 8) echo "август" ;; 9) echo "сентябрь" ;;
        10) echo "октябрь" ;; 11) echo "ноябрь" ;; 12) echo "декабрь" ;;
    esac
}

days_in_month() {
    year=$1 month=$2
    case $month in
        1|3|5|7|8|10|12) echo 31 ;;
        4|6|9|11) echo 30 ;;
        2)
            if [ $((year % 4)) -eq 0 ] && { [ $((year % 100)) -ne 0 ] || [ $((year % 400)) -eq 0 ]; }; then
                echo 29
            else
                echo 28
            fi
            ;;
    esac
}

first_day_of_month() {
    year=$1 month=$2
    dow=$(date -d "$year-$(printf "%02d" $month)-01" +%w 2>/dev/null || date -j -f "%Y-%m-%d" "$year-$(printf "%02d" $month)-01" +%w 2>/dev/null)
    echo $(( (dow + 6) % 7 ))
}

is_holiday() {
    day=$1 month=$2 year=$3
    [ ! -f "$HOLIDAYS_FILE" ] && return
    
    holiday=$(grep "^${day}|${month}|${year}-" "$HOLIDAYS_FILE" | head -n1)
    [ -n "$holiday" ] && { echo "$holiday" | cut -d'-' -f2-; return; }
    
    holiday=$(grep "^${day}|${month}|\*-" "$HOLIDAYS_FILE" | head -n1)
    [ -n "$holiday" ] && echo "$holiday" | cut -d'-' -f2-
}

save_state() {
    mkdir -p "$(dirname "$STATE_FILE")"
    printf "year=%s\nmonth=%s\nmode=%s\n" "$1" "$2" "$3" > "$STATE_FILE"
}

load_state() {
    if [ -f "$STATE_FILE" ]; then
        . "$STATE_FILE"
        echo "$year $month $mode"
    else
        echo "$(date +%Y) $(date +%-m) month"
    fi
}

generate_month_calendar() {
    target_year=$1 target_month=$2
    current_year=$(date +%Y) current_month=$(date +%-m) current_day=$(date +%-d)
    
    days_in_target_month=$(days_in_month $target_year $target_month)
    first_day=$(first_day_of_month $target_year $target_month)
    
    if [ $target_month -eq 1 ]; then
        prev_month=12 prev_year=$((target_year - 1))
    else
        prev_month=$((target_month - 1)) prev_year=$target_year
    fi
    days_in_prev_month=$(days_in_month $prev_year $prev_month)
    
    if [ $target_month -eq 12 ]; then
        next_month=1 next_year=$((target_year + 1))
    else
        next_month=$((target_month + 1)) next_year=$target_year
    fi
    
    printf '{"mode":"month","year":%d,"month_name":"%s"' $target_year "$(month_name $target_month)"
    
    day_count=0 day_index=0
    
    # Дни предыдущего месяца
    prev_month_start=$((days_in_prev_month - first_day + 1))
    i=$prev_month_start
    while [ $i -le $days_in_prev_month ] && [ $day_count -lt 42 ]; do
        day_of_week=$((day_index % 7))
        holiday=$(is_holiday $i $prev_month $prev_year)
        
        style="omonth"
        [ $prev_year -eq $current_year ] && [ $prev_month -eq $current_month ] && [ $i -eq $current_day ] && style="today"
        [ -n "$holiday" ] && style="oholiday"
        [ $day_of_week -eq 5 ] || [ $day_of_week -eq 6 ] && [ -z "$holiday" ] && [ "$style" = "omonth" ] && style="oweekend"
        
        if [ -n "$holiday" ]; then
            holiday_escaped=$(echo "$holiday" | sed 's/"/\\"/g')
            printf ',"day%d":{"day":%d,"style":"%s","holiday":"%s"}' $day_index $i $style "$holiday_escaped"
        else
            printf ',"day%d":{"day":%d,"style":"%s"}' $day_index $i $style
        fi
        
        i=$((i + 1)) day_count=$((day_count + 1)) day_index=$((day_index + 1))
    done
    
    # Дни текущего месяца
    i=1
    while [ $i -le $days_in_target_month ] && [ $day_count -lt 42 ]; do
        day_of_week=$((day_index % 7))
        holiday=$(is_holiday $i $target_month $target_year)
        
        style="tmonth"
        [ $target_year -eq $current_year ] && [ $target_month -eq $current_month ] && [ $i -eq $current_day ] && style="today"
        [ -n "$holiday" ] && style="tholiday"
        [ $day_of_week -eq 5 ] || [ $day_of_week -eq 6 ] && [ -z "$holiday" ] && [ "$style" = "tmonth" ] && style="tweekend"
        
        if [ -n "$holiday" ]; then
            holiday_escaped=$(echo "$holiday" | sed 's/"/\\"/g')
            printf ',"day%d":{"day":%d,"style":"%s","holiday":"%s"}' $day_index $i $style "$holiday_escaped"
        else
            printf ',"day%d":{"day":%d,"style":"%s"}' $day_index $i $style
        fi
        
        i=$((i + 1)) day_count=$((day_count + 1)) day_index=$((day_index + 1))
    done
    
    # Дни следующего месяца
    i=1
    while [ $day_count -lt 42 ]; do
        day_of_week=$((day_index % 7))
        holiday=$(is_holiday $i $next_month $next_year)
        
        style="omonth"
        [ $next_year -eq $current_year ] && [ $next_month -eq $current_month ] && [ $i -eq $current_day ] && style="today"
        [ -n "$holiday" ] && style="oholiday"
        [ $day_of_week -eq 5 ] || [ $day_of_week -eq 6 ] && [ -z "$holiday" ] && [ "$style" = "omonth" ] && style="oweekend"
        
        if [ -n "$holiday" ]; then
            holiday_escaped=$(echo "$holiday" | sed 's/"/\\"/g')
            printf ',"day%d":{"day":%d,"style":"%s","holiday":"%s"}' $day_index $i $style "$holiday_escaped"
        else
            printf ',"day%d":{"day":%d,"style":"%s"}' $day_index $i $style
        fi
        
        i=$((i + 1)) day_count=$((day_count + 1)) day_index=$((day_index + 1))
    done
    
    echo "}"
}

generate_year_calendar() {
    target_year=$1
    current_year=$(date +%Y) current_month=$(date +%-m)
    
    printf '{"mode":"year","year":%d' $target_year
    
    i=1
    while [ $i -le 12 ]; do
        is_current="false"
        [ $target_year -eq $current_year ] && [ $i -eq $current_month ] && is_current="true"
        printf ',"month%d":{"month":%d,"name":"%s","cur":%s}' $i $i "$(month_name $i)" $is_current
        i=$((i + 1))
    done
    
    echo "}"
}

generate_calendar_data() {
    state=$(load_state)
    year=$(echo $state | cut -d' ' -f1)
    month=$(echo $state | cut -d' ' -f2)
    mode=$(echo $state | cut -d' ' -f3)
    
    if [ "$mode" = "year" ]; then
        generate_year_calendar $year
    else
        generate_month_calendar $year $month
    fi
}

case "$1" in
    "next"|"prev"|"today"|"next_year"|"prev_year"|"toggle_mode")
        state=$(load_state)
        year=$(echo $state | cut -d' ' -f1)
        month=$(echo $state | cut -d' ' -f2)
        mode=$(echo $state | cut -d' ' -f3)
        
        case "$1" in
            "next")
                if [ "$mode" = "month" ]; then
                    [ $month -eq 12 ] && { month=1; year=$((year + 1)); } || month=$((month + 1))
                else
                    year=$((year + 1))
                fi
                ;;
            "prev")
                if [ "$mode" = "month" ]; then
                    [ $month -eq 1 ] && { month=12; year=$((year - 1)); } || month=$((month - 1))
                else
                    year=$((year - 1))
                fi
                ;;
            "today")
                year=$(date +%Y)
                month=$(date +%-m)
                mode="month"
                ;;
            "next_year") year=$((year + 1)) ;;
            "prev_year") year=$((year - 1)) ;;
            "toggle_mode")
                [ "$mode" = "month" ] && mode="year" || mode="month"
                ;;
        esac
        
        save_state $year $month $mode
        ;;
    "select_month")
        [ -z "$2" ] && exit 1
        state=$(load_state)
        year=$(echo $state | cut -d' ' -f1)
        save_state $year $2 "month"
        ;;
    "reset")
        save_state $(date +%Y) $(date +%-m) "month"
        ;;
    "listen")
        # КРИТИЧНО: используем inotifywait БЕЗ fallback на sleep!
        generate_calendar_data
        
        if command -v inotifywait >/dev/null 2>&1; then
            # Мониторим ТОЛЬКО изменения файла состояния
            inotifywait -m -e modify,close_write "$STATE_FILE" 2>/dev/null | while read -r; do
                generate_calendar_data
            done
        else
            # Если нет inotifywait - обновляем раз в 5 секунд (достаточно для календаря!)
            while true; do
                sleep 5
                generate_calendar_data
            done
        fi
        ;;
    "")
        generate_calendar_data
        ;;
    *)
        echo "Usage: $0 {listen|next|prev|today|next_year|prev_year|toggle_mode|select_month|reset}"
        exit 1
        ;;
esac
