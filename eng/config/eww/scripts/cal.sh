#!/bin/sh

# Файл для хранения состояния календаря
STATE_FILE="$HOME/.config/eww/calendar_state"
# Файл с праздниками (формат: день|месяц|год-название_праздника)
HOLIDAYS_FILE="$HOME/.config/eww/holidays.txt"

# Функция для получения названия месяца
month_name() {
    case $1 in
        1) echo "january" ;;
        2) echo "february" ;;
        3) echo "march" ;;
        4) echo "april" ;;
        5) echo "may" ;;
        6) echo "june" ;;
        7) echo "july" ;;
        8) echo "august" ;;
        9) echo "september" ;;
        10) echo "october" ;;
        11) echo "november" ;;
        12) echo "december" ;;
    esac
}

# Функция для получения количества дней в месяце
days_in_month() {
    year=$1
    month=$2
    
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

# Функция для получения дня недели первого числа месяца (понедельник=0)
first_day_of_month() {
    year=$1
    month=$2
    
    if command -v date >/dev/null 2>&1; then
        if date -d "2000-01-01" >/dev/null 2>&1; then
            # GNU date - получаем день недели и конвертируем в понедельник=0
            dow=$(date -d "$year-$(printf "%02d" $month)-01" +%w)
            echo $(( (dow + 6) % 7 ))
        else
            # BSD date (macOS)
            dow=$(date -j -f "%Y-%m-%d" "$year-$(printf "%02d" $month)-01" +%w)
            echo $(( (dow + 6) % 7 ))
        fi
    else
        if [ $month -lt 3 ]; then
            month=$((month + 12))
            year=$((year - 1))
        fi
        q=1
        m=$month
        K=$((year % 100))
        J=$((year / 100))
        h=$(( (q + ((13 * (m + 1)) / 5) + K + (K / 4) + (J / 4) - 2 * J) % 7 ))
        # Конвертируем в понедельник=0
        echo $(( (h + 5) % 7 ))
    fi
}

# Функция для проверки, является ли день праздником
is_holiday() {
    day=$1
    month=$2
    year=$3
    
    if [ ! -f "$HOLIDAYS_FILE" ]; then
        echo ""
        return
    fi
    
    # Ищем точное совпадение день|месяц|год
    holiday=$(grep "^${day}|${month}|${year}-" "$HOLIDAYS_FILE" | head -n1)
    if [ -n "$holiday" ]; then
        echo "$holiday" | cut -d'-' -f2-
        return
    fi
    
    # Ищем ежегодный праздник день|месяц|*
    holiday=$(grep "^${day}|${month}|\*-" "$HOLIDAYS_FILE" | head -n1)
    if [ -n "$holiday" ]; then
        echo "$holiday" | cut -d'-' -f2-
        return
    fi
    
    echo ""
}

# Функция для сохранения состояния
save_state() {
    mkdir -p "$(dirname "$STATE_FILE")"
    echo "year=$1" > "$STATE_FILE"
    echo "month=$2" >> "$STATE_FILE"
    echo "mode=$3" >> "$STATE_FILE"
}

# Функция для загрузки состояния
load_state() {
    if [ -f "$STATE_FILE" ]; then
        . "$STATE_FILE"
        echo "$year $month $mode"
    else
        echo "$(date +%Y) $(date +%-m) month"
    fi
}

# Функция для генерации календаря месяца
generate_month_calendar() {
    target_year=$1
    target_month=$2
    
    current_year=$(date +%Y)
    current_month=$(date +%-m)
    current_day=$(date +%-d)
    
    days_in_target_month=$(days_in_month $target_year $target_month)
    first_day=$(first_day_of_month $target_year $target_month)
    
    # Предыдущий месяц
    if [ $target_month -eq 1 ]; then
        prev_month=12
        prev_year=$((target_year - 1))
    else
        prev_month=$((target_month - 1))
        prev_year=$target_year
    fi
    days_in_prev_month=$(days_in_month $prev_year $prev_month)
    
    # Следующий месяц
    if [ $target_month -eq 12 ]; then
        next_month=1
        next_year=$((target_year + 1))
    else
        next_month=$((target_month + 1))
        next_year=$target_year
    fi
    
    # Начинаем JSON в одну строку
    printf '{"mode":"month","year":%d,"month_name":"%s"' $target_year "$(month_name $target_month)"
    
    day_count=0
    day_index=0
    
    # Дни предыдущего месяца
    prev_month_start=$((days_in_prev_month - first_day + 1))
    i=$prev_month_start
    while [ $i -le $days_in_prev_month ] && [ $day_count -lt 42 ]; do
        # Определяем день недели (0=пн, 6=вс)
        day_of_week=$((day_index % 7))
        
        holiday=$(is_holiday $i $prev_month $prev_year)
        
        style="omonth"
        if [ $prev_year -eq $current_year ] && [ $prev_month -eq $current_month ] && [ $i -eq $current_day ]; then
            style="today"
        elif [ -n "$holiday" ]; then
            style="oholiday"
        elif [ $day_of_week -eq 5 ] || [ $day_of_week -eq 6 ]; then
            style="oweekend"
        fi
        
        if [ -n "$holiday" ]; then
            # Экранируем кавычки в названии праздника
            holiday_escaped=$(echo "$holiday" | sed 's/"/\\"/g')
            printf ',"day%d":{"day":%d,"style":"%s","holiday":"%s"}' $day_index $i $style "$holiday_escaped"
        else
            printf ',"day%d":{"day":%d,"style":"%s"}' $day_index $i $style
        fi
        
        i=$((i + 1))
        day_count=$((day_count + 1))
        day_index=$((day_index + 1))
    done
    
    # Дни текущего месяца
    i=1
    while [ $i -le $days_in_target_month ] && [ $day_count -lt 42 ]; do
        # Определяем день недели (0=пн, 6=вс)
        day_of_week=$((day_index % 7))
        
        holiday=$(is_holiday $i $target_month $target_year)
        
        style="tmonth"
        if [ $target_year -eq $current_year ] && [ $target_month -eq $current_month ] && [ $i -eq $current_day ]; then
            style="today"
        elif [ -n "$holiday" ]; then
            style="tholiday"
        elif [ $day_of_week -eq 5 ] || [ $day_of_week -eq 6 ]; then
            style="tweekend"
        fi
        
        if [ -n "$holiday" ]; then
            # Экранируем кавычки в названии праздника
            holiday_escaped=$(echo "$holiday" | sed 's/"/\\"/g')
            printf ',"day%d":{"day":%d,"style":"%s","holiday":"%s"}' $day_index $i $style "$holiday_escaped"
        else
            printf ',"day%d":{"day":%d,"style":"%s"}' $day_index $i $style
        fi
        
        i=$((i + 1))
        day_count=$((day_count + 1))
        day_index=$((day_index + 1))
    done
    
    # Дни следующего месяца
    i=1
    while [ $day_count -lt 42 ]; do
        # Определяем день недели (0=пн, 6=вс)
        day_of_week=$((day_index % 7))
        
        holiday=$(is_holiday $i $next_month $next_year)
        
        style="omonth"
        if [ $next_year -eq $current_year ] && [ $next_month -eq $current_month ] && [ $i -eq $current_day ]; then
            style="today"
        elif [ -n "$holiday" ]; then
            style="oholiday"
        elif [ $day_of_week -eq 5 ] || [ $day_of_week -eq 6 ]; then
            style="oweekend"
        fi
        
        if [ -n "$holiday" ]; then
            # Экранируем кавычки в названии праздника
            holiday_escaped=$(echo "$holiday" | sed 's/"/\\"/g')
            printf ',"day%d":{"day":%d,"style":"%s","holiday":"%s"}' $day_index $i $style "$holiday_escaped"
        else
            printf ',"day%d":{"day":%d,"style":"%s"}' $day_index $i $style
        fi
        
        i=$((i + 1))
        day_count=$((day_count + 1))
        day_index=$((day_index + 1))
    done
    
    echo "}"
}

# Функция для генерации календаря года
generate_year_calendar() {
    target_year=$1
    
    current_year=$(date +%Y)
    current_month=$(date +%-m)
    
    # JSON в одну строку
    printf '{"mode":"year","year":%d' $target_year
    
    i=1
    while [ $i -le 12 ]; do
        is_current="false"
        if [ $target_year -eq $current_year ] && [ $i -eq $current_month ]; then
            is_current="true"
        fi
        
        printf ',"month%d":{"month":%d,"name":"%s","cur":%s}' $i $i "$(month_name $i)" $is_current
        
        i=$((i + 1))
    done
    
    echo "}"
}

# Функция для отправки сигнала обновления EWW
update_eww() {
    # Отправляем сигнал для обновления виджета
    if command -v eww >/dev/null 2>&1; then
        eww update calendar_data="$(generate_calendar_data)"
    fi
}

# Функция для генерации данных календаря
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

# Основная логика
case "$1" in
    "next")
        state=$(load_state)
        year=$(echo $state | cut -d' ' -f1)
        month=$(echo $state | cut -d' ' -f2)
        mode=$(echo $state | cut -d' ' -f3)
        
        if [ "$mode" = "month" ]; then
            if [ $month -eq 12 ]; then
                new_month=1
                new_year=$((year + 1))
            else
                new_month=$((month + 1))
                new_year=$year
            fi
            save_state $new_year $new_month $mode
        else
            new_year=$((year + 1))
            save_state $new_year $month $mode
        fi
        update_eww
        ;;
    "prev")
        state=$(load_state)
        year=$(echo $state | cut -d' ' -f1)
        month=$(echo $state | cut -d' ' -f2)
        mode=$(echo $state | cut -d' ' -f3)
        
        if [ "$mode" = "month" ]; then
            if [ $month -eq 1 ]; then
                new_month=12
                new_year=$((year - 1))
            else
                new_month=$((month - 1))
                new_year=$year
            fi
            save_state $new_year $new_month $mode
        else
            new_year=$((year - 1))
            save_state $new_year $month $mode
        fi
        update_eww
        ;;
    "today")
        current_year=$(date +%Y)
        current_month=$(date +%-m)
        save_state $current_year $current_month "month"
        update_eww
        ;;
    "next_year")
        state=$(load_state)
        year=$(echo $state | cut -d' ' -f1)
        month=$(echo $state | cut -d' ' -f2)
        mode=$(echo $state | cut -d' ' -f3)
        
        new_year=$((year + 1))
        save_state $new_year $month $mode
        update_eww
        ;;
    "prev_year")
        state=$(load_state)
        year=$(echo $state | cut -d' ' -f1)
        month=$(echo $state | cut -d' ' -f2)
        mode=$(echo $state | cut -d' ' -f3)
        
        new_year=$((year - 1))
        save_state $new_year $month $mode
        update_eww
        ;;
    "toggle_mode")
        state=$(load_state)
        year=$(echo $state | cut -d' ' -f1)
        month=$(echo $state | cut -d' ' -f2)
        mode=$(echo $state | cut -d' ' -f3)
        
        if [ "$mode" = "month" ]; then
            save_state $year $month "year"
        else
            save_state $year $month "month"
        fi
        update_eww
        ;;
    "select_month")
        if [ -z "$2" ]; then
            echo "Ошибка: укажите номер месяца (1-12)" >&2
            exit 1
        fi
        selected_month=$2
        
        state=$(load_state)
        year=$(echo $state | cut -d' ' -f1)
        
        save_state $year $selected_month "month"
        update_eww
        ;;
    "reset")
        current_year=$(date +%Y)
        current_month=$(date +%-m)
        save_state $current_year $current_month "month"
        ;;
    "listen")
        # Режим для deflisten - постоянно мониторит состояние
        last_output=""
        while true; do
            current_output=$(generate_calendar_data)
            # Выводим только если данные изменились
            if [ "$current_output" != "$last_output" ]; then
                echo "$current_output"
                last_output="$current_output"
            fi
            # Ждем изменения файла состояния или 50мс для 20 FPS
            if command -v inotifywait >/dev/null 2>&1; then
                inotifywait -t 0.05 -e modify "$STATE_FILE" >/dev/null 2>&1
            else
                sleep 0.05
            fi
        done
        ;;
    "")
        # Одноразовый вывод для тестирования
        generate_calendar_data
        ;;
    *)
        echo "Использование:"
        echo "  $0              - показать текущий календарь"
        echo "  $0 listen       - режим deflisten (мониторинг состояния)"
        echo "  $0 next         - следующий месяц/год"
        echo "  $0 prev         - предыдущий месяц/год"
        echo "  $0 next_year    - следующий год"
        echo "  $0 prev_year    - предыдущий год"
        echo "  $0 today        - вернуться к текущему месяцу"
        echo "  $0 toggle_mode  - переключить режим месяц/год"
        echo "  $0 select_month N - выбрать месяц (1-12)"
        echo "  $0 reset        - сброс состояния"
        exit 1
        ;;
esac
