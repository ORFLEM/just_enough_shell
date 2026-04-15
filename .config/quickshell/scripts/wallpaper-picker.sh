#!/usr/bin/env bash

WALL_DIRS=(
  "$HOME/Pictures/Wallpapers"
  "/mnt/media/файлы/обои"
  "/mnt/media/файлы/обои/.anime"
  "/mnt/media/файлы/обои/Minimalist"
  "/mnt/media/файлы/обои/WideScreen"
  "/mnt/media/файлы/обои/Abstract"
  "/mnt/media/файлы/обои/видео обои"
)

CACHE_DIR="$HOME/.cache/walls"
PREVIEW_DIR="$HOME/.cache/wall_prevs"
STATIC_CACHE="$CACHE_DIR/no-live-bg.jpg"
VIDEO_CACHE="$CACHE_DIR/live-bg.mp4"
VIDEO_FRAME="$CACHE_DIR/video-frame.jpg"
LOG_FILE="$CACHE_DIR/wallpaper.log"
SESSION=$(echo $XDG_SESSION_DESKTOP | awk -F: '{ print $1 }')

mkdir -p "$CACHE_DIR" "$PREVIEW_DIR"

# Логирование
log() {
    echo "[$(date '+%H:%M:%S')] $*" >> "$LOG_FILE"
}

case "$1" in
  list)
    all_files=()
    file_index=0

    for dir in "${WALL_DIRS[@]}"; do
      [ -d "$dir" ] || continue

      while IFS= read -r -d '' file; do
        cache_thumb="$PREVIEW_DIR/thumb_${file_index}.jpg"
        all_files+=("$file|image|$cache_thumb")
        ((file_index++))
      done < <(find "$dir" -maxdepth 1 -type f \( -iname "*.jpg" -o -iname "*.png" -o -iname "*.webp" \) -print0 2>/dev/null)

      while IFS= read -r -d '' file; do
        cache_thumb="$PREVIEW_DIR/thumb_${file_index}.jpg"
        all_files+=("$file|video|$cache_thumb")
        ((file_index++))
      done < <(find "$dir" -maxdepth 1 -type f -iname "*.mp4" -print0 2>/dev/null)
    done

    # Группируем по 3
    echo "["
    row_count=0
    for i in "${!all_files[@]}"; do
      col=$((i % 3))
      
      # Начало нового ряда
      if [ $col -eq 0 ]; then
        [ $row_count -gt 0 ] && echo "]},"
        echo -n '{"row":['
        ((row_count++))
      else
        echo -n ","
      fi

      IFS="|" read -r filepath filetype thumbpath <<< "${all_files[$i]}"
      filename=$(basename "$filepath")

      filepath_escaped="${filepath//\"/\\\"}"
      filename_escaped="${filename//\"/\\\"}"
      thumbpath_escaped="${thumbpath//\"/\\\"}"

      printf '{"path":"%s","name":"%s","type":"%s","thumb":"%s"}' \
        "$filepath_escaped" "$filename_escaped" "$filetype" "$thumbpath_escaped"
    done
    
    # Закрываем последний ряд
    echo "]}"
    echo "]"
    ;;

  cache-all)
    all_files=()
    file_index=0

    for dir in "${WALL_DIRS[@]}"; do
      [ -d "$dir" ] || continue

      while IFS= read -r -d '' file; do
        all_files+=("$file|image")
      done < <(find "$dir" -maxdepth 1 -type f \( -iname "*.jpg" -o -iname "*.png" -o -iname "*.webp" \) -print0 2>/dev/null)

      while IFS= read -r -d '' file; do
        all_files+=("$file|video")
      done < <(find "$dir" -maxdepth 1 -type f -iname "*.mp4" -print0 2>/dev/null)
    done

    log "Caching ${#all_files[@]} thumbnails..."

    for i in "${!all_files[@]}"; do
      IFS="|" read -r filepath filetype <<< "${all_files[$i]}"
      cache_path="$PREVIEW_DIR/thumb_${i}.jpg"

      [ -f "$cache_path" ] && continue

      if [ "$filetype" = "image" ]; then
        ffmpeg -i "$filepath" -vf scale=300:-1 -q:v 3 "$cache_path" -y 2>/dev/null &
      else
        ffmpeg -ss 00:00:02 -i "$filepath" -vframes 1 -vf scale=300:-1 -q:v 3 "$cache_path" -y 2>/dev/null &
      fi
      
      (( (i + 1) % 15 == 0 )) && wait
    done

    wait
    log "Cache done!"
    ;;

  clean-cache)
    rm -rf "$PREVIEW_DIR"
    mkdir -p "$PREVIEW_DIR"
    log "Cache cleaned"
    ;;

  set)
    FULL_PATH="$2"
    MODE="${3:-stat}"

    log "Setting: $FULL_PATH (mode: $MODE)"

    [ ! -f "$FULL_PATH" ] && log "File not found!" && exit 1

    IS_VIDEO=false
    [[ "$FULL_PATH" =~ \.(mp4|webm|mkv)$ ]] && IS_VIDEO=true

    if $IS_VIDEO; then
      # ВИДЕО
      cp "$FULL_PATH" "$VIDEO_CACHE"
      ffmpeg -ss 00:00:02 -i "$VIDEO_CACHE" -vframes 1 -vf "scale=1920:-1" -q:v 2 "$VIDEO_FRAME" -y 2>/dev/null
      
      pkill -x mpvpaper 2>/dev/null
      pkill -x swaybg 2>/dev/null
      
      ZOOM_OPT=""
      [ "$MODE" = "zoom" ] && ZOOM_OPT="video-zoom=0.43"
      
      mpvpaper -v -o "no-audio loop $ZOOM_OPT" '*' "$VIDEO_CACHE" >/dev/null 2>&1 &
      
      # Ждём запуска БЕЗ sleep - проверяем в цикле
      for i in {1..5}; do
        pgrep -x mpvpaper >/dev/null && break
        sleep 0.1
      done
      
      [ -f "$VIDEO_FRAME" ] && wallust -s run "$VIDEO_FRAME" 2>/dev/null
      
    else
      # СТАТИКА
       pkill -x mpvpaper 2>/dev/null
       
       # Проверяем разрешение
       resolution=$(ffprobe -v error -select_streams v:0 -show_entries stream=width,height -of csv=p=0 "$FULL_PATH" 2>/dev/null | tr ',' 'x')
       width=$(echo "$resolution" | cut -d'x' -f1)
       
       # Если больше 4K (3840px) - ресайзим
       if [ "$width" -gt 3840 ]; then
         log "Large image detected ($resolution), resizing..."
         ffmpeg -i "$FULL_PATH" -vf scale=3440:-1 -q:v 2 "$STATIC_CACHE" -y 2>/dev/null
       else
         cp "$FULL_PATH" "$STATIC_CACHE"
       fi
       
       [ ! -s "$STATIC_CACHE" ] && log "Cache empty!" && exit 1
      
      pkill -x swaybg 2>/dev/null
      
      case "$MODE" in
        zoom)     MODE_ARG="fit" ;;
        no-zoom)  MODE_ARG="stretch" ;;
        *)        MODE_ARG="fill" ;;
      esac
                  
      wallust -s run "$STATIC_CACHE" 2>/dev/null &

      if [ "$SESSION" = "sway" ]; then
        swaymsg reload
      else
        pkill -x swaybg 2>/dev/null
        swaybg -o '*' -i "$STATIC_CACHE" -m "$MODE_ARG" >> "$LOG_FILE" 2>&1 &
      fi
    fi
   
    log "Done!"
    ;;

  *)
    echo "Usage: $0 {list|cache-all|clean-cache|set <path> <mode>}"
    exit 1
    ;;
esac
