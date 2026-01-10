#!/bin/sh

## Files and Data
PREV_TOTAL=0
PREV_IDLE=0
cpuFile="/tmp/.cpu_usage"
LAST_OUTPUT=""

## Get CPU usage
get_cpu() {
	if [ -f "${cpuFile}" ]; then
		fileCont=$(cat "${cpuFile}")
		PREV_TOTAL=$(echo "${fileCont}" | head -n 1)
		PREV_IDLE=$(echo "${fileCont}" | tail -n 1)
	fi

	CPU=($(grep '^cpu ' /proc/stat))
	unset CPU[0]

	# idle + iowait
	IDLE=${CPU[3]}
	IOWAIT=${CPU[4]}
	IDLE_ALL=$((IDLE+IOWAIT))

	# total = всё
	TOTAL=0
	for VALUE in "${CPU[@]}"; do
		TOTAL=$((TOTAL+VALUE))
	done

	if [ "$PREV_TOTAL" != "" ] && [ "$PREV_IDLE" != "" ]; then
		DIFF_IDLE=$((IDLE_ALL-PREV_IDLE))
		DIFF_TOTAL=$((TOTAL-PREV_TOTAL))
		DIFF_USAGE=$(((1000*(DIFF_TOTAL-DIFF_IDLE)/DIFF_TOTAL+5)/10))
		echo "${DIFF_USAGE}"
	else
		echo "0"
	fi

	echo "${TOTAL}" > "${cpuFile}"
	echo "${IDLE_ALL}" >> "${cpuFile}"
}

## Get Used memory
get_mem() {
	free -m | awk '/Mem:/ {printf("%.0f", ($3/$2)*100)}'
}

## Get GPU usage (AMD, card1)
get_gpu() {
	if [ -f /sys/class/drm/card1/device/gpu_busy_percent ]; then
		cat /sys/class/drm/card1/device/gpu_busy_percent
	else
		echo "0"
	fi
}

## Main loop
while true; do
	CPU=$(get_cpu)
	MEM=$(get_mem)
	GPU=$(get_gpu)

	OUTPUT="{\"cpu\":${CPU},\"mem\":${MEM},\"gpu\":${GPU}}"

	if [ "$OUTPUT" != "$LAST_OUTPUT" ]; then
		echo "$OUTPUT"
		LAST_OUTPUT="$OUTPUT"
	fi

	sleep 0.2
done
